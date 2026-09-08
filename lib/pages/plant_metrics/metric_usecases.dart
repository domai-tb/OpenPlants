import 'package:uuid/uuid.dart';

import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_evaluator.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement.dart';
import 'package:openplants/pages/plant_metrics/metric_repository.dart';

/// Use cases for metric definitions and measurements.
///
/// Orchestrates business logic for metric CRUD, validation, and evaluation.
class MetricUsecases {
  final MetricRepository repository;
  static const _uuid = Uuid();

  const MetricUsecases({required this.repository});

  // --- Definition operations ---

  Future<List<MetricDefinition>> getDefinitionsForPlant(String plantId) => repository.getDefinitionsForPlant(plantId);

  Future<MetricDefinition?> getDefinitionById(String id) => repository.getDefinitionById(id);

  Future<MetricDefinition> createDefinition({
    required String plantId,
    required String name,
    required MetricValueType valueType,
    String? unit,
    List<String> categoryOptions = const [],
    NumericBounds? numericBounds,
    Set<String>? alertValues,
    AlertResponse alertResponse = AlertResponse.warning,
    String? notes,
    String? entryInstructions,
  }) async {
    final now = DateTime.now();
    final definition = MetricDefinition(
      id: _uuid.v4(),
      plantId: plantId,
      name: name,
      valueType: valueType,
      unit: unit,
      categoryOptions: categoryOptions,
      numericBounds: numericBounds,
      alertValues: alertValues,
      alertResponse: alertResponse,
      notes: notes,
      entryInstructions: entryInstructions,
      createdAt: now,
      updatedAt: now,
    );
    await repository.saveDefinition(definition);
    return definition;
  }

  Future<MetricDefinition> updateDefinition(MetricDefinition definition) async {
    final updated = definition.copyWith(updatedAt: DateTime.now());
    await repository.saveDefinition(updated);
    return updated;
  }

  Future<void> toggleDefinition(String id) async {
    final def = await repository.getDefinitionById(id);
    if (def == null) return;
    await repository.saveDefinition(
      def.copyWith(
        isEnabled: !def.isEnabled,
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteDefinition(String id) => repository.deleteDefinition(id);

  // --- Measurement operations ---

  Future<List<MetricMeasurement>> getMeasurementsForMetric(String metricId) =>
      repository.getMeasurementsForMetric(metricId);

  Future<List<MetricMeasurement>> getMeasurementsForMetricPaged(
    String metricId, {
    int limit = 50,
    int offset = 0,
  }) =>
      repository.getMeasurementsForMetricPaged(metricId, limit: limit, offset: offset);

  Future<MetricMeasurement?> getLatestMeasurement(String metricId) => repository.getLatestMeasurement(metricId);

  Future<MetricMeasurement> recordMeasurement({
    required String metricId,
    required String plantId,
    required dynamic value,
    DateTime? measuredAt,
    String? notes,
  }) async {
    // Validate against definition
    final definition = await repository.getDefinitionById(metricId);
    if (definition == null) {
      throw ArgumentError('Metric definition not found: $metricId');
    }

    final measurement = MetricMeasurement(
      id: _uuid.v4(),
      metricId: metricId,
      plantId: plantId,
      value: value,
      measuredAt: measuredAt ?? DateTime.now(),
      notes: notes,
    );

    final validationError = measurement.validate(definition);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    await repository.saveMeasurement(measurement);
    return measurement;
  }

  Future<void> updateMeasurement(MetricMeasurement measurement) async {
    final definition = await repository.getDefinitionById(measurement.metricId);
    if (definition == null) {
      throw ArgumentError('Metric definition not found: ${measurement.metricId}');
    }

    final validationError = measurement.validate(definition);
    if (validationError != null) {
      throw ArgumentError(validationError);
    }

    await repository.saveMeasurement(measurement);
  }

  Future<void> deleteMeasurement(String id) => repository.deleteMeasurement(id);

  // --- Evaluation ---

  Future<MetricEvaluation> evaluateMetric(String metricId) async {
    final definition = await repository.getDefinitionById(metricId);
    if (definition == null) return MetricEvaluation.noData;

    final measurements = await repository.getMeasurementsForMetric(metricId);
    return MetricEvaluator.evaluate(definition, measurements);
  }

  Future<Map<String, MetricEvaluation>> evaluateAllForPlant(String plantId) async {
    final definitions = await repository.getDefinitionsForPlant(plantId);
    final evaluations = <String, MetricEvaluation>{};

    for (final def in definitions) {
      final measurements = await repository.getMeasurementsForMetric(def.id);
      evaluations[def.id] = MetricEvaluator.evaluate(def, measurements);
    }

    return evaluations;
  }

  // --- Cleanup ---

  Future<void> deleteAllForPlant(String plantId) => repository.deleteDefinitionsForPlant(plantId);
}
