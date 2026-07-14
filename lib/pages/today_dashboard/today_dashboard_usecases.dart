import 'package:open_plants/pages/today_dashboard/today_dashboard_entity.dart';
import 'package:open_plants/pages/today_dashboard/today_dashboard_repository.dart';

/// Business logic for the today dashboard.
class TodayDashboardUsecases {
  final TodayDashboardRepository repository;

  const TodayDashboardUsecases({required this.repository});

  /// Returns the dashboard data.
  ///
  /// When `totalPlantCount` is zero, the UI should show the onboarding
  /// empty state instead of regular dashboard sections.
  Future<DashboardData> getDashboardData() => repository.fetchDashboardData();
}
