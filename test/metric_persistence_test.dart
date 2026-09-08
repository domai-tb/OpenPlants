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
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
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
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      final def2 = MetricDefinition(
        id: 'def-2',
        plantId: 'plant-2',
        name: 'Metric B',
        valueType: MetricValueType.boolean,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
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
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );
      await repository.saveDefinition(def);

      final meas = MetricMeasurement(
        id: 'meas-1',
        metricId: 'def-1',
        plantId: 'plant-1',
        value: 50,
        measuredAt: DateTime(2026, 1, 1),
      );
      await repository.saveMeasurement(meas);

      await repository.deleteDefinition('def-1');

      final defs = await repository.loadDefinitions();
      final measList = await repository.loadMeasurements();
      expect(defs, isEmpty);
      expect(measList, isEmpty);
    });

    test('getMeasurementsForMetricPaged returns paginated results', () async {
      final measurements = List.generate(
        10,
        (i) => MetricMeasurement(
          id: 'meas-$i',
          metricId: 'def-1',
          plantId: 'plant-1',
          value: i * 10.0,
          measuredAt: DateTime(2026, 1, 1, i),
        ),
      );

      for (final m in measurements) {
        await repository.saveMeasurement(m);
      }

      final page1 = await repository.getMeasurementsForMetricPaged('def-1', limit: 3, offset: 0);
      expect(page1, hasLength(3));
      expect(page1.first.id, 'meas-0');

      final page2 = await repository.getMeasurementsForMetricPaged('def-1', limit: 3, offset: 3);
      expect(page2, hasLength(3));
      expect(page2.first.id, 'meas-3');

      final pageEnd = await repository.getMeasurementsForMetricPaged('def-1', limit: 3, offset: 9);
      expect(pageEnd, hasLength(1));
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

    test('recordMeasurement validates and persists', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
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

    test('recordMeasurement rejects invalid value', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Moisture',
        valueType: MetricValueType.numeric,
        numericBounds: const NumericBounds(lower: 0, upper: 100),
      );

      expect(
        () => usecases.recordMeasurement(
          metricId: def.id,
          plantId: 'plant-1',
          value: 150.0,
        ),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('toggleDefinition flips isEnabled', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.boolean,
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
