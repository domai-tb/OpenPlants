import 'package:open_plants/pages/care_schedule/care_task.dart';

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

/// Detects whether a task was completed within the current calendar day's grace
/// window. A task is considered "just completed" when its most recent completion
/// timestamp falls on the same calendar day as the reference "today" date, AND
/// the task's next-due date (completion + effective interval) is in the future
/// (i.e., the task was completed early).
class GraceWindowDetector {
  /// Returns true if [completedAt] falls on the same calendar day as [today]
  /// and the next due date ([completedAt] + [effectiveIntervalDays]) is after
  /// [today] — meaning the task was genuinely completed early and should be
  /// visually distinguished.
  static bool isWithinGraceWindow({
    required DateTime? completedAt,
    required DateTime today,
    required int effectiveIntervalDays,
  }) {
    if (completedAt == null) return false;

    // Must be same calendar day
    final isSameDay =
        completedAt.year == today.year && completedAt.month == today.month && completedAt.day == today.day;
    if (!isSameDay) return false;

    // Next due date = completedAt + effectiveIntervalDays
    final nextDue = completedAt.add(Duration(days: effectiveIntervalDays));

    // If next due is still today or in the past, the task needs doing again
    // today — don't treat as "just completed"
    if (!nextDue.isAfter(today)) return false;

    return true;
  }
}
