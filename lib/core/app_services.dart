import 'package:open_plant/pages/care_schedule/care_schedule_usecases.dart';
import 'package:open_plant/pages/model_info/model_info_usecases.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_usecases.dart';
import 'package:open_plant/pages/more/more_usecases.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_usecases.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_usecases.dart';
import 'package:open_plant/pages/species_library/species_library_usecases.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_usecases.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_usecases.dart';

/// Aggregates feature use-cases for convenient access via `AppScope`.
///
/// Wiring happens in `lib/core/injection.dart` (GetIt), so pages can stay free of
/// plugin imports.
class AppServices {
  final PlantClassifierUsecases plantIdentification;
  final MoreUsecases more;
  final PlantCollectionUsecases plantCollection;
  final SpeciesLibraryUsecases speciesLibrary;
  final TodayDashboardUsecases todayDashboard;
  final CareScheduleUsecases careSchedule;
  final SymptomLoggerUseCases symptomLogger;
  final PlantJournalUseCases plantJournal;
  final RoomProfilesUsecases roomProfiles;
  final ModelInfoUseCase modelInfo;

  const AppServices({
    required this.plantIdentification,
    required this.more,
    required this.plantCollection,
    required this.speciesLibrary,
    required this.todayDashboard,
    required this.careSchedule,
    required this.symptomLogger,
    required this.plantJournal,
    required this.roomProfiles,
    required this.modelInfo,
  });
}
