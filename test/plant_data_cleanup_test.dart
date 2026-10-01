import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:openplants/pages/care_schedule/care_schedule_usecases.dart';
import 'package:openplants/pages/diagnosis/diagnosis_history_usecases.dart';
import 'package:openplants/pages/plant_collection/plant_data_cleanup.dart';
import 'package:openplants/pages/plant_journal/plant_journal_usecases.dart';
import 'package:openplants/pages/plant_metrics/metric_usecases.dart';
import 'package:openplants/pages/plant_photo_timeline/plant_photo_timeline_usecases.dart';
import 'package:openplants/pages/symptom_logger/symptom_logger_usecases.dart';

@GenerateMocks([
  PlantJournalUseCases,
  SymptomLoggerUseCases,
  DiagnosisHistoryUseCases,
  PlantPhotoTimelineUseCases,
  CareScheduleUsecases,
])
import 'plant_data_cleanup_test.mocks.dart';

void main() {
  group('PlantDataCleanup', () {
    late MockPlantJournalUseCases mockJournal;
    late MockSymptomLoggerUseCases mockSymptom;
    late MockDiagnosisHistoryUseCases mockDiagnosis;
    late MockPlantPhotoTimelineUseCases mockPhotoTimeline;
    late MockCareScheduleUsecases mockCareSchedule;
    late _RecordingMetricUsecases metrics;
    late PlantDataCleanup cleanup;
    var failJournal = false;

    setUp(() {
      mockJournal = MockPlantJournalUseCases();
      mockSymptom = MockSymptomLoggerUseCases();
      mockDiagnosis = MockDiagnosisHistoryUseCases();
      mockPhotoTimeline = MockPlantPhotoTimelineUseCases();
      mockCareSchedule = MockCareScheduleUsecases();
      metrics = _RecordingMetricUsecases();

      cleanup = PlantDataCleanup(
        journalUsecases: mockJournal,
        symptomUsecases: mockSymptom,
        diagnosisHistoryUsecases: mockDiagnosis,
        photoTimelineUsecases: mockPhotoTimeline,
        careScheduleUsecases: mockCareSchedule,
        metricUsecases: metrics,
      );

      // Set up default behaviors
      when(mockJournal.deleteEntriesForPlant(any)).thenAnswer((_) async {
        if (failJournal) throw Exception('Journal error');
      });
      when(mockSymptom.deleteEntriesForPlant(any)).thenAnswer((_) async {});
      when(mockDiagnosis.deleteResultsForPlant(any)).thenAnswer((_) async {});
      when(mockPhotoTimeline.deleteAllPhotos(any)).thenAnswer((_) async {});
      when(mockCareSchedule.deleteCompletionsForPlant(any)).thenAnswer((_) async {});
      when(mockCareSchedule.deleteCustomRulesForPlant(any)).thenAnswer((_) async {});
      when(mockCareSchedule.deleteAllScheduleActionsForPlant(any)).thenAnswer((_) async {});
    });

    test('deleteAllForPlant calls all data sources', () async {
      await cleanup.deleteAllForPlant('plant-1');

      verify(mockPhotoTimeline.deleteAllPhotos('plant-1')).called(1);
      verify(mockJournal.deleteEntriesForPlant('plant-1')).called(1);
      verify(mockSymptom.deleteEntriesForPlant('plant-1')).called(1);
      verify(mockDiagnosis.deleteResultsForPlant('plant-1')).called(1);
      verify(mockCareSchedule.deleteCompletionsForPlant('plant-1')).called(1);
      verify(mockCareSchedule.deleteCustomRulesForPlant('plant-1')).called(1);
      verify(mockCareSchedule.deleteAllScheduleActionsForPlant('plant-1')).called(1);
      expect(metrics.deletedPlantIds, ['plant-1']);
    });

    test('deleteAllForPlant continues even if one source fails', () async {
      failJournal = true;

      await expectLater(cleanup.deleteAllForPlant('plant-1'), throwsA(isA<StateError>()));

      // Verify other sources were still called
      verify(mockPhotoTimeline.deleteAllPhotos('plant-1')).called(1);
      verify(mockSymptom.deleteEntriesForPlant('plant-1')).called(1);
      verify(mockDiagnosis.deleteResultsForPlant('plant-1')).called(1);
      verify(mockCareSchedule.deleteCompletionsForPlant('plant-1')).called(1);
      verify(mockCareSchedule.deleteCustomRulesForPlant('plant-1')).called(1);
      verify(mockCareSchedule.deleteAllScheduleActionsForPlant('plant-1')).called(1);
      expect(metrics.deletedPlantIds, ['plant-1']);
    });
  });
}

class _RecordingMetricUsecases extends Fake implements MetricUsecases {
  final deletedPlantIds = <String>[];

  @override
  Future<void> deleteAllForPlant(String plantId) async {
    deletedPlantIds.add(plantId);
  }
}
