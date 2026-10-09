/// Aggregate data for the today dashboard.
class DashboardData {
  final int totalPlantCount;

  const DashboardData({required this.totalPlantCount});

  /// Whether the user's plant collection is empty.
  bool get isEmpty => totalPlantCount == 0;
}
