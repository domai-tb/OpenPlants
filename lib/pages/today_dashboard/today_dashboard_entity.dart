/// Task types for care tasks.
enum CareTaskType {
  water,
  fertilize,
  mist,
  prune,
  rotate,
  repot,
  clean,
  inspect,
}

/// A single care task displayed on the dashboard.
class CareTask {
  final String plantName;
  final String? plantId;
  final CareTaskType taskType;
  final DateTime dueDate;
  final int daysOverdue;

  const CareTask({
    required this.plantName,
    this.plantId,
    required this.taskType,
    required this.dueDate,
    this.daysOverdue = 0,
  });
}

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
