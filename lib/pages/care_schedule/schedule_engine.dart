import 'package:open_plants/pages/care_schedule/care_schedule_action.dart';
import 'package:open_plants/pages/care_schedule/care_task.dart';
import 'package:open_plants/pages/care_schedule/care_task_type.dart';
import 'package:open_plants/pages/care_schedule/custom_care_rule.dart';
import 'package:open_plants/pages/care_schedule/effective_interval_calculator.dart';
import 'package:open_plants/pages/care_schedule/light_level_modifier.dart';
import 'package:open_plants/pages/care_schedule/overdue_detector.dart';
import 'package:open_plants/pages/care_schedule/pot_type_modifier.dart';
import 'package:open_plants/pages/care_schedule/room_config.dart';
import 'package:open_plants/pages/care_schedule/room_modifier.dart';
import 'package:open_plants/pages/care_schedule/schedule_config.dart';
import 'package:open_plants/pages/care_schedule/species_care_profile.dart';
import 'package:open_plants/pages/care_schedule/task_completion.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plants/pages/room_profiles/room_profiles_entity.dart';

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
  final List<CareScheduleAction> activeScheduleActions;
  final LightLevel? lightLevel;

  /// Metric context: latest measurement time per metric ID.
  /// Used to anchor measurement-reminder intervals from the newest measurement.
  final Map<String, DateTime>? metricLatestMeasurementTimes;

  /// Metric context: alert episode IDs that have already been completed.
  /// Used to suppress completed alert tasks until recovery.
  final Set<String>? completedAlertEpisodeIds;

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
    this.activeScheduleActions = const [],
    this.lightLevel,
    this.metricLatestMeasurementTimes,
    this.completedAlertEpisodeIds,
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

    // All custom rules by taskType, including disabled overrides so they can
    // suppress the computed default rather than falling back to it.
    final allRulesByType = <String, CustomCareRuleEntity>{
      for (final r in input.customCareRules) r.taskType: r,
    };

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
      // Disabled custom override suppresses the task entirely instead of
      // falling back to the species default.
      final lookupKey = taskType.isBuiltIn ? taskType.builtIn!.name : taskType.customName!;
      final disabled = allRulesByType[lookupKey];
      if (disabled != null && !disabled.isEnabled) continue;

      // Check for a matching custom care rule first
      // Match by label (for built-in) or customName (for custom)
      CustomCareRuleEntity? matchingRule;
      if (taskType.isBuiltIn) {
        matchingRule = enabledRules[taskType.builtIn!.name];
      } else {
        matchingRule = enabledRules[taskType.customName];
      }

      int? effectiveInterval;
      DateTime? measurementAnchor;
      if (matchingRule != null) {
        // Custom rule found: use rule interval directly, skip all modifiers
        effectiveInterval = matchingRule.intervalDays;

        // For metric-linked rules, anchor from newest measurement if available
        if (matchingRule.metricId != null &&
            input.metricLatestMeasurementTimes != null &&
            input.metricLatestMeasurementTimes!.containsKey(matchingRule.metricId)) {
          measurementAnchor = input.metricLatestMeasurementTimes![matchingRule.metricId];
        }
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

      // Compute base due date: prefer measurement anchor for metric-linked rules,
      // otherwise use completion history
      DateTime baseDueDate;
      if (measurementAnchor != null) {
        baseDueDate = measurementAnchor.add(Duration(days: effectiveInterval));
      } else if (lastCompletion != null) {
        baseDueDate = lastCompletion.completedAt.add(Duration(days: effectiveInterval));
      } else {
        baseDueDate = today;
      }

      // Apply schedule action override if active
      DateTime dueDate = baseDueDate;
      CareTaskStatus status;

      final activeAction = _findActiveAction(
        input.activeScheduleActions,
        taskType,
        input.plantId,
        baseDueDate,
      );

      if (activeAction != null) {
        // Apply the override due date
        dueDate = activeAction.overriddenDueDate;
      }

      // Determine status using the final due date
      status = OverdueDetector.detect(
        today: today,
        lastCompletedAt: lastCompletion?.completedAt,
        effectiveIntervalDays: effectiveInterval,
        overriddenDueDate: activeAction != null ? dueDate : null,
      );

      tasks.add(
        CareTask(
          taskType: taskType,
          plantId: input.plantId,
          plantName: input.plantName,
          dueDate: dueDate,
          status: status,
          effectiveIntervalDays: effectiveInterval,
          completedAt: lastCompletion?.completedAt,
        ),
      );
    }

    // Generate alert tasks for metric-linked rules with active alert episodes
    for (final rule in input.customCareRules) {
      if (!rule.isEnabled || rule.metricId == null) continue;

      // Check if there's a completed alert episode for this metric
      final completedEpisodes = input.completedAlertEpisodeIds ?? {};
      if (completedEpisodes.contains(rule.metricId)) continue;

      // Add alert task for this metric rule
      tasks.add(
        CareTask(
          taskType: CareTaskType.custom('${rule.taskType}_alert'),
          plantId: input.plantId,
          plantName: input.plantName,
          dueDate: today,
          status: CareTaskStatus.dueToday,
          effectiveIntervalDays: 0,
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

  static CareScheduleAction? _findActiveAction(
    List<CareScheduleAction> actions,
    CareTaskType taskType,
    String plantId,
    DateTime baseDueDate,
  ) {
    for (final action in actions) {
      if (action.plantId == plantId && action.taskType == taskType) {
        // Check if the action targets the current occurrence
        // An action is stale if its targeted due date doesn't match the current base due date
        if (action.targetedOccurrenceDueDate == baseDueDate) {
          return action;
        }
      }
    }
    return null;
  }
}
