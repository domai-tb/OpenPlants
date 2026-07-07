import 'package:open_plant/pages/care_schedule/care_task.dart';

/// Detects overdue tasks based on elapsed time vs effective interval.
class OverdueDetector {
  /// Tolerance margin: task is overdue when elapsed > 1.2 × effective interval.
  static const double _toleranceMultiplier = 1.2;

  /// Determine the status of a task given its last completion and effective interval.
  static CareTaskStatus detect({
    required DateTime today,
    required DateTime? lastCompletedAt,
    required int effectiveIntervalDays,
  }) {
    if (lastCompletedAt == null) {
      // Never completed — treat as due today (first-time scheduling)
      return CareTaskStatus.dueToday;
    }

    final elapsed = today.difference(lastCompletedAt).inDays;
    final overdueThreshold = (effectiveIntervalDays * _toleranceMultiplier).ceil();

    if (elapsed > overdueThreshold) {
      return CareTaskStatus.overdue;
    }

    final daysUntilDue = effectiveIntervalDays - elapsed;

    if (daysUntilDue <= 0) {
      return CareTaskStatus.dueToday;
    }

    return CareTaskStatus.upcoming;
  }
}
