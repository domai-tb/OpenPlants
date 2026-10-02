import 'package:flutter/foundation.dart';

import 'package:openplants/pages/care_schedule/care_schedule_action.dart';
import 'package:openplants/pages/care_schedule/care_task.dart';
import 'package:openplants/pages/care_schedule/care_task_type.dart';
import 'package:openplants/pages/care_schedule/custom_care_rule.dart';
import 'package:openplants/pages/care_schedule/custom_care_rule_usecases.dart';
import 'package:openplants/pages/care_schedule/overdue_detector.dart';
import 'package:openplants/pages/care_schedule/room_config.dart';
import 'package:openplants/pages/care_schedule/schedule_config.dart';
import 'package:openplants/pages/care_schedule/schedule_engine.dart';
import 'package:openplants/pages/care_schedule/care_schedule_repository.dart';
import 'package:openplants/pages/care_schedule/task_completion.dart';
import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:openplants/pages/plant_journal/plant_journal_usecases.dart';
import 'package:openplants/pages/plant_metrics/metric_definition.dart';
import 'package:openplants/pages/plant_metrics/metric_evaluator.dart';
import 'package:openplants/pages/plant_metrics/metric_usecases.dart';
import 'package:openplants/pages/room_profiles/room_profiles_entity.dart';
import 'package:openplants/pages/room_profiles/room_profiles_usecases.dart';

/// Use cases for the care schedule feature.
class CareScheduleUsecases {
  final CareScheduleRepository repository;
  final PlantCollectionUsecases plantCollection;
  final PlantJournalUseCases plantJournal;
  final RoomProfilesUsecases? roomProfiles;
  final MetricUsecases? metricUsecases;
  final Future<void> Function()? onNotificationsChanged;

  const CareScheduleUsecases({
    required this.repository,
    required this.plantCollection,
    required this.plantJournal,
    this.roomProfiles,
    this.metricUsecases,
    this.onNotificationsChanged,
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
    final today = calendarDate(DateTime.now());
    final completedAlertEpisodeIds =
        completions.map((completion) => completion.alertEpisodeId).whereType<String>().toSet();

    // Load room entities if available
    final roomEntities = <String, RoomEntity>{};
    if (roomProfiles != null) {
      final rooms = await roomProfiles!.getAll();
      for (final room in rooms) {
        roomEntities[room.id] = room;
      }
    }

    final allScheduleActions = await repository.getAllScheduleActions();

    final inputs = <PlantScheduleInput>[];
    for (final plant in plants) {
      final config = allConfigs[plant.id] ?? ScheduleConfig.defaults();
      final roomConfig = plant.room != null ? allRoomConfigs[plant.room!] : null;
      final roomEntity = plant.roomId != null ? roomEntities[plant.roomId] : null;
      final profile = repository.getSpeciesProfile(plant.speciesName);
      final plantRules = allCustomRules.where((r) => r.plantId == plant.id).toList();
      final plantActions =
          allScheduleActions.entries.where((e) => e.key.startsWith('${plant.id}_')).map((e) => e.value).toList();
      final metricLatestMeasurementTimes = <String, DateTime>{};
      final careTaskMetricIds = <String>{};
      final disabledMetricIds = <String>{};
      final activeAlertEpisodeIds = <String, String>{};
      final metricNamesById = <String, String>{};

      final metricUsecases = this.metricUsecases;
      final metricIds = plantRules.map((rule) => rule.metricId).whereType<String>().toSet();
      if (metricUsecases == null) {
        disabledMetricIds.addAll(metricIds);
      } else {
        for (final metricId in metricIds) {
          final definition = await metricUsecases.getDefinitionById(metricId);
          if (definition == null || definition.plantId != plant.id || !definition.isEnabled) {
            disabledMetricIds.add(metricId);
            continue;
          }
          metricNamesById[metricId] = definition.name;

          final evaluation = await metricUsecases.evaluateMetric(metricId);
          final measuredAt = evaluation.lastMeasurement?.measuredAt;
          if (measuredAt != null) metricLatestMeasurementTimes[metricId] = measuredAt;

          if (definition.alertResponse == AlertResponse.careTask) {
            careTaskMetricIds.add(metricId);
            final episodeId = evaluation.alertEpisodeId;
            if (evaluation.state == MetricState.alert && episodeId != null) {
              activeAlertEpisodeIds[metricId] = episodeId;
            }
          }
        }
      }

      inputs.add(
        PlantScheduleInput(
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
          metricLatestMeasurementTimes: metricLatestMeasurementTimes,
          completedAlertEpisodeIds: completedAlertEpisodeIds,
          careTaskMetricIds: careTaskMetricIds,
          disabledMetricIds: disabledMetricIds,
          activeAlertEpisodeIds: activeAlertEpisodeIds,
          metricNamesById: metricNamesById,
        ),
      );
    }

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
        occurrenceDueDate: task.occurrenceDueDate,
        alertEpisodeId: task.alertEpisodeId,
        alertMetricName: task.alertMetricName,
      );
    }).toList();

    final completedEarly = tasks.where((t) => t.status == CareTaskStatus.justCompleted).toList();

    return (tasks: tasks, completedEarly: completedEarly, roomContext: taskRoomContext);
  }

  /// Complete a task — records the completion event and auto-journals it.
  ///
  /// Clears any active schedule action for this plant/task pair.
  Future<void> completeTask({
    required CareTask task,
    String? note,
  }) async {
    final completion = TaskCompletion(
      taskType: task.taskType,
      plantId: task.plantId,
      completedAt: DateTime.now(),
      note: note,
      alertEpisodeId: task.alertEpisodeId,
    );

    await repository.recordCompletion(completion);

    // A new completion makes any previous schedule action stale.
    try {
      await repository.deleteScheduleAction(task.plantId, task.taskType);
    } catch (error) {
      debugPrint('Failed to clear schedule action after task completion: $error');
    }

    // Auto-journal the completed task (graceful degradation on failure)
    try {
      final notes = _buildJournalNotes(task.displayName, note);
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

    await _syncNotifications();
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
  Future<void> snoozeTask({
    required CareTask task,
    required int days,
  }) async {
    final now = DateTime.now();
    final action = CareScheduleAction(
      plantId: task.plantId,
      taskType: task.taskType,
      actionKind: CareScheduleActionKind.snooze,
      actionTime: now,
      targetedOccurrenceDueDate: task.scheduleOccurrenceDueDate,
      overriddenDueDate: addCalendarDays(now, days),
    );

    await repository.saveScheduleAction(action);
    await _syncNotifications();
  }

  /// Skip a task — advances the due date by one effective interval.
  ///
  /// Saves a schedule action instead of recording a completion.
  /// The action advances the due date without creating a genuine completion.
  Future<void> skipTask({required CareTask task}) async {
    final now = DateTime.now();
    final action = CareScheduleAction(
      plantId: task.plantId,
      taskType: task.taskType,
      actionKind: CareScheduleActionKind.skip,
      actionTime: now,
      targetedOccurrenceDueDate: task.scheduleOccurrenceDueDate,
      overriddenDueDate: addCalendarDays(task.dueDate, task.effectiveIntervalDays),
    );

    await repository.saveScheduleAction(action);
    await _syncNotifications();
  }

  /// Update the schedule config for a specific plant.
  Future<List<CareTask>> updateScheduleConfig({
    required String plantId,
    required ScheduleConfig config,
  }) async {
    await repository.saveScheduleConfig(plantId, config);
    await _syncNotifications();
    return (await getSchedule()).tasks;
  }

  /// Update or create a room config.
  Future<List<CareTask>> updateRoomConfig({required RoomConfig config}) async {
    await repository.saveRoomConfig(config);
    await _syncNotifications();
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
    await _syncNotifications();
    return (await getSchedule()).tasks;
  }

  /// Get all active schedule actions.
  Future<Map<String, CareScheduleAction>> getScheduleActions() async {
    return repository.getAllScheduleActions();
  }

  /// Delete all task completions for a specific plant.
  Future<void> deleteCompletionsForPlant(String plantId) async {
    await repository.deleteCompletionsForPlant(plantId);
    await _syncNotifications();
  }

  /// Delete all custom care rules for a specific plant.
  Future<void> deleteCustomRulesForPlant(String plantId) async {
    await repository.deleteCustomRulesForPlant(plantId);
    await _syncNotifications();
  }

  /// Delete all schedule actions for a specific plant.
  Future<void> deleteAllScheduleActionsForPlant(String plantId) async {
    await repository.deleteAllScheduleActionsForPlant(plantId);
    await _syncNotifications();
  }

  Future<void> _syncNotifications() async {
    try {
      await onNotificationsChanged?.call();
    } catch (error) {
      debugPrint('Failed to sync notifications after care schedule change: $error');
    }
  }

  /// Get the 8 computed rules for a plant based on its species profile.
  ///
  /// Each entry has: taskType name, default interval from species profile,
  /// and whether a custom override exists. Also includes any custom
  /// non-built-in rules so they are not hidden from the unified list.
  Future<List<ComputedRule>> getComputedRules(String plantId) async {
    final plants = await plantCollection.loadPlants();
    final plant = plants.firstWhere(
      (p) => p.id == plantId,
      orElse: () => throw Exception('Plant not found'),
    );
    final profile = repository.getSpeciesProfile(plant.speciesName);
    final customRules = await repository.getCustomCareRules(plantId);
    final customByType = <String, CustomCareRuleEntity>{
      for (final r in customRules) r.taskType: r,
    };

    final builtInRules = BuiltInTaskType.values.map((builtIn) {
      final defaultInterval = profile.getDefaultInterval(builtIn);
      final custom = customByType[builtIn.name];
      return ComputedRule(
        taskType: builtIn.name,
        defaultIntervalDays: defaultInterval,
        customIntervalDays: custom?.intervalDays,
        isOverridden: custom != null,
        isEnabled: custom?.isEnabled ?? (defaultInterval != null && defaultInterval > 0),
      );
    }).toList();

    // Include custom task types that are not built-in so they remain
    // visible/editable in the unified list.
    final customOnly = customRules.where((r) => BuiltInTaskType.values.every((b) => b.name != r.taskType)).map(
          (r) => ComputedRule(
            taskType: r.taskType,
            defaultIntervalDays: null,
            customIntervalDays: r.intervalDays,
            isOverridden: true,
            isEnabled: r.isEnabled,
          ),
        );

    return [...builtInRules, ...customOnly];
  }

  /// Toggle a computed rule: create or disable a custom override.
  ///
  /// If no custom override exists, creates a disabled override so the
  /// computed default is suppressed. If one exists, toggles its enabled state.
  Future<List<ComputedRule>> toggleComputedRule({
    required String plantId,
    required String taskType,
    required int intervalDays,
  }) async {
    final rules = await repository.getCustomCareRules(plantId);
    final existing = rules.where((r) => r.taskType == taskType).toList();

    if (existing.isNotEmpty) {
      final rule = existing.first;
      await repository.saveCustomCareRule(rule.copyWith(isEnabled: !rule.isEnabled));
    } else {
      final customRules = CustomCareRuleUsecases(repository: repository);
      await customRules.create(
        plantId: plantId,
        taskType: taskType,
        intervalDays: intervalDays,
        isEnabled: false,
      );
    }

    await _syncNotifications();
    return getComputedRules(plantId);
  }
}

/// A computed care rule combining species defaults with custom overrides.
class ComputedRule {
  final String taskType;
  final int? defaultIntervalDays;
  final int? customIntervalDays;
  final bool isOverridden;
  final bool isEnabled;

  const ComputedRule({
    required this.taskType,
    required this.defaultIntervalDays,
    this.customIntervalDays,
    required this.isOverridden,
    required this.isEnabled,
  });

  int get effectiveIntervalDays => customIntervalDays ?? defaultIntervalDays ?? 0;
}
