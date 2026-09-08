import 'package:get_it/get_it.dart';

import 'package:openplants/core/app_services.dart';
import 'package:openplants/core/date_formatter.dart';
import 'package:openplants/core/locale_service.dart';
import 'package:openplants/core/settings.dart';
import 'package:openplants/core/unit_preferences.dart';
import 'package:openplants/pages/model_info/model_info_datasource.dart';
import 'package:openplants/pages/model_info/model_info_repository.dart';
import 'package:openplants/pages/model_info/model_info_usecases.dart';
import 'package:openplants/pages/care_schedule/care_schedule_datasource.dart';
import 'package:openplants/pages/care_schedule/care_schedule_repository.dart';
import 'package:openplants/pages/care_schedule/care_schedule_usecases.dart';
import 'package:openplants/pages/care_schedule/custom_care_rule_usecases.dart';
import 'package:openplants/pages/plant_identification/classifier/plant_classifier_datasource.dart';
import 'package:openplants/pages/plant_identification/classifier/plant_classifier_repository.dart';
import 'package:openplants/pages/plant_identification/classifier/plant_classifier_usecases.dart';
import 'package:openplants/pages/more/more_datasource.dart';
import 'package:openplants/pages/more/more_repository.dart';
import 'package:openplants/pages/more/more_usecases.dart';
import 'package:openplants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:openplants/pages/plant_collection/plant_collection_repository.dart';
import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/plant_journal/plant_journal_datasource.dart';
import 'package:openplants/pages/plant_journal/plant_journal_repository.dart';
import 'package:openplants/pages/plant_journal/plant_journal_usecases.dart';
import 'package:openplants/pages/plant_photo_timeline/plant_photo_timeline_datasource.dart';
import 'package:openplants/pages/plant_photo_timeline/plant_photo_timeline_repository.dart';
import 'package:openplants/pages/plant_photo_timeline/plant_photo_timeline_usecases.dart';
import 'package:openplants/pages/room_profiles/room_profiles_datasource.dart';
import 'package:openplants/pages/room_profiles/room_profiles_repository.dart';
import 'package:openplants/pages/room_profiles/room_profiles_usecases.dart';
import 'package:openplants/pages/species_library/species_library_datasource.dart';
import 'package:openplants/pages/species_library/species_library_repository.dart';
import 'package:openplants/pages/species_library/species_library_usecases.dart';
import 'package:openplants/pages/species_catalog/species_catalog_datasource.dart';
import 'package:openplants/pages/species_catalog/species_catalog_repository.dart';
import 'package:openplants/pages/species_catalog/species_catalog_usecases.dart';
import 'package:openplants/pages/symptom_logger/symptom_logger_datasource.dart';
import 'package:openplants/pages/symptom_logger/symptom_logger_repository.dart';
import 'package:openplants/pages/symptom_logger/symptom_logger_usecases.dart';
import 'package:openplants/pages/today_dashboard/today_dashboard_datasource.dart';
import 'package:openplants/pages/today_dashboard/today_dashboard_repository.dart';
import 'package:openplants/pages/today_dashboard/today_dashboard_usecases.dart';
import 'package:openplants/pages/light_assessment/light_assessment_datasource.dart';
import 'package:openplants/pages/light_assessment/light_assessment_repository.dart';
import 'package:openplants/pages/light_assessment/light_assessment_usecases.dart';
import 'package:openplants/pages/diagnosis/auto_diagnosis_service.dart';
import 'package:openplants/pages/diagnosis/diagnosis_datasource.dart';
import 'package:openplants/pages/diagnosis/diagnosis_history_usecases.dart';
import 'package:openplants/pages/diagnosis/diagnosis_repository.dart';
import 'package:openplants/pages/diagnosis/diagnosis_usecases.dart';
import 'package:openplants/pages/plant_names/plant_names_datasource.dart';
import 'package:openplants/pages/plant_names/plant_names_repository.dart';
import 'package:openplants/pages/plant_names/plant_names_usecases.dart';
import 'package:openplants/pages/plant_metrics/metric_definition_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_repository.dart';
import 'package:openplants/pages/plant_metrics/metric_usecases.dart';
import 'package:openplants/pages/notifications/notification_datasource.dart';
import 'package:openplants/pages/notifications/notification_repository.dart';
import 'package:openplants/pages/notifications/notification_usecases.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Global service locator (GetIt).
///
/// Keep plugin usage centralized here; UI code should access dependencies via
/// `AppScope` (or, if you prefer, via `sl<T>()` in non-UI layers).
final sl = GetIt.instance;

Future<void> init() async {
  // Core
  sl.registerSingleton<SettingsController>(await SettingsController.load());

  // Locale Service
  sl.registerLazySingleton<LocaleService>(
    () => LocaleService(sl<SettingsController>()),
  );

  // Unit Preferences
  sl.registerLazySingleton<TemperatureFormatter>(
    () => TemperatureFormatter(sl<SettingsController>()),
  );

  // Date Formatter
  sl.registerLazySingleton<DateFormatter>(
    () => DateFormatter(sl<LocaleService>()),
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
    () => PlantCollectionRepository(
      dataSource: sl(),
      speciesLibrary: sl(),
      careSchedule: sl(),
    ),
  );
  sl.registerLazySingleton<PlantCollectionUsecases>(
    () => PlantCollectionUsecases(repository: sl()),
  );

  // Plant Photo Timeline
  sl.registerLazySingleton<PlantPhotoTimelineDataSource>(
    PlantPhotoTimelineDataSource.new,
  );
  sl.registerLazySingleton<PlantPhotoTimelineRepository>(
    () => PlantPhotoTimelineRepository(
      dataSource: sl(),
      plantCollection: sl(),
    ),
  );
  sl.registerLazySingleton<PlantPhotoTimelineUseCases>(
    () => PlantPhotoTimelineUseCases(repository: sl()),
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

  // Species Catalog
  sl.registerLazySingleton<SpeciesCatalogDatasource>(
    SpeciesCatalogDatasource.new,
  );
  sl.registerLazySingleton<SpeciesCatalogRepository>(
    () => SpeciesCatalogRepository(datasource: sl()),
  );
  sl.registerLazySingleton<SpeciesCatalogUsecases>(
    () => SpeciesCatalogUsecases(repository: sl()),
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
      plantJournal: sl(),
      roomProfiles: sl(),
    ),
  );
  sl.registerLazySingleton<CustomCareRuleUsecases>(
    () => CustomCareRuleUsecases(repository: sl()),
  );

  // Symptom Logger
  sl.registerLazySingleton<SymptomLoggerDataSource>(
    SymptomLoggerDataSource.new,
  );
  sl.registerLazySingleton<SymptomLoggerRepository>(
    () => SymptomLoggerRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<SymptomLoggerUseCases>(
    () => SymptomLoggerUseCases(
      repository: sl(),
      plantCollection: sl(),
      autoDiagnosis: sl(),
    ),
  );

  // Plant Journal
  sl.registerLazySingleton<PlantJournalDataSource>(
    () => PlantJournalDataSource(
      symptomLoggerDataSource: sl(),
      diagnosisDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<PlantJournalRepository>(
    () => PlantJournalRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<PlantJournalUseCases>(
    () => PlantJournalUseCases(repository: sl()),
  );

  // Room Profiles
  sl.registerLazySingleton<RoomProfilesDatasource>(
    RoomProfilesDatasource.new,
  );
  sl.registerLazySingleton<RoomProfilesRepository>(
    () => RoomProfilesRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<RoomProfilesUsecases>(
    () => RoomProfilesUsecases(repository: sl()),
  );

  // Model Info
  sl.registerLazySingleton<ModelInfoDatasource>(ModelInfoDatasource.new);
  sl.registerLazySingleton<ModelInfoRepository>(
    () => ModelInfoRepository(datasource: sl()),
  );
  sl.registerLazySingleton<ModelInfoUseCase>(
    () => ModelInfoUseCase(repository: sl()),
  );

  // Light Assessment
  sl.registerLazySingleton<LightAssessmentDataSource>(
    () => LightAssessmentDataSource(plantDataSource: sl()),
  );
  sl.registerLazySingleton<LightAssessmentRepository>(
    () => LightAssessmentRepository(dataSource: sl()),
  );
  sl.registerLazySingleton<LightAssessmentUseCases>(
    () => LightAssessmentUseCases(
      repository: sl(),
      getLatestPhoto: (plantId) async {
        final timeline = await sl<PlantPhotoTimelineUseCases>().getTimeline(plantId);
        return timeline.isNotEmpty ? timeline.first : null;
      },
      addPhoto: (plantId, image) => sl<PlantPhotoTimelineUseCases>().addPhoto(
        plantId,
        image,
        date: DateTime.now(),
      ),
    ),
  );

  // Diagnosis
  sl.registerLazySingleton<DiagnosisDataSource>(
    DiagnosisDataSource.new,
  );
  sl.registerLazySingleton<DiagnosisEngine>(
    DiagnosisEngine.new,
  );
  sl.registerLazySingleton<DiagnosisRepository>(
    () => DiagnosisRepository(
      engine: sl(),
      dataSource: sl(),
    ),
  );
  sl.registerLazySingleton<AutoDiagnosisService>(
    () => AutoDiagnosisService(
      repository: sl(),
      engine: sl(),
      plantCollection: sl(),
      roomProfiles: sl(),
    ),
  );
  sl.registerLazySingleton<DiagnosisHistoryUseCases>(
    () => DiagnosisHistoryUseCases(repository: sl()),
  );

  // Plant Names
  sl.registerLazySingleton<PlantNamesDatasource>(
    PlantNamesDatasource.new,
  );
  sl.registerLazySingleton<PlantNamesRepository>(
    () => PlantNamesRepository(datasource: sl()),
  );
  sl.registerLazySingleton<PlantNamesUsecases>(
    () => PlantNamesUsecases(repository: sl()),
  );

  // Plant Metrics
  sl.registerLazySingleton<MetricDefinitionDataSource>(
    MetricDefinitionDataSource.new,
  );
  sl.registerLazySingleton<MetricMeasurementDataSource>(
    MetricMeasurementDataSource.new,
  );
  sl.registerLazySingleton<MetricRepository>(
    () => MetricRepository(
      definitionDataSource: sl(),
      measurementDataSource: sl(),
    ),
  );
  sl.registerLazySingleton<MetricUsecases>(
    () => MetricUsecases(repository: sl()),
  );

  // Notifications
  sl.registerLazySingleton<NotificationDataSource>(
    NotificationDataSource.new,
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepository(datasource: sl()),
  );
  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    FlutterLocalNotificationsPlugin.new,
  );
  sl.registerLazySingleton<NotificationUsecases>(
    () => NotificationUsecases(
      repository: sl(),
      plugin: sl(),
    ),
  );

  // Aggregate wiring
  sl.registerLazySingleton<AppServices>(
    () => AppServices(
      plantIdentification: sl(),
      more: sl(),
      plantCollection: sl(),
      plantPhotoTimeline: sl(),
      speciesLibrary: sl(),
      speciesCatalog: sl(),
      todayDashboard: sl(),
      careSchedule: sl(),
      customCareRules: sl(),
      symptomLogger: sl(),
      plantJournal: sl(),
      roomProfiles: sl(),
      modelInfo: sl(),
      lightAssessment: sl(),
      diagnosis: sl(),
      autoDiagnosis: sl(),
      diagnosisHistory: sl(),
      localeService: sl(),
      temperatureFormatter: sl(),
      dateFormatter: sl(),
      plantNames: sl(),
      metric: sl(),
      notification: sl(),
    ),
  );
}
