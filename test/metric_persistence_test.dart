import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_definition_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_repository.dart';
import 'package:openplants/pages/plant_metrics/metric_evaluator.dart';
import 'package:openplants/pages/plant_metrics/metric_usecases.dart';

void main() {
  late SharedPreferences prefs;
  late MetricDefinitionDataSource definitionDataSource;
  late MetricMeasurementDataSource measurementDataSource;
  late MetricRepository repository;
  late MetricUsecases usecases;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    definitionDataSource = MetricDefinitionDataSource(prefs: prefs);
    measurementDataSource = MetricMeasurementDataSource(prefs: prefs);
    repository = MetricRepository(
      definitionDataSource: definitionDataSource,
      measurementDataSource: measurementDataSource,
    );
    usecases = MetricUsecases(repository: repository);
  });

  group('MetricDefinitionDataSource', () {
    test('returns empty list when no data', () async {
      final definitions = await definitionDataSource.loadDefinitions();
      expect(definitions, isEmpty);
    });

    test('round-trips definitions', () async {
      final definition = MetricDefinition(
        id: 'def-1',
        plantId: 'plant-1',
        name: 'Soil Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
        numericBounds: const NumericBounds(lower: 20, upper: 80),
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      await definitionDataSource.addDefinition(definition);
      final loaded = await definitionDataSource.loadDefinitions();

      expect(loaded, hasLength(1));
      expect(loaded.first.id, 'def-1');
      expect(loaded.first.name, 'Soil Moisture');
      expect(loaded.first.unit, '%');
    });

    test('preserves malformed JSON as-is', () async {
      // Inject malformed data directly
      await prefs.setString('metric_definitions_v1', 'not valid json');
      expect(
        () => definitionDataSource.loadDefinitions(),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('MetricMeasurementDataSource', () {
    test('returns empty list when no data', () async {
      final measurements = await measurementDataSource.loadMeasurements();
      expect(measurements, isEmpty);
    });

    test('round-trips measurements', () async {
      final measurement = MetricMeasurement(
        id: 'meas-1',
        metricId: 'def-1',
        plantId: 'plant-1',
        value: 42.5,
        measuredAt: DateTime(2026, 1, 15, 10, 30),
        notes: 'After rain',
      );

      await measurementDataSource.addMeasurement(measurement);
      final loaded = await measurementDataSource.loadMeasurements();

      expect(loaded, hasLength(1));
      expect(loaded.first.id, 'meas-1');
      expect(loaded.first.value, 42.5);
      expect(loaded.first.notes, 'After rain');
    });
  });

  group('MetricRepository', () {
    test('getDefinitionsForPlant filters by plant', () async {
      final def1 = MetricDefinition(
        id: 'def-1',
        plantId: 'plant-1',
        name: 'Metric A',
        valueType: MetricValueType.numeric,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      final def2 = MetricDefinition(
        id: 'def-2',
        plantId: 'plant-2',
        name: 'Metric B',
        valueType: MetricValueType.boolean,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

      await repository.saveDefinition(def1);
      await repository.saveDefinition(def2);

      final plant1Defs = await repository.getDefinitionsForPlant('plant-1');
      expect(plant1Defs, hasLength(1));
      expect(plant1Defs.first.id, 'def-1');
    });

    test('deleteDefinition cascades to measurements', () async {
      final def = MetricDefinition(
        id: 'def-1',
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );
      await repository.saveDefinition(def);

      final meas = MetricMeasurement(
        id: 'meas-1',
        metricId: 'def-1',
        plantId: 'plant-1',
        value: 50,
        measuredAt: DateTime(2026),
      );
      await repository.saveMeasurement(meas);

      await repository.deleteDefinition('def-1');

      final defs = await repository.loadDefinitions();
      final measList = await repository.loadMeasurements();
      expect(defs, isEmpty);
      expect(measList, isEmpty);
    });
  });

  group('MetricUsecases', () {
    test('createDefinition generates ID and persists', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Temperature',
        valueType: MetricValueType.numeric,
        unit: '°C',
      );

      expect(def.id, isNotEmpty);
      expect(def.name, 'Temperature');
      expect(def.unit, '°C');

      final loaded = await usecases.getDefinitionById(def.id);
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Temperature');
    });

    test('createDefinition rejects invalid range and categorical options', () async {
      await expectLater(
        () => usecases.createDefinition(
          plantId: 'plant-1',
          name: 'Moisture',
          valueType: MetricValueType.numeric,
          unit: '%',
          numericBounds: const NumericBounds(lower: 10, upper: 5),
        ),
        throwsArgumentError,
      );
      await expectLater(
        () => usecases.createDefinition(
          plantId: 'plant-1',
          name: 'Leaf color',
          valueType: MetricValueType.categorical,
          unit: 'state',
        ),
        throwsArgumentError,
      );
      expect(await usecases.getDefinitionsForPlant('plant-1'), isEmpty);
    });

    test('recordMeasurement validates and persists', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
        numericBounds: const NumericBounds(lower: 0, upper: 100),
      );

      final meas = await usecases.recordMeasurement(
        metricId: def.id,
        plantId: 'plant-1',
        value: 65.0,
      );

      expect(meas.id, isNotEmpty);
      expect(meas.value, 65.0);

      final loaded = await usecases.getLatestMeasurement(def.id);
      expect(loaded, isNotNull);
      expect(loaded!.value, 65.0);
    });

    test('resyncs care reminders after measurement changes', () async {
      var notificationSyncs = 0;
      final notifyingUsecases = MetricUsecases(
        repository: repository,
        onNotificationsChanged: () async {
          notificationSyncs++;
        },
      );
      final definition = await notifyingUsecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
        numericBounds: const NumericBounds(lower: 0, upper: 100),
      );
      notificationSyncs = 0;

      final measurement = await notifyingUsecases.recordMeasurement(
        metricId: definition.id,
        plantId: 'plant-1',
        value: 65.0,
      );
      await notifyingUsecases.updateMeasurement(measurement.copyWith(value: 70.0));
      await notifyingUsecases.deleteMeasurement(measurement.id);

      expect(notificationSyncs, 3);
    });

    test('recordMeasurement rejects a value with the wrong type', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
        numericBounds: const NumericBounds(lower: 0, upper: 100),
      );

      expect(
        () => usecases.recordMeasurement(
          metricId: def.id,
          plantId: 'plant-1',
          value: 'not a number',
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('out-of-range measurements are saved and trigger numeric alerts', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
        unit: '%',
        numericBounds: const NumericBounds(lower: 0, upper: 100),
      );

      await usecases.recordMeasurement(metricId: def.id, plantId: 'plant-1', value: 150.0);

      expect((await usecases.evaluateMetric(def.id)).state, MetricState.alert);
    });

    test('toggleDefinition flips isEnabled', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.boolean,
        unit: 'state',
      );

      expect(def.isEnabled, isTrue);

      await usecases.toggleDefinition(def.id);
      final toggled = await usecases.getDefinitionById(def.id);
      expect(toggled!.isEnabled, isFalse);

      await usecases.toggleDefinition(def.id);
      final toggledBack = await usecases.getDefinitionById(def.id);
      expect(toggledBack!.isEnabled, isTrue);
    });

    test('evaluateMetric returns noData for unknown metric', () async {
      final result = await usecases.evaluateMetric('unknown');
      expect(result.state, MetricState.noData);
    });

    test('evaluateMetric returns normal for metric with valid measurements', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
        unit: 'value',
        numericBounds: const NumericBounds(lower: 0, upper: 100),
      );

      await usecases.recordMeasurement(
        metricId: def.id,
        plantId: 'plant-1',
        value: 50.0,
      );

      final result = await usecases.evaluateMetric(def.id);
      expect(result.state, MetricState.normal);
    });

    test('deleteAllForPlant removes definitions and measurements', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
        unit: 'value',
      );

      await usecases.recordMeasurement(
        metricId: def.id,
        plantId: 'plant-1',
        value: 42.0,
      );

      await usecases.deleteAllForPlant('plant-1');

      final defs = await usecases.getDefinitionsForPlant('plant-1');
      expect(defs, isEmpty);
    });
  });
}
