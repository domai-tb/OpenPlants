import 'package:flutter/foundation.dart';

import 'package:open_plants/pages/care_schedule/care_schedule_action.dart';
import 'package:open_plants/pages/care_schedule/care_task.dart';
import 'package:open_plants/pages/care_schedule/care_task_type.dart';
import 'package:open_plants/pages/care_schedule/overdue_detector.dart';
import 'package:open_plants/pages/care_schedule/room_config.dart';
import 'package:open_plants/pages/care_schedule/schedule_config.dart';
import 'package:open_plants/pages/care_schedule/schedule_engine.dart';
import 'package:open_plants/pages/care_schedule/care_schedule_repository.dart';
import 'package:open_plants/pages/care_schedule/task_completion.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_usecases.dart';
import 'package:open_plants/pages/room_profiles/room_profiles_entity.dart';
import 'package:open_plants/pages/room_profiles/room_profiles_usecases.dart';

/// Use cases for the care schedule feature.
class CareScheduleUsecases {
  final CareScheduleRepository repository;
  final PlantCollectionUsecases plantCollection;
  final PlantJournalUseCases plantJournal;
  final RoomProfilesUsecases? roomProfiles;

  const CareScheduleUsecases({
    required this.repository,
    required this.plantCollection,
    required this.plantJournal,
    this.roomProfiles,
  });

  /// Get the full schedule for all plants, sorted by urgency.
  ///
  /// Returns a record with the tasks, a map of plantId to room context,
  /// and a list of tasks completed early within the grace window.
  Future<
      ({
        List<CareTask> tasks,
        List<CareTask> completedEarly,
        Map<String, ({String name, String environment})> roomContext,
      })> getSchedule() async {
    final plants = await plantCollection.loadPlants();
    final allConfigs = await repository.getAllScheduleConfigs();
    final allRoomConfigs = await repository.getAllRoomConfigs();
    final completions = await repository.getAllCompletions();
    final allCustomRules = await repository.getAllCustomCareRules();
    final today = DateTime.now();

    // Load room entities if available
    final roomEntities = <String, RoomEntity>{};
    if (roomProfiles != null) {
      final rooms = await roomProfiles!.getAll();
      for (final room in rooms) {
        roomEntities[room.id] = room;
      }
    }

    // Build plant-to-room mapping for UI
    final plantRoomMap = <String, String?>{};
    for (final plant in plants) {
      plantRoomMap[plant.id] = plant.roomId;
    }

    final allScheduleActions = await repository.getAllScheduleActions();

    final inputs = plants.map((plant) {
      final config = allConfigs[plant.id] ?? ScheduleConfig.defaults();
      final roomConfig = plant.room != null ? allRoomConfigs[plant.room!] : null;
      final roomEntity = plant.roomId != null ? roomEntities[plant.roomId] : null;
      final profile = repository.getSpeciesProfile(plant.speciesName);
      final plantRules = allCustomRules.where((r) => r.plantId == plant.id).toList();
      final plantActions =
          allScheduleActions.entries.where((e) => e.key.startsWith('${plant.id}_')).map((e) => e.value).toList();

      return PlantScheduleInput(
        plantId: plant.id,
        plantName: plant.name,
        config: config,
        roomConfig: roomConfig,
        roomEntity: roomEntity,
        profile: profile,
        completionHistory: completions,
        customCareRules: plantRules,
        activeScheduleActions: plantActions,
        lightLevel: plant.lightLevel,
      );
    }).toList();

    // Build room context map for tasks
    final taskRoomContext = <String, ({String name, String environment})>{};
    for (final plant in plants) {
      final roomId = plant.roomId;
      if (roomId != null && roomEntities.containsKey(roomId)) {
        final room = roomEntities[roomId]!;
        taskRoomContext[plant.id] = (
          name: room.name,
          environment: '${room.lightLevel.label}, ${room.humidityLevel.label}',
        );
      }
    }

    var tasks = ScheduleEngine.computeUnified(inputs: inputs, today: today);

    // Apply grace-window detection: upgrade `upcoming` tasks that were
    // completed today (within the grace window) to `justCompleted`
    tasks = tasks.map((task) {
      if (task.status != CareTaskStatus.upcoming) return task;
      final inGrace = GraceWindowDetector.isWithinGraceWindow(
        completedAt: task.completedAt,
        today: today,
        effectiveIntervalDays: task.effectiveIntervalDays,
      );
      if (!inGrace) return task;
      return CareTask(
        taskType: task.taskType,
        plantId: task.plantId,
        plantName: task.plantName,
        dueDate: task.dueDate,
        status: CareTaskStatus.justCompleted,
        effectiveIntervalDays: task.effectiveIntervalDays,
        completedAt: task.completedAt,
      );
    }).toList();

    final completedEarly = tasks.where((t) => t.status == CareTaskStatus.justCompleted).toList();

    return (tasks: tasks, completedEarly: completedEarly, roomContext: taskRoomContext);
  }

  /// Complete a task — records the completion event and auto-journals it.
  ///
  /// Clears any active schedule action for this plant/task pair.
  Future<List<CareTask>> completeTask({
    required CareTask task,
    String? note,
  }) async {
    final completion = TaskCompletion(
      taskType: task.taskType,
      plantId: task.plantId,
      completedAt: DateTime.now(),
      note: note,
    );

    await repository.recordCompletion(completion);

    // Clear any active schedule action for this plant/task pair
    await repository.deleteScheduleAction(task.plantId, task.taskType);

    // Auto-journal the completed task (graceful degradation on failure)
    try {
      final notes = _buildJournalNotes(task.taskType.label, note);
      final entry = JournalEntry(
        id: '',
        plantId: task.plantId,
        type: JournalEntryType.task,
        timestamp: completion.completedAt,
        notes: notes,
      );
      await plantJournal.addEntry(entry);
    } catch (e) {
      debugPrint('Failed to auto-journal care task completion: $e');
    }

    // Update plant care status for watering/fertilizing tasks (graceful degradation)
    try {
      final plant = await plantCollection.getPlantById(task.plantId);
      if (plant != null) {
        if (task.taskType.builtIn == BuiltInTaskType.watering) {
          await plantCollection.markAsWatered(plant);
        } else if (task.taskType.builtIn == BuiltInTaskType.fertilizing) {
          await plantCollection.markAsFertilized(plant);
        }
      }
    } catch (e) {
      debugPrint('Failed to update plant care status on task completion: $e');
    }

    return (await getSchedule()).tasks;
  }

  /// Build the journal entry notes from task type label and optional user note.
  String _buildJournalNotes(String taskTypeLabel, String? userNote) {
    if (userNote != null && userNote.isNotEmpty) {
      return '$taskTypeLabel completed — $userNote';
    }
    return '$taskTypeLabel completed';
  }

  /// Snooze a task by deferring it for [days] days.
  ///
  /// Saves a schedule action instead of recording a completion.
  /// The action overrides the due date without creating a genuine completion.
  Future<List<CareTask>> snoozeTask({
    required CareTask task,
    required int days,
  }) async {
    final now = DateTime.now();
    final action = CareScheduleAction(
      plantId: task.plantId,
      taskType: task.taskType,
      actionKind: CareScheduleActionKind.snooze,
      actionTime: now,
      targetedOccurrenceDueDate: task.dueDate,
      overriddenDueDate: now.add(Duration(days: days)),
    );

    await repository.saveScheduleAction(action);
    return (await getSchedule()).tasks;
  }

  /// Skip a task — advances the due date by one effective interval.
  ///
  /// Saves a schedule action instead of recording a completion.
  /// The action advances the due date without creating a genuine completion.
  Future<List<CareTask>> skipTask({required CareTask task}) async {
    final now = DateTime.now();
    final action = CareScheduleAction(
      plantId: task.plantId,
      taskType: task.taskType,
      actionKind: CareScheduleActionKind.skip,
      actionTime: now,
      targetedOccurrenceDueDate: task.dueDate,
      overriddenDueDate: task.dueDate.add(Duration(days: task.effectiveIntervalDays)),
    );

    await repository.saveScheduleAction(action);
    return (await getSchedule()).tasks;
  }

  /// Update the schedule config for a specific plant.
  Future<List<CareTask>> updateScheduleConfig({
    required String plantId,
    required ScheduleConfig config,
  }) async {
    await repository.saveScheduleConfig(plantId, config);
    return (await getSchedule()).tasks;
  }

  /// Update or create a room config.
  Future<List<CareTask>> updateRoomConfig({required RoomConfig config}) async {
    await repository.saveRoomConfig(config);
    return (await getSchedule()).tasks;
  }

  /// Get task history for a specific plant.
  Future<List<TaskCompletion>> getTaskHistory(String plantId) async {
    return repository.getCompletionsForPlant(plantId);
  }

  /// Get task history filtered by plant and task type.
  Future<List<TaskCompletion>> getTaskHistoryFiltered({
    required String plantId,
    String? taskTypeKey,
  }) async {
    if (taskTypeKey != null) {
      return repository.getCompletionsForPlantAndType(plantId, taskTypeKey);
    }
    return repository.getCompletionsForPlant(plantId);
  }

  /// Delete a specific completion event.
  Future<List<CareTask>> deleteCompletion({
    required TaskCompletion completion,
  }) async {
    await repository.deleteCompletion(completion);
    return (await getSchedule()).tasks;
  }

  /// Get all active schedule actions.
  Future<Map<String, CareScheduleAction>> getScheduleActions() async {
    return repository.getAllScheduleActions();
  }

  /// Delete all task completions for a specific plant.
  Future<void> deleteCompletionsForPlant(String plantId) async {
    await repository.deleteCompletionsForPlant(plantId);
  }

  /// Delete all custom care rules for a specific plant.
  Future<void> deleteCustomRulesForPlant(String plantId) async {
    await repository.deleteCustomRulesForPlant(plantId);
  }

  /// Delete all schedule actions for a specific plant.
  Future<void> deleteAllScheduleActionsForPlant(String plantId) async {
    await repository.deleteAllScheduleActionsForPlant(plantId);
  }
}
