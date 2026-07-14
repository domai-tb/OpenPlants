import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/pages/care_schedule/care_schedule_datasource.dart';
import 'package:open_plants/pages/care_schedule/care_task_type.dart';
import 'package:open_plants/pages/care_schedule/custom_care_rule.dart';
import 'package:open_plants/pages/care_schedule/task_completion.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_datasource.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_datasource.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_datasource.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_item_entity.dart';

void main() {
  group('Plant deletion cascade — datasource deleteForPlant', () {
    late PlantJournalDataSource journal;
    late SymptomLoggerDataSource symptom;
    late DiagnosisDataSource diagnosis;
    late CareScheduleDataSource careSchedule;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      journal = PlantJournalDataSource(prefs: prefs);
      symptom = SymptomLoggerDataSource(prefs: prefs);
      diagnosis = DiagnosisDataSource(prefs: prefs);
      careSchedule = CareScheduleDataSource(prefs: prefs);
    });

    group('PlantJournalDataSource', () {
      test('deleteForPlant removes all entries for plant', () async {
        await journal.save(
          JournalEntry(
            id: 'j1',
            plantId: 'plant-1',
            type: JournalEntryType.text,
            timestamp: DateTime(2025),
            notes: 'Note 1',
          ),
        );
        await journal.save(
          JournalEntry(
            id: 'j2',
            plantId: 'plant-2',
            type: JournalEntryType.text,
            timestamp: DateTime(2025),
            notes: 'Note 2',
          ),
        );
        await journal.save(
          JournalEntry(
            id: 'j3',
            plantId: 'plant-1',
            type: JournalEntryType.photo,
            timestamp: DateTime(2025),
            photoPath: '/tmp/photo.jpg',
          ),
        );

        await journal.deleteForPlant('plant-1');

        final remaining = await journal.loadAll();
        expect(remaining.length, 1);
        expect(remaining.first.id, 'j2');
      });

      test('deleteForPlant is idempotent for missing plant', () async {
        await journal.deleteForPlant('nonexistent-plant');
        final all = await journal.loadAll();
        expect(all, isEmpty);
      });
    });

    group('SymptomLoggerDataSource', () {
      test('deleteForPlant removes all entries for plant', () async {
        await symptom.save(
          SymptomLogEntry(
            id: 's1',
            plantId: 'plant-1',
            symptomTypes: const [],
            severity: Severity.mild,
            affectedParts: const [],
            onsetTiming: OnsetTiming.today,
            createdAt: DateTime(2025),
          ),
        );
        await symptom.save(
          SymptomLogEntry(
            id: 's2',
            plantId: 'plant-2',
            symptomTypes: const [],
            severity: Severity.moderate,
            affectedParts: const [],
            onsetTiming: OnsetTiming.fewDaysAgo,
            createdAt: DateTime(2025),
          ),
        );

        await symptom.deleteForPlant('plant-1');

        final remaining = await symptom.loadAllEntries();
        expect(remaining.length, 1);
        expect(remaining.first.id, 's2');
      });

      test('deleteForPlant also clears draft', () async {
        await symptom.saveDraft('plant-1', {'note': 'test'});

        await symptom.deleteForPlant('plant-1');

        final draft = await symptom.getDraft('plant-1');
        expect(draft, isNull);
      });

      test('deleteForPlant is idempotent for missing plant', () async {
        await symptom.deleteForPlant('nonexistent-plant');
        final all = await symptom.loadAllEntries();
        expect(all, isEmpty);
      });
    });

    group('DiagnosisDataSource', () {
      test('deleteForPlant removes all results for plant', () async {
        await diagnosis.save(
          DiagnosisResultEntity(
            id: 'd1',
            plantId: 'plant-1',
            plantSymptoms: const [],
            causes: const [],
            type: DiagnosisResultType.rankedCauses,
            context: const DiagnosisContext(symptoms: []),
            createdAt: DateTime(2025),
          ),
        );
        await diagnosis.save(
          DiagnosisResultEntity(
            id: 'd2',
            plantId: 'plant-2',
            plantSymptoms: const [],
            causes: const [],
            type: DiagnosisResultType.rankedCauses,
            context: const DiagnosisContext(symptoms: []),
            createdAt: DateTime(2025),
          ),
        );

        await diagnosis.deleteForPlant('plant-1');

        final remaining = await diagnosis.getAll();
        expect(remaining.length, 1);
        expect(remaining.first.id, 'd2');
      });

      test('deleteForPlant is idempotent for missing plant', () async {
        await diagnosis.deleteForPlant('nonexistent-plant');
        final all = await diagnosis.getAll();
        expect(all, isEmpty);
      });
    });

    group('CareScheduleDataSource', () {
      test('deleteCompletionsForPlant removes completions for plant', () async {
        await careSchedule.saveCompletions([
          TaskCompletion(
            taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
            plantId: 'plant-1',
            completedAt: DateTime(2025),
          ),
          TaskCompletion(
            taskType: const CareTaskType.builtIn(BuiltInTaskType.fertilizing),
            plantId: 'plant-2',
            completedAt: DateTime(2025),
          ),
        ]);

        await careSchedule.deleteCompletionsForPlant('plant-1');

        final remaining = await careSchedule.loadCompletions();
        expect(remaining.length, 1);
        expect(remaining.first.plantId, 'plant-2');
      });

      test('deleteCompletionsForPlant is idempotent', () async {
        await careSchedule.deleteCompletionsForPlant('nonexistent-plant');
        final all = await careSchedule.loadCompletions();
        expect(all, isEmpty);
      });

      test('deleteCustomRulesForPlant removes rules for plant', () async {
        await careSchedule.saveCustomCareRules([
          CustomCareRuleEntity(
            id: 'rule-1',
            plantId: 'plant-1',
            taskType: 'watering',
            intervalDays: 7,
            createdAt: DateTime(2025),
          ),
          CustomCareRuleEntity(
            id: 'rule-2',
            plantId: 'plant-2',
            taskType: 'fertilizing',
            intervalDays: 14,
            createdAt: DateTime(2025),
          ),
        ]);

        await careSchedule.deleteCustomRulesForPlant('plant-1');

        final remaining = await careSchedule.loadCustomCareRules();
        expect(remaining.length, 1);
        expect(remaining.first.plantId, 'plant-2');
      });

      test('deleteCustomRulesForPlant is idempotent', () async {
        await careSchedule.deleteCustomRulesForPlant('nonexistent-plant');
        final all = await careSchedule.loadCustomCareRules();
        expect(all, isEmpty);
      });
    });
  });
}
