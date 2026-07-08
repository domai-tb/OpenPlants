import 'package:open_plant/pages/care_schedule/care_task.dart';
import 'package:open_plant/pages/care_schedule/care_task_type.dart';
import 'package:open_plant/pages/care_schedule/effective_interval_calculator.dart';
import 'package:open_plant/pages/care_schedule/overdue_detector.dart';
import 'package:open_plant/pages/care_schedule/pot_type_modifier.dart';
import 'package:open_plant/pages/care_schedule/room_config.dart';
import 'package:open_plant/pages/care_schedule/room_modifier.dart';
import 'package:open_plant/pages/care_schedule/schedule_config.dart';
import 'package:open_plant/pages/care_schedule/species_care_profile.dart';
import 'package:open_plant/pages/care_schedule/task_completion.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_entity.dart';

/// Input data for computing a schedule for a single plant.
class PlantScheduleInput {
  final String plantId;
  final String plantName;
  final ScheduleConfig config;
  final RoomConfig? roomConfig;
  final RoomEntity? roomEntity;
  final SpeciesCareProfile profile;
  final List<TaskCompletion> completionHistory;
  final List<CareTaskType> customTaskTypes;

  const PlantScheduleInput({
    required this.plantId,
    required this.plantName,
    required this.config,
    this.roomConfig,
    this.roomEntity,
    required this.profile,
    this.completionHistory = const [],
    this.customTaskTypes = const [],
  });
}

/// Pure-function scheduling engine.
///
/// Given a plant's config, room, profile, history, and today's date,
/// produces a deterministic list of care tasks sorted by urgency.
class ScheduleEngine {
  /// Compute the task feed for a single plant.
  static List<CareTask> computeForPlant({
    required PlantScheduleInput input,
    required DateTime today,
  }) {
    final tasks = <CareTask>[];

    // All task types: 8 built-in + custom
    final allTypes = <CareTaskType>[
      ...BuiltInTaskType.values.map(CareTaskType.builtIn),
      ...input.customTaskTypes,
    ];

    for (final taskType in allTypes) {
      // 1. Compute effective interval (species default → user override → seasonal)
      final effectiveInterval = EffectiveIntervalCalculator.compute(
        taskType: taskType,
        config: input.config,
        profile: input.profile,
        today: today,
      );

      if (effectiveInterval == null || effectiveInterval <= 0) continue;

      // 2. Apply room modifier
      double roomMod = 1;
      if (taskType.isBuiltIn) {
        roomMod = RoomModifier.compute(
          taskType: taskType.builtIn!,
          room: input.roomConfig,
          roomEntity: input.roomEntity,
        );
      }

      // 3. Apply pot-type modifier
      double potMod = 1;
      if (taskType.isBuiltIn) {
        potMod = PotTypeModifier.compute(
          taskType: taskType.builtIn!,
          potType: input.config.potType,
        );
      }

      // 4. Final effective interval
      final finalInterval = (effectiveInterval * roomMod * potMod).round();
      if (finalInterval <= 0) continue;

      // 5. Find last completion for this task type
      final lastCompletion = _findLastCompletion(
        input.completionHistory,
        taskType,
        input.plantId,
      );

      // 6. Determine status
      final status = OverdueDetector.detect(
        today: today,
        lastCompletedAt: lastCompletion?.completedAt,
        effectiveIntervalDays: finalInterval,
      );

      // 7. Compute due date
      final dueDate = lastCompletion != null ? lastCompletion.completedAt.add(Duration(days: finalInterval)) : today;

      tasks.add(
        CareTask(
          taskType: taskType,
          plantId: input.plantId,
          plantName: input.plantName,
          dueDate: dueDate,
          status: status,
          effectiveIntervalDays: finalInterval,
        ),
      );
    }

    // Sort: overdue first (by most overdue), then due-today, then upcoming (by due date)
    tasks.sort((a, b) {
      if (a.status != b.status) {
        return a.status.index.compareTo(b.status.index);
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return tasks;
  }

  /// Compute a unified schedule for multiple plants.
  static List<CareTask> computeUnified({
    required List<PlantScheduleInput> inputs,
    required DateTime today,
  }) {
    final allTasks = <CareTask>[];
    for (final input in inputs) {
      allTasks.addAll(computeForPlant(input: input, today: today));
    }

    allTasks.sort((a, b) {
      if (a.status != b.status) {
        return a.status.index.compareTo(b.status.index);
      }
      return a.dueDate.compareTo(b.dueDate);
    });

    return allTasks;
  }

  static TaskCompletion? _findLastCompletion(
    List<TaskCompletion> history,
    CareTaskType taskType,
    String plantId,
  ) {
    final matching = history.where((c) => c.plantId == plantId && c.taskType == taskType).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));

    return matching.isNotEmpty ? matching.first : null;
  }
}
