import 'package:get_it/get_it.dart';

import 'package:open_plant/core/app_services.dart';
import 'package:open_plant/core/settings.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_datasource.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_repository.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_usecases.dart';
import 'package:open_plant/pages/page1/page1_datasource.dart';
import 'package:open_plant/pages/page1/page1_repository.dart';
import 'package:open_plant/pages/page1/page1_usecases.dart';
import 'package:open_plant/pages/page2/page2_datasource.dart';
import 'package:open_plant/pages/page2/page2_repository.dart';
import 'package:open_plant/pages/page2/page2_usecases.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_datasource.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_repository.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_usecases.dart';
import 'package:open_plant/pages/page4/page4_datasource.dart';
import 'package:open_plant/pages/page4/page4_repository.dart';
import 'package:open_plant/pages/page4/page4_usecases.dart';
import 'package:open_plant/pages/page5/page5_datasource.dart';
import 'package:open_plant/pages/page5/page5_repository.dart';
import 'package:open_plant/pages/page5/page5_usecases.dart';
import 'package:open_plant/pages/page6/page6_datasource.dart';
import 'package:open_plant/pages/page6/page6_repository.dart';
import 'package:open_plant/pages/page6/page6_usecases.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_datasource.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_repository.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/species_library/species_library_datasource.dart';
import 'package:open_plant/pages/species_library/species_library_repository.dart';
import 'package:open_plant/pages/species_library/species_library_usecases.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_datasource.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_repository.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_usecases.dart';

/// Global service locator (GetIt).
///
/// Keep plugin usage centralized here; UI code should access dependencies via
/// `AppScope` (or, if you prefer, via `sl<T>()` in non-UI layers).
final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerSingleton<SettingsController>(await SettingsController.load());

  // Page 1
  sl.registerLazySingleton<Page1DataSource>(Page1DataSource.new);
  sl.registerLazySingleton<Page1Repository>(
    () => Page1Repository(dataSource: sl()),
  );
  sl.registerLazySingleton<Page1Usecases>(
    () => Page1Usecases(repository: sl()),
  );

  // Page 2
  sl.registerLazySingleton<Page2DataSource>(Page2DataSource.new);
  sl.registerLazySingleton<Page2Repository>(
    () => Page2Repository(dataSource: sl()),
  );
  sl.registerLazySingleton<Page2Usecases>(
    () => Page2Usecases(repository: sl()),
  );

  // Plant Classifier
  sl.registerLazySingleton<PlantClassifierDatasource>(
    PlantClassifierDatasource.new,
  );
  sl.registerLazySingleton<PlantClassifierRepository>(
    () => PlantClassifierRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<PlantClassifierUsecases>(
    () => PlantClassifierUsecases(repository: sl()),
  );

  // Page 4
  sl.registerLazySingleton<Page4DataSource>(Page4DataSource.new);
  sl.registerLazySingleton<Page4Repository>(
    () => Page4Repository(dataSource: sl()),
  );
  sl.registerLazySingleton<Page4Usecases>(
    () => Page4Usecases(repository: sl()),
  );

  // Page 5
  sl.registerLazySingleton<Page5DataSource>(Page5DataSource.new);
  sl.registerLazySingleton<Page5Repository>(
    () => Page5Repository(dataSource: sl()),
  );
  sl.registerLazySingleton<Page5Usecases>(
    () => Page5Usecases(repository: sl()),
  );

  // Page 6
  sl.registerLazySingleton<Page6DataSource>(Page6DataSource.new);
  sl.registerLazySingleton<Page6Repository>(
    () => Page6Repository(dataSource: sl()),
  );
  sl.registerLazySingleton<Page6Usecases>(
    () => Page6Usecases(repository: sl()),
  );

  // Plant Collection
  sl.registerLazySingleton<PlantCollectionDataSource>(
    PlantCollectionDataSource.new,
  );
  sl.registerLazySingleton<PlantCollectionRepository>(
    () => PlantCollectionRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<PlantCollectionUsecases>(
    () => PlantCollectionUsecases(repository: sl()),
  );

  // Species Library
  sl.registerLazySingleton<SpeciesLibraryDatasource>(
    SpeciesLibraryDatasource.new,
  );
  sl.registerLazySingleton<SpeciesLibraryRepository>(
    () => SpeciesLibraryRepository(datasource: sl()),
  );
  sl.registerLazySingleton<SpeciesLibraryUsecases>(
    () => SpeciesLibraryUsecases(repository: sl()),
  );

  // Today Dashboard
  sl.registerLazySingleton<TodayDashboardDataSource>(
    () => TodayDashboardDataSource(plantCollection: sl()),
  );
  sl.registerLazySingleton<TodayDashboardRepository>(
    () => TodayDashboardRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<TodayDashboardUsecases>(
    () => TodayDashboardUsecases(repository: sl()),
  );

  // Care Schedule
  sl.registerLazySingleton<CareScheduleDataSource>(
    CareScheduleDataSource.new,
  );
  sl.registerLazySingleton<CareScheduleRepository>(
    () => CareScheduleRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<CareScheduleUsecases>(
    () => CareScheduleUsecases(
      repository: sl(),
      plantCollection: sl(),
    ),
  );

  // Aggregate wiring
  sl.registerLazySingleton<AppServices>(
    () => AppServices(
      page1: sl(),
      page2: sl(),
      plantIdentification: sl(),
      page4: sl(),
      page5: sl(),
      page6: sl(),
      plantCollection: sl(),
      speciesLibrary: sl(),
      todayDashboard: sl(),
      careSchedule: sl(),
    ),
  );
}
