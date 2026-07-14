import 'package:open_plants/pages/care_schedule/care_schedule_action.dart';
import 'package:open_plants/pages/care_schedule/care_schedule_datasource.dart';
import 'package:open_plants/pages/care_schedule/care_task_type.dart';
import 'package:open_plants/pages/care_schedule/custom_care_rule.dart';
import 'package:open_plants/pages/care_schedule/room_config.dart';
import 'package:open_plants/pages/care_schedule/schedule_config.dart';
import 'package:open_plants/pages/care_schedule/species_care_profile.dart';
import 'package:open_plants/pages/care_schedule/species_care_profiles.dart';
import 'package:open_plants/pages/care_schedule/task_completion.dart';

/// Repository for care schedule domain operations.
///
/// Wraps the datasource and provides typed getters/setters for config and history.
class CareScheduleRepository {
  final CareScheduleDataSource dataSource;

  CareScheduleRepository({required this.dataSource});

  // --- Schedule Config ---

  /// Load the schedule config for a specific plant.
  /// Returns default config if none exists.
  Future<ScheduleConfig> getScheduleConfig(String plantId) async {
    final configs = await dataSource.loadScheduleConfigs();
    return configs[plantId] ?? ScheduleConfig.defaults();
  }

  /// Save a schedule config for a specific plant.
  Future<void> saveScheduleConfig(String plantId, ScheduleConfig config) async {
    await dataSource.saveScheduleConfig(plantId, config);
  }

  /// Load all schedule configs.
  Future<Map<String, ScheduleConfig>> getAllScheduleConfigs() async {
    return dataSource.loadScheduleConfigs();
  }

  // --- Room Config ---

  /// Load the room config for a specific room.
  /// Returns null if no config exists.
  Future<RoomConfig?> getRoomConfig(String roomName) async {
    final configs = await dataSource.loadRoomConfigs();
    return configs[roomName];
  }

  /// Save a room config.
  Future<void> saveRoomConfig(RoomConfig config) async {
    await dataSource.saveRoomConfig(config);
  }

  /// Load all room configs.
  Future<Map<String, RoomConfig>> getAllRoomConfigs() async {
    return dataSource.loadRoomConfigs();
  }

  // --- Task Completions ---

  /// Get all task completions.
  Future<List<TaskCompletion>> getAllCompletions() async {
    return dataSource.loadCompletions();
  }

  /// Get completions for a specific plant.
  Future<List<TaskCompletion>> getCompletionsForPlant(String plantId) async {
    final all = await dataSource.loadCompletions();
    return all.where((c) => c.plantId == plantId).toList()..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  /// Get completions for a specific plant and task type.
  Future<List<TaskCompletion>> getCompletionsForPlantAndType(
    String plantId,
    String taskTypeKey,
  ) async {
    final all = await dataSource.loadCompletions();
    return all.where((c) => c.plantId == plantId && c.taskType.key == taskTypeKey).toList()
      ..sort((a, b) => b.completedAt.compareTo(a.completedAt));
  }

  /// Record a task completion.
  Future<void> recordCompletion(TaskCompletion completion) async {
    await dataSource.addCompletion(completion);
  }

  /// Delete a task completion.
  Future<void> deleteCompletion(TaskCompletion completion) async {
    await dataSource.deleteCompletion(completion);
  }

  /// Get the most recent completion per task type for a plant.
  Future<Map<String, TaskCompletion>> getLatestCompletionsPerType(
    String plantId,
  ) async {
    final completions = await getCompletionsForPlant(plantId);
    final latest = <String, TaskCompletion>{};

    for (final c in completions) {
      final key = c.taskType.key;
      if (!latest.containsKey(key)) {
        latest[key] = c;
      }
    }

    return latest;
  }

  // --- Custom Care Rules ---

  /// Get all custom care rules for a specific plant, ordered by creation date.
  Future<List<CustomCareRuleEntity>> getCustomCareRules(String plantId) async {
    final all = await dataSource.loadCustomCareRules();
    return all.where((r) => r.plantId == plantId).toList()..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Get all custom care rules across all plants.
  Future<List<CustomCareRuleEntity>> getAllCustomCareRules() async {
    return dataSource.loadCustomCareRules();
  }

  /// Save a custom care rule (create or update).
  Future<void> saveCustomCareRule(CustomCareRuleEntity rule) async {
    final all = await dataSource.loadCustomCareRules();
    final index = all.indexWhere((r) => r.id == rule.id);
    if (index >= 0) {
      all[index] = rule;
    } else {
      all.add(rule);
    }
    await dataSource.saveCustomCareRules(all);
  }

  /// Delete a custom care rule by ID.
  Future<void> deleteCustomCareRule(String ruleId) async {
    final all = await dataSource.loadCustomCareRules();
    all.removeWhere((r) => r.id == ruleId);
    await dataSource.saveCustomCareRules(all);
  }

  // --- Species Profile ---

  /// Get a species care profile by ID.
  SpeciesCareProfile getSpeciesProfile(String? speciesId) {
    return SpeciesCareProfiles.getProfile(speciesId);
  }

  // --- Schedule Actions (Snooze/Skip) ---

  /// Get all active schedule actions.
  Future<Map<String, CareScheduleAction>> getAllScheduleActions() async {
    return dataSource.loadScheduleActions();
  }

  /// Get the active schedule action for a specific plant and task type.
  Future<CareScheduleAction?> getScheduleAction(String plantId, CareTaskType taskType) async {
    return dataSource.loadScheduleAction(plantId, taskType);
  }

  /// Save a schedule action, replacing any existing action for the same plant/task pair.
  Future<void> saveScheduleAction(CareScheduleAction action) async {
    await dataSource.saveScheduleAction(action);
  }

  /// Delete the schedule action for a specific plant and task type.
  Future<void> deleteScheduleAction(String plantId, CareTaskType taskType) async {
    await dataSource.deleteScheduleAction(plantId, taskType);
  }

  /// Delete all schedule actions for a specific plant.
  Future<void> deleteAllScheduleActionsForPlant(String plantId) async {
    await dataSource.deleteAllScheduleActionsForPlant(plantId);
  }

  /// Delete all task completions for a specific plant.
  Future<void> deleteCompletionsForPlant(String plantId) async {
    await dataSource.deleteCompletionsForPlant(plantId);
  }

  /// Delete all custom care rules for a specific plant.
  Future<void> deleteCustomRulesForPlant(String plantId) async {
    await dataSource.deleteCustomRulesForPlant(plantId);
  }
}
