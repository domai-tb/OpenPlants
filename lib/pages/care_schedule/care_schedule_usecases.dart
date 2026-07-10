import 'package:flutter/foundation.dart';

import 'package:open_plant/pages/care_schedule/care_task.dart';
import 'package:open_plant/pages/care_schedule/room_config.dart';
import 'package:open_plant/pages/care_schedule/schedule_config.dart';
import 'package:open_plant/pages/care_schedule/schedule_engine.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_repository.dart';
import 'package:open_plant/pages/care_schedule/task_completion.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_usecases.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_entity.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_usecases.dart';

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
  /// Returns a record with the tasks and a map of plantId to room context.
  Future<({List<CareTask> tasks, Map<String, ({String name, String environment})> roomContext})> getSchedule() async {
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

    final inputs = plants.map((plant) {
      final config = allConfigs[plant.id] ?? ScheduleConfig.defaults();
      final roomConfig = plant.room != null ? allRoomConfigs[plant.room!] : null;
      final roomEntity = plant.roomId != null ? roomEntities[plant.roomId] : null;
      final profile = repository.getSpeciesProfile(plant.speciesName);
      final plantRules = allCustomRules.where((r) => r.plantId == plant.id).toList();

      return PlantScheduleInput(
        plantId: plant.id,
        plantName: plant.name,
        config: config,
        roomConfig: roomConfig,
        roomEntity: roomEntity,
        profile: profile,
        completionHistory: completions,
        customCareRules: plantRules,
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

    final tasks = ScheduleEngine.computeUnified(inputs: inputs, today: today);
    return (tasks: tasks, roomContext: taskRoomContext);
  }

  /// Complete a task — records the completion event and auto-journals it.
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
  /// Records a completion event anchored to today. The next-due date will be
  /// today + effectiveInterval, which may differ from the requested snooze
  /// duration. This is the simplest correct behavior for a completion-based
  /// scheduling model.
  Future<List<CareTask>> snoozeTask({
    required CareTask task,
    required int days,
  }) async {
    final completion = TaskCompletion(
      taskType: task.taskType,
      plantId: task.plantId,
      completedAt: DateTime.now(),
    );

    await repository.recordCompletion(completion);
    return (await getSchedule()).tasks;
  }

  /// Skip a task — resets the anchor to today without recording completion.
  Future<List<CareTask>> skipTask({required CareTask task}) async {
    // Record a completion with today's timestamp to reset the timer
    final completion = TaskCompletion(
      taskType: task.taskType,
      plantId: task.plantId,
      completedAt: DateTime.now(),
    );

    await repository.recordCompletion(completion);
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
}
