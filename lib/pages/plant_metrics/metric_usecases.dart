import 'package:flutter/foundation.dart';
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
  final Future<void> Function(String metricId, Future<void> Function() deleteMetric)? deleteLinkedCareRules;
  final Future<void> Function()? onNotificationsChanged;
  static const _uuid = Uuid();

  const MetricUsecases({required this.repository, this.deleteLinkedCareRules, this.onNotificationsChanged});

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
    final cleanedCategoryOptions = categoryOptions.map((option) => option.trim()).toList();
    final cleanedUnit = unit?.trim();
    final now = DateTime.now();
    final definition = MetricDefinition(
      id: _uuid.v4(),
      plantId: plantId,
      name: name.trim(),
      valueType: valueType,
      unit: cleanedUnit,
      categoryOptions: cleanedCategoryOptions,
      numericBounds: numericBounds,
      alertValues: alertValues,
      alertResponse: alertResponse,
      notes: notes,
      entryInstructions: entryInstructions,
      createdAt: now,
      updatedAt: now,
    );
    _validateDefinition(definition);
    await repository.saveDefinition(definition);
    await _syncNotifications();
    return definition;
  }

  Future<MetricDefinition> updateDefinition(MetricDefinition definition) async {
    final updated = definition.copyWith(updatedAt: DateTime.now());
    _validateDefinition(updated);
    final measurements = await repository.getMeasurementsForMetric(updated.id);
    for (final measurement in measurements) {
      final validationError = measurement.validate(updated);
      if (validationError != null) {
        throw ArgumentError('Existing measurements prevent this definition change: $validationError');
      }
    }
    await repository.saveDefinition(updated);
    await _syncNotifications();
    return updated;
  }

  void _validateDefinition(MetricDefinition definition) {
    if (definition.name.trim().isEmpty) throw ArgumentError('Metric name is required');
    if (definition.unit?.trim().isNotEmpty != true) throw ArgumentError('Metric unit is required');

    final bounds = definition.numericBounds;
    if (bounds != null) {
      if (bounds.lower?.isFinite == false || bounds.upper?.isFinite == false) {
        throw ArgumentError('Alert thresholds must be finite numbers');
      }
      if (bounds.lower != null && bounds.upper != null && bounds.lower! > bounds.upper!) {
        throw ArgumentError('Minimum cannot exceed maximum');
      }
    }

    if (definition.valueType == MetricValueType.categorical) {
      final options = definition.categoryOptions;
      final normalizedOptions = options.map((option) => option.trim().toLowerCase()).toSet();
      if (options.isEmpty ||
          options.any((option) => option.trim().isEmpty) ||
          normalizedOptions.length != options.length) {
        throw ArgumentError('Categorical metrics need non-blank, unique options');
      }
      if (!(definition.alertValues ?? {}).every(options.contains)) {
        throw ArgumentError('Alert values must be configured categories');
      }
    }

    if (definition.valueType == MetricValueType.boolean) {
      const booleanValues = {'true', 'false'};
      if (!(definition.alertValues ?? {}).every(booleanValues.contains)) {
        throw ArgumentError('Boolean alert values must be true or false');
      }
    }
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
    await _syncNotifications();
  }

  Future<void> deleteDefinition(String id) async {
    final deleteLinkedCareRules = this.deleteLinkedCareRules;
    if (deleteLinkedCareRules == null) {
      await repository.deleteDefinition(id);
      return;
    }
    await deleteLinkedCareRules(id, () => repository.deleteDefinition(id));
  }

  // --- Measurement operations ---

  Future<List<MetricMeasurement>> getMeasurementsForMetric(String metricId) =>
      repository.getMeasurementsForMetric(metricId);

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
    if (!definition.isEnabled) {
      throw ArgumentError('Metric is disabled: $metricId');
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
    await _syncNotifications();
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
    await _syncNotifications();
  }

  Future<void> deleteMeasurement(String id) async {
    await repository.deleteMeasurement(id);
    await _syncNotifications();
  }

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

  Future<void> _syncNotifications() async {
    try {
      await onNotificationsChanged?.call();
    } catch (error) {
      debugPrint('Failed to sync notifications after metric change: $error');
    }
  }
}
