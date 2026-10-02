import 'package:openplants/pages/care_schedule/care_task.dart' as schedule;

typedef CareTask = schedule.CareTask;

/// Aggregate data for the today dashboard.
class DashboardData {
  final List<CareTask> dueToday;
  final List<CareTask> overdue;
  final int totalPlantCount;

  const DashboardData({
    required this.dueToday,
    required this.overdue,
    required this.totalPlantCount,
  });

  /// Whether the user's plant collection is empty.
  bool get isEmpty => totalPlantCount == 0;
}
