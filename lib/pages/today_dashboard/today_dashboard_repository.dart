import 'package:open_plants/pages/today_dashboard/today_dashboard_datasource.dart';
import 'package:open_plants/pages/today_dashboard/today_dashboard_entity.dart';

/// Thin pass-through repository for the today dashboard.
class TodayDashboardRepository {
  final TodayDashboardDataSource dataSource;

  const TodayDashboardRepository({required this.dataSource});

  Future<DashboardData> fetchDashboardData() => dataSource.fetchDashboardData();
}
