import 'package:get_it/get_it.dart';

import 'package:open_plant/core/app_services.dart';
import 'package:open_plant/core/settings.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_datasource.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_repository.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_usecases.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_datasource.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_repository.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_usecases.dart';
import 'package:open_plant/pages/more/more_datasource.dart';
import 'package:open_plant/pages/more/more_repository.dart';
import 'package:open_plant/pages/more/more_usecases.dart';
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

  // More
  sl.registerLazySingleton<MoreDataSource>(MoreDataSource.new);
  sl.registerLazySingleton<MoreRepository>(
    () => MoreRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<MoreUsecases>(
    () => MoreUsecases(repository: sl()),
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
      plantIdentification: sl(),
      more: sl(),
      plantCollection: sl(),
      speciesLibrary: sl(),
      todayDashboard: sl(),
      careSchedule: sl(),
    ),
  );
}
