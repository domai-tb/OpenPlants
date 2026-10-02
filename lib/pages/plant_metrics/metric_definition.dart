/// Value type for a metric definition.
enum MetricValueType { numeric, boolean, categorical }

/// Alert response when a metric enters alert state.
enum AlertResponse { warning, careTask }

/// Immutable metric definition entity.
///
/// Defines what can be measured for a plant, including validation rules
/// and optional alert criteria.
class MetricDefinition {
  final String id;
  final String plantId;
  final String name;
  final MetricValueType valueType;
  final String? unit;
  final List<String> categoryOptions;
  final NumericBounds? numericBounds;
  final Set<String>? alertValues;
  final AlertResponse alertResponse;
  final bool isEnabled;
  final String? notes;
  final String? entryInstructions;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MetricDefinition({
    required this.id,
    required this.plantId,
    required this.name,
    required this.valueType,
    this.unit,
    this.categoryOptions = const [],
    this.numericBounds,
    this.alertValues,
    this.alertResponse = AlertResponse.warning,
    this.isEnabled = true,
    this.notes,
    this.entryInstructions,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [MetricDefinition] from a parsed JSON map.
  factory MetricDefinition.fromJson(Map<String, dynamic> json) {
    return MetricDefinition(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      name: json['name'] as String,
      valueType: MetricValueType.values.byName(json['valueType'] as String),
      unit: json['unit'] as String?,
      categoryOptions: (json['categoryOptions'] as List<dynamic>?)?.cast<String>() ?? [],
      numericBounds:
          json['numericBounds'] != null ? NumericBounds.fromJson(json['numericBounds'] as Map<String, dynamic>) : null,
      alertValues: (json['alertValues'] as List<dynamic>?)?.cast<String>().toSet(),
      alertResponse: AlertResponse.values.byName(json['alertResponse'] as String? ?? 'warning'),
      isEnabled: json['isEnabled'] as bool? ?? true,
      notes: json['notes'] as String?,
      entryInstructions: json['entryInstructions'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Serialize to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'name': name,
      'valueType': valueType.name,
      'unit': unit,
      'categoryOptions': categoryOptions,
      'numericBounds': numericBounds?.toJson(),
      'alertValues': alertValues?.toList(),
      'alertResponse': alertResponse.name,
      'isEnabled': isEnabled,
      'notes': notes,
      'entryInstructions': entryInstructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Create a copy with optional field overrides.
  MetricDefinition copyWith({
    String? id,
    String? plantId,
    String? name,
    MetricValueType? valueType,
    String? unit,
    bool clearUnit = false,
    List<String>? categoryOptions,
    NumericBounds? numericBounds,
    bool clearNumericBounds = false,
    Set<String>? alertValues,
    bool clearAlertValues = false,
    AlertResponse? alertResponse,
    bool? isEnabled,
    String? notes,
    bool clearNotes = false,
    String? entryInstructions,
    bool clearEntryInstructions = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MetricDefinition(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      name: name ?? this.name,
      valueType: valueType ?? this.valueType,
      unit: clearUnit ? null : (unit ?? this.unit),
      categoryOptions: categoryOptions ?? this.categoryOptions,
      numericBounds: clearNumericBounds ? null : (numericBounds ?? this.numericBounds),
      alertValues: clearAlertValues ? null : (alertValues ?? this.alertValues),
      alertResponse: alertResponse ?? this.alertResponse,
      isEnabled: isEnabled ?? this.isEnabled,
      notes: clearNotes ? null : (notes ?? this.notes),
      entryInstructions: clearEntryInstructions ? null : (entryInstructions ?? this.entryInstructions),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Numeric bounds for a metric definition.
class NumericBounds {
  final double? lower;
  final double? upper;

  const NumericBounds({this.lower, this.upper});

  factory NumericBounds.fromJson(Map<String, dynamic> json) {
    return NumericBounds(
      lower: (json['lower'] as num?)?.toDouble(),
      upper: (json['upper'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        if (lower != null) 'lower': lower,
        if (upper != null) 'upper': upper,
      };
}
