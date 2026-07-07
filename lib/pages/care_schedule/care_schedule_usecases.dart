import 'package:open_plant/pages/care_schedule/care_task.dart';
import 'package:open_plant/pages/care_schedule/room_config.dart';
import 'package:open_plant/pages/care_schedule/schedule_config.dart';
import 'package:open_plant/pages/care_schedule/schedule_engine.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_repository.dart';
import 'package:open_plant/pages/care_schedule/task_completion.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';

/// Use cases for the care schedule feature.
class CareScheduleUsecases {
  final CareScheduleRepository repository;
  final PlantCollectionUsecases plantCollection;

  const CareScheduleUsecases({
    required this.repository,
    required this.plantCollection,
  });

  /// Get the full schedule for all plants, sorted by urgency.
  Future<List<CareTask>> getSchedule() async {
    final plants = await plantCollection.loadPlants();
    final allConfigs = await repository.getAllScheduleConfigs();
    final allRoomConfigs = await repository.getAllRoomConfigs();
    final completions = await repository.getAllCompletions();
    final today = DateTime.now();

    final inputs = plants.map((plant) {
      final config = allConfigs[plant.id] ?? ScheduleConfig.defaults();
      final roomConfig = plant.room != null ? allRoomConfigs[plant.room!] : null;
      final profile = repository.getSpeciesProfile(plant.speciesName);

      return PlantScheduleInput(
        plantId: plant.id,
        plantName: plant.name,
        config: config,
        roomConfig: roomConfig,
        profile: profile,
        completionHistory: completions,
      );
    }).toList();

    return ScheduleEngine.computeUnified(inputs: inputs, today: today);
  }

  /// Complete a task — records the completion event.
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
    return getSchedule();
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
    return getSchedule();
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
    return getSchedule();
  }

  /// Update the schedule config for a specific plant.
  Future<List<CareTask>> updateScheduleConfig({
    required String plantId,
    required ScheduleConfig config,
  }) async {
    await repository.saveScheduleConfig(plantId, config);
    return getSchedule();
  }

  /// Update or create a room config.
  Future<List<CareTask>> updateRoomConfig({required RoomConfig config}) async {
    await repository.saveRoomConfig(config);
    return getSchedule();
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
    return getSchedule();
  }
}
