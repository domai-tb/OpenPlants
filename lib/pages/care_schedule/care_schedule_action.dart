import 'package:flutter/foundation.dart';

import 'package:open_plants/pages/care_schedule/care_task_type.dart';

/// The kind of schedule action performed.
enum CareScheduleActionKind {
  /// The task's due date is postponed by a positive day count.
  snooze,

  /// The task's due date advances by one effective interval.
  skip,
}

/// Extension for JSON serialization of [CareScheduleActionKind].
extension CareScheduleActionKindExtension on CareScheduleActionKind {
  String toJson() => name;

  static CareScheduleActionKind fromJson(String json) {
    return CareScheduleActionKind.values.firstWhere(
      (e) => e.name == json,
      orElse: () => CareScheduleActionKind.snooze,
    );
  }
}

/// An immutable record representing a schedule-only action (snooze or skip).
///
/// This action overrides a single schedule occurrence without creating a
/// TaskCompletion record. Only one active override is required per
/// plant/task pair.
@immutable
class CareScheduleAction {
  /// The plant this action applies to.
  final String plantId;

  /// The task type being acted upon.
  final CareTaskType taskType;

  /// Whether this is a snooze or skip action.
  final CareScheduleActionKind actionKind;

  /// When the action was requested.
  final DateTime actionTime;

  /// The due date of the occurrence this action targets.
  final DateTime targetedOccurrenceDueDate;

  /// The new due date after applying this action.
  final DateTime overriddenDueDate;

  const CareScheduleAction({
    required this.plantId,
    required this.taskType,
    required this.actionKind,
    required this.actionTime,
    required this.targetedOccurrenceDueDate,
    required this.overriddenDueDate,
  });

  /// Creates a copy with optional field overrides.
  CareScheduleAction copyWith({
    String? plantId,
    CareTaskType? taskType,
    CareScheduleActionKind? actionKind,
    DateTime? actionTime,
    DateTime? targetedOccurrenceDueDate,
    DateTime? overriddenDueDate,
  }) {
    return CareScheduleAction(
      plantId: plantId ?? this.plantId,
      taskType: taskType ?? this.taskType,
      actionKind: actionKind ?? this.actionKind,
      actionTime: actionTime ?? this.actionTime,
      targetedOccurrenceDueDate: targetedOccurrenceDueDate ?? this.targetedOccurrenceDueDate,
      overriddenDueDate: overriddenDueDate ?? this.overriddenDueDate,
    );
  }

  /// Serialize to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'plantId': plantId,
      'taskType': taskType.toJson(),
      'actionKind': actionKind.toJson(),
      'actionTime': actionTime.toIso8601String(),
      'targetedOccurrenceDueDate': targetedOccurrenceDueDate.toIso8601String(),
      'overriddenDueDate': overriddenDueDate.toIso8601String(),
    };
  }

  /// Deserialize from JSON map.
  factory CareScheduleAction.fromJson(Map<String, dynamic> json) {
    return CareScheduleAction(
      plantId: json['plantId'] as String,
      taskType: CareTaskType.fromJson(json['taskType'] as String),
      actionKind: CareScheduleActionKindExtension.fromJson(json['actionKind'] as String),
      actionTime: DateTime.parse(json['actionTime'] as String),
      targetedOccurrenceDueDate: DateTime.parse(json['targetedOccurrenceDueDate'] as String),
      overriddenDueDate: DateTime.parse(json['overriddenDueDate'] as String),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareScheduleAction &&
          runtimeType == other.runtimeType &&
          plantId == other.plantId &&
          taskType == other.taskType &&
          actionKind == other.actionKind &&
          actionTime == other.actionTime &&
          targetedOccurrenceDueDate == other.targetedOccurrenceDueDate &&
          overriddenDueDate == other.overriddenDueDate;

  @override
  int get hashCode =>
      plantId.hashCode ^
      taskType.hashCode ^
      actionKind.hashCode ^
      actionTime.hashCode ^
      targetedOccurrenceDueDate.hashCode ^
      overriddenDueDate.hashCode;
}
