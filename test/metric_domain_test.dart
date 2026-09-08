import 'package:flutter_test/flutter_test.dart';
import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement.dart';
import 'package:openplants/pages/plant_metrics/metric_evaluator.dart';

void main() {
  group('MetricDefinition', () {
    test('fromJson round-trips correctly', () {
      final json = {
        'id': 'metric-1',
        'plantId': 'plant-1',
        'name': 'Soil Moisture',
        'valueType': 'numeric',
        'unit': '%',
        'categoryOptions': <String>[],
        'numericBounds': {'lower': 20.0, 'upper': 80.0},
        'alertValues': <String>['low', 'high'],
        'alertResponse': 'warning',
        'isEnabled': true,
        'notes': 'Check weekly',
        'entryInstructions': 'Insert probe 2 inches deep',
        'createdAt': '2026-01-01T00:00:00.000',
        'updatedAt': '2026-01-01T00:00:00.000',
      };

      final def = MetricDefinition.fromJson(json);
      expect(def.id, 'metric-1');
      expect(def.plantId, 'plant-1');
      expect(def.name, 'Soil Moisture');
      expect(def.valueType, MetricValueType.numeric);
      expect(def.unit, '%');
      expect(def.numericBounds?.lower, 20.0);
      expect(def.numericBounds?.upper, 80.0);
      expect(def.alertValues, {'low', 'high'});
      expect(def.alertResponse, AlertResponse.warning);
    });

    test('toJson round-trips correctly', () {
      final def = MetricDefinition(
        id: 'test',
        plantId: 'plant-1',
        name: 'Temperature',
        valueType: MetricValueType.numeric,
        unit: '°C',
        numericBounds: const NumericBounds(lower: 15.0, upper: 30.0),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final json = def.toJson();
      final restored = MetricDefinition.fromJson(json);
      expect(restored.id, def.id);
      expect(restored.unit, def.unit);
      expect(restored.numericBounds?.lower, 15.0);
    });

    test('copyWith preserves fields', () {
      final def = MetricDefinition(
        id: 'test',
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.boolean,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final copy = def.copyWith(name: 'Updated');
      expect(copy.name, 'Updated');
      expect(copy.id, 'test');
      expect(copy.valueType, MetricValueType.boolean);
    });
  });

  group('MetricMeasurement', () {
    test('fromJson round-trips correctly', () {
      final json = {
        'id': 'meas-1',
        'metricId': 'metric-1',
        'plantId': 'plant-1',
        'value': 42.5,
        'measuredAt': '2026-01-01T12:00:00.000',
        'notes': 'After watering',
      };

      final meas = MetricMeasurement.fromJson(json);
      expect(meas.id, 'meas-1');
      expect(meas.value, 42.5);
      expect(meas.notes, 'After watering');
    });

    test('validate accepts valid numeric value', () {
      final def = MetricDefinition(
        id: 'metric-1',
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
        numericBounds: const NumericBounds(lower: 0, upper: 100),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final meas = MetricMeasurement(
        id: 'meas-1',
        metricId: 'metric-1',
        plantId: 'plant-1',
        value: 50,
        measuredAt: DateTime(2026, 1, 1),
      );

      expect(meas.validate(def), isNull);
    });

    test('validate rejects out-of-bounds numeric value', () {
      final def = MetricDefinition(
        id: 'metric-1',
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
        numericBounds: const NumericBounds(lower: 0, upper: 100),
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final meas = MetricMeasurement(
        id: 'meas-1',
        metricId: 'metric-1',
        plantId: 'plant-1',
        value: 150,
        measuredAt: DateTime(2026, 1, 1),
      );

      expect(meas.validate(def), isNotNull);
    });

    test('validate accepts valid categorical value', () {
      final def = MetricDefinition(
        id: 'metric-1',
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.categorical,
        categoryOptions: const ['Good', 'Fair', 'Poor'],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final meas = MetricMeasurement(
        id: 'meas-1',
        metricId: 'metric-1',
        plantId: 'plant-1',
        value: 'Good',
        measuredAt: DateTime(2026, 1, 1),
      );

      expect(meas.validate(def), isNull);
    });

    test('validate rejects invalid categorical value', () {
      final def = MetricDefinition(
        id: 'metric-1',
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.categorical,
        categoryOptions: const ['Good', 'Fair', 'Poor'],
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final meas = MetricMeasurement(
        id: 'meas-1',
        metricId: 'metric-1',
        plantId: 'plant-1',
        value: 'Excellent',
        measuredAt: DateTime(2026, 1, 1),
      );

      expect(meas.validate(def), isNotNull);
    });
  });

  group('MetricEvaluator', () {
    test('returns noData for empty measurements', () {
      final def = MetricDefinition(
        id: 'metric-1',
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final result = MetricEvaluator.evaluate(def, []);
      expect(result.state, MetricState.noData);
    });

    test('returns normal for enabled metric with normal value', () {
      final def = MetricDefinition(
        id: 'metric-1',
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
        numericBounds: const NumericBounds(lower: 0, upper: 100),
        alertValues: const {'low', 'high'},
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final measurements = [
        MetricMeasurement(
          id: 'meas-1',
          metricId: 'metric-1',
          plantId: 'plant-1',
          value: 50,
          measuredAt: DateTime(2026, 1, 1),
        ),
      ];

      final result = MetricEvaluator.evaluate(def, measurements);
      expect(result.state, MetricState.normal);
      expect(result.lastMeasurement, measurements.first);
    });

    test('returns normal for disabled metric', () {
      final def = MetricDefinition(
        id: 'metric-1',
        plantId: 'plant-1',
        name: 'Test',
        valueType: MetricValueType.numeric,
        isEnabled: false,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      final measurements = [
        MetricMeasurement(
          id: 'meas-1',
          metricId: 'metric-1',
          plantId: 'plant-1',
          value: 150,
          measuredAt: DateTime(2026, 1, 1),
        ),
      ];

      final result = MetricEvaluator.evaluate(def, measurements);
      expect(result.state, MetricState.normal);
    });
  });
}
