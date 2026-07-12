import 'package:open_plant/pages/care_schedule/care_task_type.dart';

/// Status of a care task relative to today.
enum CareTaskStatus {
  overdue,
  dueToday,
  upcoming,
  justCompleted,
}

/// A computed care task ready for display in the UI.
class CareTask {
  final CareTaskType taskType;
  final String plantId;
  final String plantName;
  final DateTime dueDate;
  final CareTaskStatus status;
  final int effectiveIntervalDays;
  final DateTime? completedAt;

  const CareTask({
    required this.taskType,
    required this.plantId,
    required this.plantName,
    required this.dueDate,
    required this.status,
    required this.effectiveIntervalDays,
    this.completedAt,
  });

  /// Days until due (negative = overdue).
  int daysUntilDue(DateTime today) {
    return dueDate.difference(today).inDays;
  }

  /// Human-readable due label.
  String dueLabel(DateTime today) {
    final days = daysUntilDue(today);
    if (status == CareTaskStatus.justCompleted) {
      if (days <= 0) return 'Completed — due again today';
      return 'Completed early — next due in $days days';
    }
    if (days < 0) return 'Overdue by ${-days} days';
    if (days == 0) return 'Due today';
    return 'Due in $days days';
  }
}
