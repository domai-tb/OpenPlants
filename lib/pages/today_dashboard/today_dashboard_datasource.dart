import 'package:openplants/pages/care_schedule/care_schedule_usecases.dart';
import 'package:openplants/pages/care_schedule/care_task.dart';
import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/today_dashboard/today_dashboard_entity.dart';

/// Data source for the today dashboard.
class TodayDashboardDataSource {
  final PlantCollectionUsecases plantCollection;
  final CareScheduleUsecases careSchedule;

  const TodayDashboardDataSource({
    required this.plantCollection,
    required this.careSchedule,
  });

  Future<DashboardData> fetchDashboardData() async {
    final plants = await plantCollection.loadPlants();
    final schedule = await careSchedule.getSchedule();

    return DashboardData(
      dueToday: schedule.tasks.where((task) => task.status == CareTaskStatus.dueToday).toList(),
      overdue: schedule.tasks.where((task) => task.status == CareTaskStatus.overdue).toList(),
      totalPlantCount: plants.length,
    );
  }
}
