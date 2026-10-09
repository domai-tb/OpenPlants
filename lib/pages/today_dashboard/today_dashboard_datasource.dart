import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/today_dashboard/today_dashboard_entity.dart';

/// Data source for the today dashboard.
class TodayDashboardDataSource {
  final PlantCollectionUsecases plantCollection;

  const TodayDashboardDataSource({required this.plantCollection});

  Future<DashboardData> fetchDashboardData() async {
    final plants = await plantCollection.loadPlants();

    return DashboardData(totalPlantCount: plants.length);
  }
}
