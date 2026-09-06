import 'package:open_plants/pages/plant_metrics/metric_definition.dart';

/// Immutable measurement entity for a metric.
///
/// Stores a single measurement value with metadata. The value is stored as a
/// JSON primitive (number, bool, or string for categorical) and validated
/// against the metric definition before persistence.
class MetricMeasurement {
  final String id;
  final String metricId;
  final String plantId;
  final dynamic value;
  final DateTime measuredAt;
  final String? notes;

  const MetricMeasurement({
    required this.id,
    required this.metricId,
    required this.plantId,
    required this.value,
    required this.measuredAt,
    this.notes,
  });

  /// Creates a [MetricMeasurement] from a parsed JSON map.
  factory MetricMeasurement.fromJson(Map<String, dynamic> json) {
    return MetricMeasurement(
      id: json['id'] as String,
      metricId: json['metricId'] as String,
      plantId: json['plantId'] as String,
      value: json['value'],
      measuredAt: DateTime.parse(json['measuredAt'] as String),
      notes: json['notes'] as String?,
    );
  }

  /// Serialize to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'metricId': metricId,
      'plantId': plantId,
      'value': value,
      'measuredAt': measuredAt.toIso8601String(),
      'notes': notes,
    };
  }

  /// Create a copy with optional field overrides.
  MetricMeasurement copyWith({
    String? id,
    String? metricId,
    String? plantId,
    dynamic value,
    DateTime? measuredAt,
    String? notes,
    bool clearNotes = false,
  }) {
    return MetricMeasurement(
      id: id ?? this.id,
      metricId: metricId ?? this.metricId,
      plantId: plantId ?? this.plantId,
      value: value ?? this.value,
      measuredAt: measuredAt ?? this.measuredAt,
      notes: clearNotes ? null : (notes ?? this.notes),
    );
  }

  /// Validate this measurement against its definition.
  ///
  /// Returns null if valid, or an error message if invalid.
  String? validate(MetricDefinition definition) {
    if (metricId != definition.id) {
      return 'Measurement metric ID does not match definition';
    }

    switch (definition.valueType) {
      case MetricValueType.numeric:
        if (value is! num) return 'Value must be a number';
        final numVal = (value as num).toDouble();
        if (!numVal.isFinite) return 'Value must be finite';
        if (definition.numericBounds != null) {
          final bounds = definition.numericBounds!;
          if (bounds.lower != null && numVal < bounds.lower!) {
            return 'Value below minimum (${bounds.lower})';
          }
          if (bounds.upper != null && numVal > bounds.upper!) {
            return 'Value above maximum (${bounds.upper})';
          }
        }
      case MetricValueType.boolean:
        if (value is! bool) return 'Value must be a boolean';
      case MetricValueType.categorical:
        if (value is! String) return 'Value must be a string';
        if (!definition.categoryOptions.contains(value)) {
          return 'Value not in allowed categories';
        }
    }

    return null;
  }
}
