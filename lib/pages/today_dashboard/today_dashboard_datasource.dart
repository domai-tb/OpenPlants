import 'package:open_plants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plants/pages/today_dashboard/today_dashboard_entity.dart';

/// Data source for the today dashboard.
///
/// Delegates plant queries to [PlantCollectionUsecases] and task queries
/// to a downstream care schedule (when wired). Each downstream capability
/// is nullable so the dashboard works even when a capability is not yet
/// registered.
///
/// TODO: Wire care-schedule use-cases once the care-schedule-system feature
/// is implemented. For now, task lists return empty gracefully.
class TodayDashboardDataSource {
  final PlantCollectionUsecases plantCollection;

  const TodayDashboardDataSource({
    required this.plantCollection,
  });

  /// Fetches dashboard data by orchestrating parallel calls to downstream
  /// data sources and composing the results into [DashboardData].
  Future<DashboardData> fetchDashboardData() async {
    final plants = await plantCollection.loadPlants();

    return DashboardData(
      dueToday: const [],
      overdue: const [],
      totalPlantCount: plants.length,
    );
  }
}
