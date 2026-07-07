import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_entity.dart';

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
    final plantsFuture = plantCollection.loadPlants();

    final plants = await plantsFuture;

    plants.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    final recentPlants = plants.take(10).map(_toPlantSummary).toList();

    return DashboardData(
      dueToday: const [],
      overdue: const [],
      recentPlants: recentPlants,
      totalPlantCount: plants.length,
    );
  }

  PlantSummary _toPlantSummary(PlantEntity plant) {
    return PlantSummary(
      id: plant.id,
      name: plant.name,
      photoPath: plant.photoPath,
      updatedAt: plant.updatedAt,
    );
  }
}
