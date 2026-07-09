import 'package:open_plant/pages/care_schedule/care_task.dart';
import 'package:open_plant/pages/care_schedule/care_task_type.dart';
import 'package:open_plant/pages/care_schedule/custom_care_rule.dart';
import 'package:open_plant/pages/care_schedule/effective_interval_calculator.dart';
import 'package:open_plant/pages/care_schedule/light_level_modifier.dart';
import 'package:open_plant/pages/care_schedule/overdue_detector.dart';
import 'package:open_plant/pages/care_schedule/pot_type_modifier.dart';
import 'package:open_plant/pages/care_schedule/room_config.dart';
import 'package:open_plant/pages/care_schedule/room_modifier.dart';
import 'package:open_plant/pages/care_schedule/schedule_config.dart';
import 'package:open_plant/pages/care_schedule/species_care_profile.dart';
import 'package:open_plant/pages/care_schedule/task_completion.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
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
  final List<CustomCareRuleEntity> customCareRules;
  final LightLevel? lightLevel;

  const PlantScheduleInput({
    required this.plantId,
    required this.plantName,
    required this.config,
    this.roomConfig,
    this.roomEntity,
    required this.profile,
    this.completionHistory = const [],
    this.customTaskTypes = const [],
    this.customCareRules = const [],
    this.lightLevel,
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

    // Build a map of enabled custom care rules keyed by task type string
    final enabledRules = <String, CustomCareRuleEntity>{};
    for (final rule in input.customCareRules) {
      if (rule.isEnabled) {
        enabledRules[rule.taskType] = rule;
      }
    }

    // All task types: 8 built-in + custom from rules
    final allTypes = <CareTaskType>[
      ...BuiltInTaskType.values.map(CareTaskType.builtIn),
      ...input.customTaskTypes,
    ];

    // Also add task types from enabled rules that aren't already in the list
    for (final ruleEntry in enabledRules.entries) {
      final ruleTypeName = ruleEntry.key;
      // Check if this is a built-in type name
      final isBuiltIn = BuiltInTaskType.values.any((b) => b.name == ruleTypeName);
      final ruleType = isBuiltIn
          ? CareTaskType.builtIn(BuiltInTaskType.values.firstWhere((b) => b.name == ruleTypeName))
          : CareTaskType.custom(ruleTypeName);
      if (!allTypes.contains(ruleType)) {
        allTypes.add(ruleType);
      }
    }

    for (final taskType in allTypes) {
      // Check for a matching custom care rule first
      // Match by label (for built-in) or customName (for custom)
      CustomCareRuleEntity? matchingRule;
      if (taskType.isBuiltIn) {
        matchingRule = enabledRules[taskType.builtIn!.name];
      } else {
        matchingRule = enabledRules[taskType.customName];
      }

      int? effectiveInterval;
      if (matchingRule != null) {
        // Custom rule found: use rule interval directly, skip all modifiers
        effectiveInterval = matchingRule.intervalDays;
      } else {
        // No custom rule: use existing computation pipeline
        effectiveInterval = EffectiveIntervalCalculator.compute(
          taskType: taskType,
          config: input.config,
          profile: input.profile,
          today: today,
        );

        if (effectiveInterval != null && effectiveInterval > 0 && taskType.isBuiltIn) {
          // Compute light modifier: plant light level takes precedence over room sunlight
          double lightMod;
          if (input.lightLevel != null) {
            lightMod = LightLevelModifier.compute(
              taskType: taskType.builtIn!,
              lightLevel: input.lightLevel,
            );
          } else {
            // Fall back to room's light modifier
            lightMod = RoomModifier.computeLightModifier(
              taskType: taskType.builtIn!,
              room: input.roomConfig,
              roomEntity: input.roomEntity,
            );
          }

          // Compute humidity modifier from room
          final humidityMod = RoomModifier.computeHumidityModifier(
            taskType: taskType.builtIn!,
            room: input.roomConfig,
            roomEntity: input.roomEntity,
          );

          // Apply pot-type modifier
          final potMod = PotTypeModifier.compute(
            taskType: taskType.builtIn!,
            potType: input.config.potType,
          );

          effectiveInterval = (effectiveInterval * lightMod * humidityMod * potMod).round();
        }
      }

      if (effectiveInterval == null || effectiveInterval <= 0) continue;

      // Find last completion for this task type
      final lastCompletion = _findLastCompletion(
        input.completionHistory,
        taskType,
        input.plantId,
      );

      // Determine status
      final status = OverdueDetector.detect(
        today: today,
        lastCompletedAt: lastCompletion?.completedAt,
        effectiveIntervalDays: effectiveInterval,
      );

      // Compute due date
      final dueDate = lastCompletion != null
          ? lastCompletion.completedAt.add(Duration(days: effectiveInterval))
          : today;

      tasks.add(
        CareTask(
          taskType: taskType,
          plantId: input.plantId,
          plantName: input.plantName,
          dueDate: dueDate,
          status: status,
          effectiveIntervalDays: effectiveInterval,
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
