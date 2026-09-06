/// A user-defined care rule that overrides the computed schedule for a plant.
///
/// Custom rules are per-plant and take precedence over species defaults,
/// room modifiers, and pot-type modifiers when enabled.
///
/// Optional metric linkage: when [metricId] is set, the rule triggers
/// measurement reminders and alert tasks for the linked metric.
class CustomCareRuleEntity {
  final String id;
  final String plantId;
  final String taskType;
  final int intervalDays;
  final bool reminderEnabled;
  final String? reminderTime;
  final List<String>? reminderDays;
  final bool isEnabled;
  final DateTime createdAt;

  /// Optional link to a metric definition. When set, this rule generates
  /// measurement reminders based on the metric's measurement history.
  final String? metricId;

  /// Whether a measurement is required before task completion.
  /// Only meaningful when [metricId] is set.
  final bool isMeasurementRequired;

  const CustomCareRuleEntity({
    required this.id,
    required this.plantId,
    required this.taskType,
    required this.intervalDays,
    this.reminderEnabled = false,
    this.reminderTime,
    this.reminderDays,
    this.isEnabled = true,
    required this.createdAt,
    this.metricId,
    this.isMeasurementRequired = false,
  });

  CustomCareRuleEntity copyWith({
    String? id,
    String? plantId,
    String? taskType,
    int? intervalDays,
    bool? reminderEnabled,
    String? reminderTime,
    bool clearReminderTime = false,
    List<String>? reminderDays,
    bool clearReminderDays = false,
    bool? isEnabled,
    DateTime? createdAt,
    String? metricId,
    bool clearMetricId = false,
    bool? isMeasurementRequired,
  }) {
    return CustomCareRuleEntity(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      taskType: taskType ?? this.taskType,
      intervalDays: intervalDays ?? this.intervalDays,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: clearReminderTime ? null : (reminderTime ?? this.reminderTime),
      reminderDays: clearReminderDays ? null : (reminderDays ?? this.reminderDays),
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      metricId: clearMetricId ? null : (metricId ?? this.metricId),
      isMeasurementRequired: isMeasurementRequired ?? this.isMeasurementRequired,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'taskType': taskType,
      'intervalDays': intervalDays,
      'reminderEnabled': reminderEnabled,
      'reminderTime': reminderTime,
      'reminderDays': reminderDays,
      'isEnabled': isEnabled,
      'createdAt': createdAt.toIso8601String(),
      'metricId': metricId,
      'isMeasurementRequired': isMeasurementRequired,
    };
  }

  factory CustomCareRuleEntity.fromJson(Map<String, dynamic> json) {
    return CustomCareRuleEntity(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      taskType: json['taskType'] as String,
      intervalDays: json['intervalDays'] as int,
      reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      reminderTime: json['reminderTime'] as String?,
      reminderDays: json['reminderDays'] != null ? (json['reminderDays'] as List<dynamic>).cast<String>() : null,
      isEnabled: json['isEnabled'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      metricId: json['metricId'] as String?,
      isMeasurementRequired: json['isMeasurementRequired'] as bool? ?? false,
    );
  }
}
