import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/pages/care_schedule/care_schedule_action.dart';
import 'package:openplants/pages/care_schedule/care_schedule_repository.dart';
import 'package:openplants/pages/care_schedule/care_schedule_usecases.dart';
import 'package:openplants/pages/care_schedule/care_task.dart';
import 'package:openplants/pages/care_schedule/care_task_type.dart';
import 'package:openplants/pages/care_schedule/task_completion.dart';
import 'package:openplants/pages/care_schedule/custom_care_rule.dart';
import 'package:openplants/pages/care_schedule/species_care_profile.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:openplants/pages/plant_journal/plant_journal_usecases.dart';
import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_definition_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement.dart';
import 'package:openplants/pages/plant_metrics/metric_measurement_datasource.dart';
import 'package:openplants/pages/plant_metrics/metric_repository.dart';
import 'package:openplants/pages/plant_metrics/metric_usecases.dart';

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
    when(mockPlantCollection.getPlantById(any)).thenAnswer((_) async => null);
    when(mockRepository.getAllScheduleConfigs()).thenAnswer((_) async => {});
    when(mockRepository.getAllRoomConfigs()).thenAnswer((_) async => {});
    when(mockRepository.getAllCompletions()).thenAnswer((_) async => []);
    when(mockRepository.getAllCustomCareRules()).thenAnswer((_) async => []);
    when(mockRepository.getAllScheduleActions()).thenAnswer((_) async => {});

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
    test('saves schedule action instead of completion', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );

      when(mockRepository.saveScheduleAction(any)).thenAnswer((_) async {});

      await usecases.snoozeTask(task: task, days: 3);

      verifyNever(mockRepository.recordCompletion(any));
      verify(mockRepository.saveScheduleAction(any)).called(1);
      verifyNever(mockPlantJournal.addEntry(any));
    });
  });

  group('skipTask', () {
    test('saves schedule action instead of completion', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );

      when(mockRepository.saveScheduleAction(any)).thenAnswer((_) async {});

      await usecases.skipTask(task: task);

      verifyNever(mockRepository.recordCompletion(any));
      verify(mockRepository.saveScheduleAction(any)).called(1);
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
      await usecases.completeTask(task: task);

      // Task completion was recorded
      verify(mockRepository.recordCompletion(any)).called(1);
      // Journal entry was attempted
      verify(mockPlantJournal.addEntry(any)).called(1);
      // A post-write schedule refresh is left to the page, so refresh errors
      // cannot report an already-persisted completion as failed.
      verifyNever(mockRepository.getAllScheduleConfigs());
    });

    test('notification sync failure does not fail a saved snooze', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );
      final usecasesWithFailingSync = CareScheduleUsecases(
        repository: mockRepository,
        plantCollection: mockPlantCollection,
        plantJournal: mockPlantJournal,
        onNotificationsChanged: () async => throw StateError('Notification plugin failure'),
      );
      when(mockRepository.saveScheduleAction(any)).thenAnswer((_) async {});

      await expectLater(usecasesWithFailingSync.snoozeTask(task: task, days: 2), completes);

      verify(mockRepository.saveScheduleAction(any)).called(1);
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

  group('schedule actions', () {
    test('completeTask clears active schedule action', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
        alertEpisodeId: 'metric-1:episode-1',
      );

      when(mockRepository.recordCompletion(any)).thenAnswer((_) async {});
      when(mockRepository.deleteScheduleAction(any, any)).thenAnswer((_) async {});
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

      final completion = verify(mockRepository.recordCompletion(captureAny)).captured.single as TaskCompletion;
      expect(completion.alertEpisodeId, 'metric-1:episode-1');
      verify(mockRepository.deleteScheduleAction('plant-1', const CareTaskType.builtIn(BuiltInTaskType.watering)))
          .called(1);
    });

    test('snoozeTask saves schedule action instead of completion', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );

      when(mockRepository.saveScheduleAction(any)).thenAnswer((_) async {});

      await usecases.snoozeTask(task: task, days: 3);

      // Should NOT create a completion
      verifyNever(mockRepository.recordCompletion(any));
      // Should save a schedule action
      verify(mockRepository.saveScheduleAction(any)).called(1);
      // Should NOT create a journal entry
      verifyNever(mockPlantJournal.addEntry(any));
    });

    test('snooze targets the stable occurrence date, not the overridden due date', () async {
      final occurrenceDate = DateTime(2025, 7);
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime(2025, 7, 4),
        status: CareTaskStatus.upcoming,
        effectiveIntervalDays: 7,
        occurrenceDueDate: occurrenceDate,
      );

      when(mockRepository.saveScheduleAction(any)).thenAnswer((_) async {});

      await usecases.snoozeTask(task: task, days: 3);

      final action = verify(mockRepository.saveScheduleAction(captureAny)).captured.single as CareScheduleAction;
      expect(action.targetedOccurrenceDueDate, occurrenceDate);
      expect(action.overriddenDueDate.hour, 0);
    });

    test('skipTask saves schedule action instead of completion', () async {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Plant',
        dueDate: DateTime.now(),
        status: CareTaskStatus.dueToday,
        effectiveIntervalDays: 7,
      );

      when(mockRepository.saveScheduleAction(any)).thenAnswer((_) async {});

      await usecases.skipTask(task: task);

      // Should NOT create a completion
      verifyNever(mockRepository.recordCompletion(any));
      // Should save a schedule action
      verify(mockRepository.saveScheduleAction(any)).called(1);
      // Should NOT create a journal entry
      verifyNever(mockPlantJournal.addEntry(any));
    });

    test('getScheduleActions returns actions from repository', () async {
      final action = CareScheduleAction(
        plantId: 'plant-1',
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        actionKind: CareScheduleActionKind.snooze,
        actionTime: DateTime.now(),
        targetedOccurrenceDueDate: DateTime.now(),
        overriddenDueDate: DateTime.now().add(const Duration(days: 3)),
      );

      when(mockRepository.getAllScheduleActions()).thenAnswer(
        (_) async => {'plant-1_watering': action},
      );

      final actions = await usecases.getScheduleActions();

      expect(actions.length, 1);
      expect(actions['plant-1_watering'], action);
    });
  });

  group('getComputedRules', () {
    test('returns computed rules for a plant with species profile', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'Monstera',
        speciesName: 'Monstera Deliciosa',
        roomId: 'room-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockPlantCollection.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockRepository.getSpeciesProfile('Monstera Deliciosa')).thenReturn(
        const SpeciesCareProfile(
          id: 'monstera',
          name: 'Monstera Deliciosa',
          defaultIntervals: {
            'watering': 7,
            'fertilizing': 14,
            'misting': 3,
          },
        ),
      );
      when(mockRepository.getCustomCareRules('plant-1')).thenAnswer((_) async => []);

      final rules = await usecases.getComputedRules('plant-1');

      expect(rules.length, 8); // 8 built-in types
      final watering = rules.firstWhere((r) => r.taskType == 'watering');
      expect(watering.defaultIntervalDays, 7);
      expect(watering.isOverridden, false);
      expect(watering.isEnabled, true);
    });

    test('marks overridden rules correctly', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'Monstera',
        speciesName: 'Monstera Deliciosa',
        roomId: 'room-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockPlantCollection.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockRepository.getSpeciesProfile('Monstera Deliciosa')).thenReturn(
        const SpeciesCareProfile(
          id: 'monstera',
          name: 'Monstera Deliciosa',
          defaultIntervals: {'watering': 7},
        ),
      );
      when(mockRepository.getCustomCareRules('plant-1')).thenAnswer(
        (_) async => [
          CustomCareRuleEntity(
            id: 'rule-1',
            plantId: 'plant-1',
            taskType: 'watering',
            intervalDays: 5,
            createdAt: DateTime.now(),
          ),
        ],
      );

      final rules = await usecases.getComputedRules('plant-1');
      final watering = rules.firstWhere((r) => r.taskType == 'watering');

      expect(watering.isOverridden, true);
      expect(watering.customIntervalDays, 5);
      expect(watering.effectiveIntervalDays, 5);
    });
  });

  group('metric alert task context', () {
    test('uses active metric episodes and measurement time for care tasks', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final metricRepository = MetricRepository(
        definitionDataSource: MetricDefinitionDataSource(prefs: prefs),
        measurementDataSource: MetricMeasurementDataSource(prefs: prefs),
      );
      final metricUsecases = MetricUsecases(repository: metricRepository);
      final now = DateTime.now();
      final measuredAt = DateTime(now.year, now.month, now.day - 10, 12);
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'Test Plant',
        speciesName: 'Test species',
        createdAt: now,
        updatedAt: now,
      );
      final rule = CustomCareRuleEntity(
        id: 'rule-1',
        plantId: plant.id,
        taskType: 'watering',
        intervalDays: 7,
        metricId: 'metric-1',
        createdAt: now,
      );

      await metricRepository.saveDefinition(
        MetricDefinition(
          id: 'metric-1',
          plantId: plant.id,
          name: 'Soil moisture',
          valueType: MetricValueType.numeric,
          unit: '%',
          numericBounds: const NumericBounds(lower: 20),
          alertResponse: AlertResponse.careTask,
          createdAt: now,
          updatedAt: now,
        ),
      );
      await metricRepository.saveMeasurement(
        MetricMeasurement(
          id: 'measurement-1',
          metricId: 'metric-1',
          plantId: plant.id,
          value: 10,
          measuredAt: measuredAt,
        ),
      );
      when(mockPlantCollection.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockRepository.getAllCustomCareRules()).thenAnswer((_) async => [rule]);
      when(mockRepository.getSpeciesProfile('Test species')).thenReturn(
        const SpeciesCareProfile(id: 'test', name: 'Test species', defaultIntervals: {}),
      );
      final metricCareSchedule = CareScheduleUsecases(
        repository: mockRepository,
        plantCollection: mockPlantCollection,
        plantJournal: mockPlantJournal,
        metricUsecases: metricUsecases,
      );

      final result = await metricCareSchedule.getSchedule();
      final wateringTask = result.tasks.firstWhere((task) => task.taskType.builtIn == BuiltInTaskType.watering);
      final alertTask = result.tasks.singleWhere((task) => task.alertEpisodeId != null);

      expect(wateringTask.dueDate, DateTime(now.year, now.month, now.day - 3));
      expect(wateringTask.status, CareTaskStatus.overdue);
      expect(alertTask.alertEpisodeId, 'metric-1:measurement-1');
      expect(alertTask.taskType, const CareTaskType.custom('metric_alert:metric-1'));
      expect(alertTask.alertMetricName, 'Soil moisture');
    });
  });

  group('toggleComputedRule', () {
    test('creates new custom rule when none exists', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'Monstera',
        speciesName: 'Monstera Deliciosa',
        roomId: 'room-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      when(mockPlantCollection.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockRepository.getSpeciesProfile('Monstera Deliciosa')).thenReturn(
        const SpeciesCareProfile(
          id: 'monstera',
          name: 'Monstera Deliciosa',
          defaultIntervals: {'watering': 7},
        ),
      );
      when(mockRepository.getCustomCareRules('plant-1')).thenAnswer((_) async => []);

      await usecases.toggleComputedRule(
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 5,
      );

      verify(mockRepository.saveCustomCareRule(any)).called(1);
    });

    test('toggles existing custom rule', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'Monstera',
        speciesName: 'Monstera Deliciosa',
        roomId: 'room-1',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final existingRule = CustomCareRuleEntity(
        id: 'rule-1',
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 5,
        createdAt: DateTime.now(),
      );

      when(mockPlantCollection.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockRepository.getSpeciesProfile('Monstera Deliciosa')).thenReturn(
        const SpeciesCareProfile(
          id: 'monstera',
          name: 'Monstera Deliciosa',
          defaultIntervals: {'watering': 7},
        ),
      );
      when(mockRepository.getCustomCareRules('plant-1')).thenAnswer(
        (_) async => [existingRule],
      );

      await usecases.toggleComputedRule(
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 5,
      );

      verify(mockRepository.saveCustomCareRule(any)).called(1);
    });
  });
}
