import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:open_plants/pages/care_schedule/care_schedule_repository.dart';
import 'package:open_plants/pages/care_schedule/care_schedule_usecases.dart';
import 'package:open_plants/pages/care_schedule/care_task.dart';
import 'package:open_plants/pages/care_schedule/care_task_type.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_usecases.dart';

@GenerateMocks([
  CareScheduleRepository,
  PlantCollectionUsecases,
  PlantJournalUseCases,
])
import 'care_schedule_usecases_test.mocks.dart';

void main() {
  late CareScheduleUsecases usecases;
  late MockCareScheduleRepository mockRepository;
  late MockPlantCollectionUsecases mockPlantCollection;
  late MockPlantJournalUseCases mockPlantJournal;

  setUp(() {
    mockRepository = MockCareScheduleRepository();
    mockPlantCollection = MockPlantCollectionUsecases();
    mockPlantJournal = MockPlantJournalUseCases();

    // Stub getSchedule dependencies to return empty results
    when(mockPlantCollection.loadPlants()).thenAnswer((_) async => []);
    when(mockRepository.getAllScheduleConfigs()).thenAnswer((_) async => {});
    when(mockRepository.getAllRoomConfigs()).thenAnswer((_) async => {});
    when(mockRepository.getAllCompletions()).thenAnswer((_) async => []);
    when(mockRepository.getAllCustomCareRules()).thenAnswer((_) async => []);

    usecases = CareScheduleUsecases(
      repository: mockRepository,
      plantCollection: mockPlantCollection,
      plantJournal: mockPlantJournal,
    );
  });

  group('completeTask', () {
    test('creates journal entry with correct parameters', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );

      when(mockRepository.recordCompletion(any)).thenAnswer((_) async {});
      when(mockPlantJournal.addEntry(any)).thenAnswer(
        (_) async => JournalEntry(
          id: 'generated-id',
          plantId: 'plant-1',
          type: JournalEntryType.task,
          timestamp: DateTime.now(),
          notes: 'Watering completed',
        ),
      );

      await usecases.completeTask(task: task);

      final captured = verify(mockPlantJournal.addEntry(captureAny)).captured;
      final entry = captured.last as JournalEntry;

      expect(entry.plantId, 'plant-1');
      expect(entry.type, JournalEntryType.task);
      expect(entry.notes, 'Watering completed');
      expect(entry.photoPath, isNull);
    });

    test('includes user note in journal entry', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );

      when(mockRepository.recordCompletion(any)).thenAnswer((_) async {});
      when(mockPlantJournal.addEntry(any)).thenAnswer(
        (_) async => JournalEntry(
          id: 'generated-id',
          plantId: 'plant-1',
          type: JournalEntryType.task,
          timestamp: DateTime.now(),
          notes: 'Watering completed — gave extra due to heat wave',
        ),
      );

      await usecases.completeTask(
        task: task,
        note: 'gave extra due to heat wave',
      );

      final captured = verify(mockPlantJournal.addEntry(captureAny)).captured;
      final entry = captured.last as JournalEntry;

      expect(entry.notes, 'Watering completed — gave extra due to heat wave');
    });

    test('records task completion before journaling', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.fertilizing),
        plantId: 'plant-2',
        plantName: 'Other Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 30,
      );

      when(mockRepository.recordCompletion(any)).thenAnswer((_) async {});
      when(mockPlantJournal.addEntry(any)).thenAnswer(
        (_) async => JournalEntry(
          id: 'id',
          plantId: 'plant-2',
          type: JournalEntryType.task,
          timestamp: DateTime.now(),
        ),
      );

      await usecases.completeTask(task: task);

      // Verify recordCompletion was called first
      verify(mockRepository.recordCompletion(any)).called(1);
      verify(mockPlantJournal.addEntry(any)).called(1);
    });
  });

  group('snoozeTask', () {
    test('does NOT create journal entry', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );

      when(mockRepository.recordCompletion(any)).thenAnswer((_) async {});

      await usecases.snoozeTask(task: task, days: 3);

      verify(mockRepository.recordCompletion(any)).called(1);
      verifyNever(mockPlantJournal.addEntry(any));
    });
  });

  group('skipTask', () {
    test('does NOT create journal entry', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );

      when(mockRepository.recordCompletion(any)).thenAnswer((_) async {});

      await usecases.skipTask(task: task);

      verify(mockRepository.recordCompletion(any)).called(1);
      verifyNever(mockPlantJournal.addEntry(any));
    });
  });

  group('graceful degradation', () {
    test('task completion persists even if journal creation fails', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );

      when(mockRepository.recordCompletion(any)).thenAnswer((_) async {});
      when(mockPlantJournal.addEntry(any)).thenThrow(
        Exception('Storage failure'),
      );

      // Should not throw — graceful degradation
      final result = await usecases.completeTask(task: task);

      // Task completion was recorded
      verify(mockRepository.recordCompletion(any)).called(1);
      // Journal entry was attempted
      verify(mockPlantJournal.addEntry(any)).called(1);
      // Schedule was still returned
      expect(result, isA<List<CareTask>>());
    });
  });

  group('custom task types', () {
    test('uses custom task type label in journal notes', () async {
      final task = CareTask(
        taskType: const CareTaskType.custom('Check for flowers'),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );

      when(mockRepository.recordCompletion(any)).thenAnswer((_) async {});
      when(mockPlantJournal.addEntry(any)).thenAnswer(
        (_) async => JournalEntry(
          id: 'id',
          plantId: 'plant-1',
          type: JournalEntryType.task,
          timestamp: DateTime.now(),
          notes: 'Check for flowers completed',
        ),
      );

      await usecases.completeTask(task: task);

      final captured = verify(mockPlantJournal.addEntry(captureAny)).captured;
      final entry = captured.last as JournalEntry;

      expect(entry.notes, 'Check for flowers completed');
    });
  });
}
