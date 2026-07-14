import 'package:flutter/foundation.dart';

import 'package:open_plants/pages/care_schedule/care_schedule_usecases.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_history_usecases.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_usecases.dart';
import 'package:open_plants/pages/plant_photo_timeline/plant_photo_timeline_usecases.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_usecases.dart';

/// Orchestrates deletion of all associated data when a plant is removed.
///
/// Centralizes the cascade logic that was previously scattered across
/// the detail page, ensuring every data source is cleaned up consistently.
class PlantDataCleanup {
  final PlantJournalUseCases _journalUsecases;
  final SymptomLoggerUseCases _symptomUsecases;
  final DiagnosisHistoryUseCases _diagnosisHistoryUsecases;
  final PlantPhotoTimelineUseCases _photoTimelineUsecases;
  final CareScheduleUsecases _careScheduleUsecases;

  PlantDataCleanup({
    required PlantJournalUseCases journalUsecases,
    required SymptomLoggerUseCases symptomUsecases,
    required DiagnosisHistoryUseCases diagnosisHistoryUsecases,
    required PlantPhotoTimelineUseCases photoTimelineUsecases,
    required CareScheduleUsecases careScheduleUsecases,
  })  : _journalUsecases = journalUsecases,
        _symptomUsecases = symptomUsecases,
        _diagnosisHistoryUsecases = diagnosisHistoryUsecases,
        _photoTimelineUsecases = photoTimelineUsecases,
        _careScheduleUsecases = careScheduleUsecases;

  /// Delete all associated data for [plantId] across all data sources.
  ///
  /// Each operation is attempted independently — if one fails, the others
  /// are still attempted to minimize orphaned data. Errors are logged but
  /// do not prevent subsequent cleanup operations.
  Future<void> deleteAllForPlant(String plantId) async {
    // Delete growth photos
    await _safeDelete('photos', () => _photoTimelineUsecases.deleteAllPhotos(plantId));

    // Delete journal entries (also cleans up their photo files)
    await _safeDelete('journal', () => _journalUsecases.deleteEntriesForPlant(plantId));

    // Delete symptom log entries and their drafts
    await _safeDelete('symptoms', () => _symptomUsecases.deleteEntriesForPlant(plantId));

    // Delete diagnosis results
    await _safeDelete('diagnosis', () => _diagnosisHistoryUsecases.deleteResultsForPlant(plantId));

    // Delete care schedule completions, custom rules, and actions
    await _safeDelete('completions', () => _careScheduleUsecases.deleteCompletionsForPlant(plantId));
    await _safeDelete('custom rules', () => _careScheduleUsecases.deleteCustomRulesForPlant(plantId));
    await _safeDelete('schedule actions', () => _careScheduleUsecases.deleteAllScheduleActionsForPlant(plantId));
  }

  /// Safely execute a delete operation, logging errors without rethrowing.
  Future<void> _safeDelete(String name, Future<void> Function() operation) async {
    try {
      await operation();
    } catch (e) {
      debugPrint('Failed to delete $name for plant: $e');
    }
  }
}
