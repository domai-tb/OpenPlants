import 'package:flutter/foundation.dart';

import 'package:openplants/pages/care_schedule/care_schedule_usecases.dart';
import 'package:openplants/pages/diagnosis/diagnosis_history_usecases.dart';
import 'package:openplants/pages/plant_journal/plant_journal_usecases.dart';
import 'package:openplants/pages/plant_metrics/metric_usecases.dart';
import 'package:openplants/pages/plant_photo_timeline/plant_photo_timeline_usecases.dart';
import 'package:openplants/pages/symptom_logger/symptom_logger_usecases.dart';

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
  final MetricUsecases? _metricUsecases;

  PlantDataCleanup({
    required PlantJournalUseCases journalUsecases,
    required SymptomLoggerUseCases symptomUsecases,
    required DiagnosisHistoryUseCases diagnosisHistoryUsecases,
    required PlantPhotoTimelineUseCases photoTimelineUsecases,
    required CareScheduleUsecases careScheduleUsecases,
    MetricUsecases? metricUsecases,
  })  : _journalUsecases = journalUsecases,
        _symptomUsecases = symptomUsecases,
        _diagnosisHistoryUsecases = diagnosisHistoryUsecases,
        _photoTimelineUsecases = photoTimelineUsecases,
        _careScheduleUsecases = careScheduleUsecases,
        _metricUsecases = metricUsecases;

  /// Delete all associated data for [plantId] across all data sources.
  ///
  /// Each operation is attempted independently — if one fails, the others
  /// are still attempted to minimize orphaned data. Errors are logged but
  /// collected and reported after all cleanup operations have been attempted.
  Future<void> deleteAllForPlant(String plantId) async {
    final failures = <String>[];

    // Delete growth photos
    await _safeDelete('photos', () => _photoTimelineUsecases.deleteAllPhotos(plantId), failures);

    // Delete journal entries (also cleans up their photo files)
    await _safeDelete('journal', () => _journalUsecases.deleteEntriesForPlant(plantId), failures);

    // Delete symptom log entries and their drafts
    await _safeDelete('symptoms', () => _symptomUsecases.deleteEntriesForPlant(plantId), failures);

    // Delete diagnosis results
    await _safeDelete('diagnosis', () => _diagnosisHistoryUsecases.deleteResultsForPlant(plantId), failures);

    // Delete care schedule completions, custom rules, and actions
    await _safeDelete('completions', () => _careScheduleUsecases.deleteCompletionsForPlant(plantId), failures);
    await _safeDelete('custom rules', () => _careScheduleUsecases.deleteCustomRulesForPlant(plantId), failures);
    await _safeDelete(
      'schedule actions',
      () => _careScheduleUsecases.deleteAllScheduleActionsForPlant(plantId),
      failures,
    );

    // Delete metric definitions and measurements
    if (_metricUsecases != null) {
      await _safeDelete('metrics', () => _metricUsecases.deleteAllForPlant(plantId), failures);
    }

    if (failures.isNotEmpty) {
      throw StateError('Plant data cleanup failed for: ${failures.join(', ')}');
    }
  }

  /// Runs a delete operation so later stores can still be attempted.
  Future<void> _safeDelete(String name, Future<void> Function() operation, List<String> failures) async {
    try {
      await operation();
    } catch (e) {
      debugPrint('Failed to delete $name for plant: $e');
      failures.add(name);
    }
  }
}
