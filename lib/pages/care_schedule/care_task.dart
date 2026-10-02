import 'package:openplants/pages/care_schedule/care_task_type.dart';

/// Returns the calendar date for [date], with its time set to midnight.
DateTime calendarDate(DateTime date) => DateTime(date.year, date.month, date.day);

/// Returns the number of calendar-day boundaries from [from] to [to].
int calendarDaysBetween(DateTime from, DateTime to) {
  final fromDate = DateTime.utc(from.year, from.month, from.day);
  final toDate = DateTime.utc(to.year, to.month, to.day);
  return toDate.difference(fromDate).inDays;
}

/// Adds [days] calendar days while preserving local midnight across DST.
DateTime addCalendarDays(DateTime date, int days) => DateTime(date.year, date.month, date.day + days);

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
  final DateTime? occurrenceDueDate;
  final String? alertEpisodeId;
  final String? alertMetricName;

  const CareTask({
    required this.taskType,
    required this.plantId,
    required this.plantName,
    required this.dueDate,
    required this.status,
    required this.effectiveIntervalDays,
    this.completedAt,
    this.occurrenceDueDate,
    this.alertEpisodeId,
    this.alertMetricName,
  });

  String get displayName => alertMetricName ?? taskType.label;

  /// Stable due date for the occurrence, even while an action overrides [dueDate].
  DateTime get scheduleOccurrenceDueDate => calendarDate(occurrenceDueDate ?? dueDate);

  /// Days until due (negative = overdue).
  int daysUntilDue(DateTime today) {
    return calendarDaysBetween(today, dueDate);
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
