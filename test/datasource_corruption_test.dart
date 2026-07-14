import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/exceptions.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_datasource.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_datasource.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_datasource.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_item_entity.dart';

void main() {
  group('DiagnosisDataSource corruption tests', () {
    late DiagnosisDataSource dataSource;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      dataSource = DiagnosisDataSource(prefs: prefs);
    });

    DiagnosisResultEntity makeEntity({String id = 'test-id', String plantId = 'plant-1'}) {
      return DiagnosisResultEntity(
        id: id,
        plantId: plantId,
        plantSymptoms: const [PlantSymptom.yellowingLeaves],
        causes: const [
          ScoredCause(
            causeId: 'overwatering',
            confidence: ConfidenceLevel.high,
            evidence: 'Yellowing leaves.',
            recommendedActions: ['Water less.'],
            followUpChecks: ['Check roots.'],
            score: 0.8,
          ),
        ],
        type: DiagnosisResultType.rankedCauses,
        context: const DiagnosisContext(symptoms: [PlantSymptom.yellowingLeaves]),
        createdAt: DateTime(2026, 1, 15),
      );
    }

    test('throws on malformed JSON', () async {
      await prefs.setString('diagnosis_results_v1', 'not valid json');
      expect(() => dataSource.getAll(), throwsA(isA<CollectionDecodeFailure>()));
    });

    test('throws on wrong top-level shape', () async {
      await prefs.setString('diagnosis_results_v1', jsonEncode({'not': 'a list'}));
      expect(() => dataSource.getAll(), throwsA(isA<CollectionShapeFailure>()));
    });

    test('throws on invalid record', () async {
      await prefs.setString(
        'diagnosis_results_v1',
        jsonEncode([
          {'id': 'invalid'},
        ]),
      );
      expect(() => dataSource.getAll(), throwsA(isA<RecordDecodeFailure>()));
    });

    test('save blocks after corruption', () async {
      await prefs.setString('diagnosis_results_v1', 'corrupted');
      expect(() => dataSource.getAll(), throwsA(isA<CollectionDecodeFailure>()));
      expect(
        () => dataSource.save(makeEntity()),
        throwsA(isA<BlockedAfterDecodeFailure>()),
      );
      expect(prefs.getString('diagnosis_results_v1'), equals('corrupted'));
    });

    test('delete blocks after corruption', () async {
      await prefs.setString('diagnosis_results_v1', 'corrupted');
      expect(() => dataSource.getAll(), throwsA(isA<CollectionDecodeFailure>()));
      expect(
        () => dataSource.delete('some-id'),
        throwsA(isA<BlockedAfterDecodeFailure>()),
      );
    });
  });

  group('SymptomLoggerDataSource corruption tests', () {
    late SymptomLoggerDataSource dataSource;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      dataSource = SymptomLoggerDataSource(prefs: prefs);
    });

    SymptomLogEntry makeEntry({String id = 'test-id', String plantId = 'plant-1'}) {
      return SymptomLogEntry(
        id: id,
        plantId: plantId,
        symptomTypes: const [PlantSymptom.yellowingLeaves],
        severity: Severity.mild,
        affectedParts: const [AffectedPart.leaves],
        onsetTiming: OnsetTiming.today,
        notes: 'Test symptom',
        createdAt: DateTime(2026, 1, 15),
      );
    }

    test('throws on malformed JSON', () async {
      await prefs.setString('symptom_logs_v1', 'not valid json');
      expect(() => dataSource.getAllByPlant('plant-1'), throwsA(isA<CollectionDecodeFailure>()));
    });

    test('throws on wrong top-level shape', () async {
      await prefs.setString('symptom_logs_v1', jsonEncode({'not': 'a list'}));
      expect(() => dataSource.getAllByPlant('plant-1'), throwsA(isA<CollectionShapeFailure>()));
    });

    test('throws on invalid record', () async {
      await prefs.setString(
        'symptom_logs_v1',
        jsonEncode([
          {'id': 'invalid'},
        ]),
      );
      expect(() => dataSource.getAllByPlant('plant-1'), throwsA(isA<RecordDecodeFailure>()));
    });

    test('save blocks after corruption', () async {
      await prefs.setString('symptom_logs_v1', 'corrupted');
      expect(() => dataSource.getAllByPlant('plant-1'), throwsA(isA<CollectionDecodeFailure>()));
      expect(
        () => dataSource.save(makeEntry()),
        throwsA(isA<BlockedAfterDecodeFailure>()),
      );
      expect(prefs.getString('symptom_logs_v1'), equals('corrupted'));
    });

    test('draft operations still work after symptom log corruption', () async {
      await prefs.setString('symptom_logs_v1', 'corrupted');
      expect(() => dataSource.getAllByPlant('plant-1'), throwsA(isA<CollectionDecodeFailure>()));

      // Draft operations should still work since they use a different key
      await dataSource.saveDraft('plant-1', {'type': 'yellowing'});
      final draft = await dataSource.getDraft('plant-1');
      expect(draft, equals({'type': 'yellowing'}));
    });
  });

  group('PlantJournalDataSource corruption tests', () {
    late PlantJournalDataSource dataSource;
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      dataSource = PlantJournalDataSource(prefs: prefs);
    });

    JournalEntry makeEntry({String id = 'test-id', String plantId = 'plant-1'}) {
      return JournalEntry(
        id: id,
        plantId: plantId,
        type: JournalEntryType.text,
        timestamp: DateTime(2026, 1, 15),
        notes: 'Test journal entry',
      );
    }

    test('throws on malformed JSON', () async {
      await prefs.setString('plant_journal_v1', 'not valid json');
      expect(() => dataSource.loadAll(), throwsA(isA<CollectionDecodeFailure>()));
    });

    test('throws on wrong top-level shape', () async {
      await prefs.setString('plant_journal_v1', jsonEncode({'not': 'a list'}));
      expect(() => dataSource.loadAll(), throwsA(isA<CollectionShapeFailure>()));
    });

    test('throws on invalid record', () async {
      await prefs.setString(
        'plant_journal_v1',
        jsonEncode([
          {'id': 'invalid'},
        ]),
      );
      expect(() => dataSource.loadAll(), throwsA(isA<RecordDecodeFailure>()));
    });

    test('save blocks after corruption', () async {
      await prefs.setString('plant_journal_v1', 'corrupted');
      expect(() => dataSource.loadAll(), throwsA(isA<CollectionDecodeFailure>()));
      expect(
        () => dataSource.save(makeEntry()),
        throwsA(isA<BlockedAfterDecodeFailure>()),
      );
      expect(prefs.getString('plant_journal_v1'), equals('corrupted'));
    });

    test('delete blocks after corruption', () async {
      await prefs.setString('plant_journal_v1', 'corrupted');
      expect(() => dataSource.loadAll(), throwsA(isA<CollectionDecodeFailure>()));
      expect(
        () => dataSource.delete('some-id'),
        throwsA(isA<BlockedAfterDecodeFailure>()),
      );
    });
  });
}
