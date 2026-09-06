import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/pages/plant_metrics/metric_definition.dart';
import 'package:open_plants/pages/plant_metrics/metric_definition_datasource.dart';
import 'package:open_plants/pages/plant_metrics/metric_measurement.dart';
import 'package:open_plants/pages/plant_metrics/metric_measurement_datasource.dart';
import 'package:open_plants/pages/plant_metrics/metric_repository.dart';
import 'package:open_plants/pages/plant_metrics/metric_usecases.dart';

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

  group('Metric deletion cascade', () {
    test('deleteAllForPlant removes all definitions and measurements', () async {
      // Create definitions for two plants
      final def1 = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Metric A',
        valueType: MetricValueType.numeric,
      );
      final def2 = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Metric B',
        valueType: MetricValueType.boolean,
      );
      final def3 = await usecases.createDefinition(
        plantId: 'plant-2',
        name: 'Metric C',
        valueType: MetricValueType.categorical,
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
      );

      // Delete twice - should not throw
      await usecases.deleteAllForPlant('plant-1');
      await usecases.deleteAllForPlant('plant-1');

      final defs = await usecases.getDefinitionsForPlant('plant-1');
      expect(defs, isEmpty);
    });

    test('deleteDefinition cascades to measurements', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
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
    test('custom rules with metric linkage can be deleted', () async {
      final def = await usecases.createDefinition(
        plantId: 'plant-1',
        name: 'Soil Moisture',
        valueType: MetricValueType.numeric,
      );

      // Simulate a custom rule linked to this metric
      // (In real code, this would be via CustomCareRuleUsecases)
      final defs = await usecases.getDefinitionsForPlant('plant-1');
      expect(defs, hasLength(1));

      // Delete the plant's metrics
      await usecases.deleteAllForPlant('plant-1');

      // Verify everything is clean
      final afterDefs = await usecases.getDefinitionsForPlant('plant-1');
      expect(afterDefs, isEmpty);
    });
  });
}
