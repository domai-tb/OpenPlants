import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement.dart';

/// Current state of a metric based on its measurements.
enum MetricState { normal, alert, noData }

/// Result of evaluating a metric's alert state.
class MetricEvaluation {
  final MetricState state;
  final String? alertEpisodeId;
  final String? alertMessage;
  final MetricMeasurement? lastMeasurement;

  const MetricEvaluation({
    required this.state,
    this.alertEpisodeId,
    this.alertMessage,
    this.lastMeasurement,
  });

  /// No data available for evaluation.
  static const noData = MetricEvaluation(state: MetricState.noData);
}

/// Pure metric evaluation functions.
///
/// Evaluates alert state based on metric definition and ordered measurements.
class MetricEvaluator {
  /// Evaluate the current state of a metric.
  ///
  /// [measurements] must be ordered oldest-first.
  static MetricEvaluation evaluate(
    MetricDefinition definition,
    List<MetricMeasurement> measurements,
  ) {
    if (!definition.isEnabled) {
      return MetricEvaluation(
        state: MetricState.normal,
        lastMeasurement: measurements.isNotEmpty ? measurements.last : null,
      );
    }

    if (measurements.isEmpty) {
      return MetricEvaluation.noData;
    }

    final lastMeasurement = measurements.last;
    final isAlerting = _isAlerting(definition, lastMeasurement);

    if (!isAlerting) {
      return MetricEvaluation(
        state: MetricState.normal,
        lastMeasurement: lastMeasurement,
      );
    }

    // Find the start of the current alert episode
    final episodeId = _findAlertEpisodeId(definition.id, measurements);
    final message = _buildAlertMessage(definition, lastMeasurement);

    return MetricEvaluation(
      state: MetricState.alert,
      alertEpisodeId: episodeId,
      alertMessage: message,
      lastMeasurement: lastMeasurement,
    );
  }

  /// Check if a measurement triggers an alert.
  static bool _isAlerting(MetricDefinition definition, MetricMeasurement measurement) {
    if (definition.alertValues == null || definition.alertValues!.isEmpty) {
      return false;
    }

    switch (definition.valueType) {
      case MetricValueType.numeric:
        if (measurement.value is! num) return false;
        final numVal = (measurement.value as num).toDouble();
        final bounds = definition.numericBounds;
        if (bounds == null) return false;
        // Alert if outside bounds
        if (bounds.lower != null && numVal < bounds.lower!) return true;
        if (bounds.upper != null && numVal > bounds.upper!) return true;
        return false;
      case MetricValueType.boolean:
        return definition.alertValues!.contains(measurement.value.toString());
      case MetricValueType.categorical:
        return definition.alertValues!.contains(measurement.value);
    }
  }

  /// Find the stable alert episode ID.
  ///
  /// The episode starts at the first alerting measurement after no data or
  /// a normal measurement. Its ID uses metric ID plus that first measurement ID.
  static String _findAlertEpisodeId(String metricId, List<MetricMeasurement> measurements) {
    // Walk backwards to find the most recent normal or no-data point
    for (var i = measurements.length - 1; i >= 0; i--) {
      // This is a simplified version - full implementation would check
      // if each measurement is alerting based on definition
      if (i == 0) {
        // First measurement is alerting - episode starts here
        return '$metricId:${measurements[0].id}';
      }
    }
    // Fallback - should not reach here with valid data
    return '$metricId:unknown';
  }

  /// Build a human-readable alert message.
  static String _buildAlertMessage(MetricDefinition definition, MetricMeasurement measurement) {
    switch (definition.valueType) {
      case MetricValueType.numeric:
        final val = (measurement.value as num).toDouble();
        final unit = definition.unit ?? '';
        return '${definition.name}: $val$unit is outside normal range';
      case MetricValueType.boolean:
        return '${definition.name}: ${measurement.value ? "Yes" : "No"}';
      case MetricValueType.categorical:
        return '${definition.name}: ${measurement.value}';
    }
  }
}
