import 'dart:convert';

/// Notification payload entity for care task reminders.
class NotificationPayload {
  final String plantId;
  final String ruleId;
  final String taskType;
  final String? metricId;

  const NotificationPayload({
    required this.plantId,
    required this.ruleId,
    required this.taskType,
    this.metricId,
  });

  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      plantId: json['plantId'] as String,
      ruleId: json['ruleId'] as String,
      taskType: json['taskType'] as String,
      metricId: json['metricId'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'plantId': plantId,
        'ruleId': ruleId,
        'taskType': taskType,
        if (metricId != null) 'metricId': metricId,
      };

  String encode() => jsonEncode(toJson());

  static NotificationPayload? decode(String? encoded) {
    if (encoded == null || encoded.isEmpty) return null;
    try {
      final json = jsonDecode(Uri.decodeComponent(encoded)) as Map<String, dynamic>;
      return NotificationPayload.fromJson(json);
    } catch (_) {
      return null;
    }
  }
}

/// Scheduled notification record for tracking active notifications.
class ScheduledNotification {
  final int id;
  final String plantId;
  final String ruleId;
  final String taskType;
  final String? metricId;
  final DateTime scheduledTime;
  final bool isActive;

  const ScheduledNotification({
    required this.id,
    required this.plantId,
    required this.ruleId,
    required this.taskType,
    this.metricId,
    required this.scheduledTime,
    this.isActive = true,
  });

  ScheduledNotification copyWith({
    int? id,
    String? plantId,
    String? ruleId,
    String? taskType,
    String? metricId,
    DateTime? scheduledTime,
    bool? isActive,
  }) {
    return ScheduledNotification(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      ruleId: ruleId ?? this.ruleId,
      taskType: taskType ?? this.taskType,
      metricId: metricId ?? this.metricId,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isActive: isActive ?? this.isActive,
    );
  }

  factory ScheduledNotification.fromJson(Map<String, dynamic> json) {
    return ScheduledNotification(
      id: json['id'] as int,
      plantId: json['plantId'] as String,
      ruleId: json['ruleId'] as String,
      taskType: json['taskType'] as String,
      metricId: json['metricId'] as String?,
      scheduledTime: DateTime.parse(json['scheduledTime'] as String),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plantId': plantId,
        'ruleId': ruleId,
        'taskType': taskType,
        if (metricId != null) 'metricId': metricId,
        'scheduledTime': scheduledTime.toIso8601String(),
        'isActive': isActive,
      };
}
