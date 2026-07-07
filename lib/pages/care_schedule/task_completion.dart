import 'package:open_plant/pages/care_schedule/care_task_type.dart';

/// An immutable event recording that a care task was completed.
class TaskCompletion {
  final CareTaskType taskType;
  final String plantId;
  final DateTime completedAt;
  final String? note;

  const TaskCompletion({
    required this.taskType,
    required this.plantId,
    required this.completedAt,
    this.note,
  });

  TaskCompletion copyWith({
    CareTaskType? taskType,
    String? plantId,
    DateTime? completedAt,
    String? note,
    bool clearNote = false,
  }) {
    return TaskCompletion(
      taskType: taskType ?? this.taskType,
      plantId: plantId ?? this.plantId,
      completedAt: completedAt ?? this.completedAt,
      note: clearNote ? null : (note ?? this.note),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'taskType': taskType.toJson(),
      'plantId': plantId,
      'completedAt': completedAt.toIso8601String(),
      'note': note,
    };
  }

  factory TaskCompletion.fromJson(Map<String, dynamic> json) {
    return TaskCompletion(
      taskType: CareTaskType.fromJson(json['taskType'] as String),
      plantId: json['plantId'] as String,
      completedAt: DateTime.parse(json['completedAt'] as String),
      note: json['note'] as String?,
    );
  }
}
