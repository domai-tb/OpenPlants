import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/pages/care_schedule/care_schedule_datasource.dart';
import 'package:openplants/pages/care_schedule/care_schedule_repository.dart';
import 'package:openplants/pages/care_schedule/custom_care_rule.dart';
import 'package:openplants/pages/care_schedule/custom_care_rule_usecases.dart';
import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_definition_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_repository.dart';
import 'package:openplants/pages/plant_metrics/metric_usecases.dart';

void main() {
  late SharedPreferences prefs;
  late MetricDefinitionDataSource definitionDataSource;
  late MetricMeasurementDataSource measurementDataSource;
  late MetricRepository repository;
  late MetricUsecases usecases;
  late CareScheduleRepository careRepository;
  var notificationSyncCount = 0;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    notificationSyncCount = 0;
    prefs = await SharedPreferences.getInstance();
    definitionDataSource = MetricDefinitionDataSource(prefs: prefs);
    measurementDataSource = MetricMeasurementDataSource(prefs: prefs);
    careRepository = CareScheduleRepository(dataSource: CareScheduleDataSource(prefs: prefs));
    final careRuleUsecases = CustomCareRuleUsecases(
      repository: careRepository,
      onNotificationsChanged: () async {
        notificationSyncCount++;
      },
    );
    repository = MetricRepository(
      definitionDataSource: definitionDataSource,
      measurementDataSource: measurementDataSource,
    );
    usecases = MetricUsecases(
      repository: repository,
      deleteLinkedCareRules: careRuleUsecases.deleteForMetric,
    );
  });

  group('Metric deletion cascade', () {
    test('deleteAllForPlant removes all definitions and measurements', () async {
      // Create definitions for two plants
      final def1 = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Metric A',
        valueType: MetricValueType.numeric,
        unit: 'value',
      );
      final def2 = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Metric B',
        valueType: MetricValueType.boolean,
        unit: 'state',
      );
      final def3 = await usecases.createDefinition(
        plantId: 'plant-2',
        name: 'Metric C',
        valueType: MetricValueType.categorical,
        unit: 'state',
        categoryOptions: const ['Good', 'Fair', 'Poor'],
      );

      // Add measurements
      await usecases.recordMeasurement(
        metricId: def1.id,
        plantId: 'plant-1',
        value: 42.0,
      );
      await usecases.recordMeasurement(
        metricId: def2.id,
        plantId: 'plant-1',
        value: true,
      );
      await usecases.recordMeasurement(
        metricId: def3.id,
        plantId: 'plant-2',
        value: 'Good',
      );

      // Delete plant-1
      await usecases.deleteAllForPlant('plant-1');

      // Verify plant-1 data is gone
      final plant1Defs = await usecases.getDefinitionsForPlant('plant-1');
      expect(plant1Defs, isEmpty);

      // Verify plant-2 data is intact
      final plant2Defs = await usecases.getDefinitionsForPlant('plant-2');
      expect(plant2Defs, hasLength(1));
      expect(plant2Defs.first.id, def3.id);

      // Verify measurements for plant-1 are gone
      final meas1 = await usecases.getMeasurementsForMetric(def1.id);
      expect(meas1, isEmpty);
      final meas2 = await usecases.getMeasurementsForMetric(def2.id);
      expect(meas2, isEmpty);

      // Verify measurements for plant-2 are intact
      final meas3 = await usecases.getMeasurementsForMetric(def3.id);
      expect(meas3, hasLength(1));
    });

    test('deleteAllForPlant is idempotent', () async {
      await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
        unit: 'value',
      );

      // Delete twice - should not throw
      await usecases.deleteAllForPlant('plant-1');
      await usecases.deleteAllForPlant('plant-1');

      final defs = await usecases.getDefinitionsForPlant('plant-1');
      expect(defs, isEmpty);
    });

    test('deleteAllForPlant restores definitions and measurements after a failed cascade', () async {
      final definition = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Soil Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
      );
      await usecases.recordMeasurement(
        metricId: definition.id,
        plantId: 'plant-1',
        value: 42,
      );

      final failingRepository = MetricRepository(
        definitionDataSource: definitionDataSource,
        measurementDataSource: _FailingAfterPlantMeasurementDeleteDataSource(prefs: prefs),
      );

      await expectLater(
        () => failingRepository.deleteDefinitionsForPlant('plant-1'),
        throwsA(isA<StateError>()),
      );

      expect(await usecases.getDefinitionsForPlant('plant-1'), hasLength(1));
      expect(await usecases.getMeasurementsForMetric(definition.id), hasLength(1));
    });

    test('deleteDefinition cascades to measurements', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
        unit: 'value',
      );

      await usecases.recordMeasurement(
        metricId: def.id,
        plantId: 'plant-1',
        value: 50.0,
      );
      await usecases.recordMeasurement(
        metricId: def.id,
        plantId: 'plant-1',
        value: 60.0,
      );

      // Verify measurements exist
      final before = await usecases.getMeasurementsForMetric(def.id);
      expect(before, hasLength(2));

      // Delete definition
      await usecases.deleteDefinition(def.id);

      // Verify measurements are deleted
      final after = await usecases.getMeasurementsForMetric(def.id);
      expect(after, isEmpty);
    });
  });

  group('Metric custom rule linkage cleanup', () {
    test('deleting a metric removes its linked rules and preserves unrelated rules', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Soil Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
      );

      final linkedRule = CustomCareRuleEntity(
        id: 'linked-rule',
        plantId: 'plant-1',
        taskType: 'measure-moisture',
        intervalDays: 7,
        createdAt: DateTime(2026),
        metricId: def.id,
      );
      final unrelatedRule = CustomCareRuleEntity(
        id: 'unrelated-rule',
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 5,
        createdAt: DateTime(2026),
      );
      await careRepository.saveCustomCareRule(linkedRule);
      await careRepository.saveCustomCareRule(unrelatedRule);
      await usecases.recordMeasurement(metricId: def.id, plantId: 'plant-1', value: 30);

      await usecases.deleteDefinition(def.id);

      expect(await usecases.getDefinitionsForPlant('plant-1'), isEmpty);
      expect(await usecases.getMeasurementsForMetric(def.id), isEmpty);
      expect((await careRepository.getAllCustomCareRules()).map((rule) => rule.id), ['unrelated-rule']);
      expect(notificationSyncCount, 1);
    });

    test('restores linked rules and keeps the definition when measurement deletion fails', () async {
      final failingRepository = MetricRepository(
        definitionDataSource: definitionDataSource,
        measurementDataSource: _FailingDeleteMeasurementDataSource(prefs: prefs),
      );
      final careRuleUsecases = CustomCareRuleUsecases(repository: careRepository);
      final failingUsecases = MetricUsecases(
        repository: failingRepository,
        deleteLinkedCareRules: careRuleUsecases.deleteForMetric,
      );
      final def = await failingUsecases.createDefinition(
        plantId: 'plant-1',
        name: 'Soil Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
      );
      final linkedRule = CustomCareRuleEntity(
        id: 'linked-rule',
        plantId: 'plant-1',
        taskType: 'measure-moisture',
        intervalDays: 7,
        createdAt: DateTime(2026),
        metricId: def.id,
      );
      await careRepository.saveCustomCareRule(linkedRule);

      await expectLater(
        () => failingUsecases.deleteDefinition(def.id),
        throwsA(isA<StateError>()),
      );

      expect(await failingUsecases.getDefinitionById(def.id), isNotNull);
      expect((await careRepository.getAllCustomCareRules()).map((rule) => rule.id), ['linked-rule']);
    });
  });
}

class _FailingDeleteMeasurementDataSource extends MetricMeasurementDataSource {
  _FailingDeleteMeasurementDataSource({required super.prefs});

  @override
  Future<void> deleteMeasurementsForMetric(String metricId) async {
    throw StateError('measurement storage unavailable');
  }
}

class _FailingAfterPlantMeasurementDeleteDataSource extends MetricMeasurementDataSource {
  _FailingAfterPlantMeasurementDeleteDataSource({required super.prefs});

  @override
  Future<void> deleteMeasurementsForPlant(String plantId) async {
    await super.deleteMeasurementsForPlant(plantId);
    throw StateError('measurement storage unavailable after delete');
  }
}
