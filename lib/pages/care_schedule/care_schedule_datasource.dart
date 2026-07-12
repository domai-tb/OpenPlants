import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/pages/care_schedule/custom_care_rule.dart';
import 'package:open_plants/pages/care_schedule/room_config.dart';
import 'package:open_plants/pages/care_schedule/schedule_config.dart';
import 'package:open_plants/pages/care_schedule/task_completion.dart';

/// Data source for care schedule persistence.
///
/// Stores schedule configs, room configs, and task completion log
/// as JSON in SharedPreferences.
class CareScheduleDataSource {
  static const String _scheduleConfigsKey = 'care_schedule_configs_v1';
  static const String _roomConfigsKey = 'care_room_configs_v1';
  static const String _completionsKey = 'care_task_completions_v1';
  static const String _customCareRulesKey = 'custom_care_rules_v1';

  // --- Schedule Configs (per-plant) ---

  /// Load all schedule configs keyed by plant ID.
  Future<Map<String, ScheduleConfig>> loadScheduleConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_scheduleConfigsKey);

    if (raw == null || raw.trim().isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, ScheduleConfig.fromJson(value as Map<String, dynamic>)),
      );
    } catch (_) {
      return {};
    }
  }

  /// Save a schedule config for a specific plant.
  Future<void> saveScheduleConfig(String plantId, ScheduleConfig config) async {
    final configs = await loadScheduleConfigs();
    configs[plantId] = config;
    final prefs = await SharedPreferences.getInstance();
    final json = configs.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_scheduleConfigsKey, jsonEncode(json));
  }

  /// Delete a schedule config for a specific plant.
  Future<void> deleteScheduleConfig(String plantId) async {
    final configs = await loadScheduleConfigs();
    configs.remove(plantId);
    final prefs = await SharedPreferences.getInstance();
    final json = configs.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_scheduleConfigsKey, jsonEncode(json));
  }

  // --- Room Configs ---

  /// Load all room configs keyed by room name.
  Future<Map<String, RoomConfig>> loadRoomConfigs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_roomConfigsKey);

    if (raw == null || raw.trim().isEmpty) return {};

    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map(
        (key, value) => MapEntry(key, RoomConfig.fromJson(value as Map<String, dynamic>)),
      );
    } catch (_) {
      return {};
    }
  }

  /// Save a room config.
  Future<void> saveRoomConfig(RoomConfig config) async {
    final configs = await loadRoomConfigs();
    configs[config.roomName] = config;
    final prefs = await SharedPreferences.getInstance();
    final json = configs.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_roomConfigsKey, jsonEncode(json));
  }

  /// Delete a room config by name.
  Future<void> deleteRoomConfig(String roomName) async {
    final configs = await loadRoomConfigs();
    configs.remove(roomName);
    final prefs = await SharedPreferences.getInstance();
    final json = configs.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_roomConfigsKey, jsonEncode(json));
  }

  // --- Task Completions ---

  /// Load all task completions.
  Future<List<TaskCompletion>> loadCompletions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_completionsKey);

    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => TaskCompletion.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Save the full list of task completions.
  Future<void> saveCompletions(List<TaskCompletion> completions) async {
    final prefs = await SharedPreferences.getInstance();
    final json = completions.map((c) => c.toJson()).toList();
    await prefs.setString(_completionsKey, jsonEncode(json));
  }

  /// Add a single completion event.
  Future<void> addCompletion(TaskCompletion completion) async {
    final completions = await loadCompletions();
    completions.add(completion);
    await saveCompletions(completions);
  }

  /// Delete a specific completion event.
  Future<void> deleteCompletion(TaskCompletion completion) async {
    final completions = await loadCompletions();
    completions.removeWhere(
      (c) =>
          c.taskType == completion.taskType &&
          c.plantId == completion.plantId &&
          c.completedAt == completion.completedAt,
    );
    await saveCompletions(completions);
  }

  // --- Custom Care Rules ---

  /// Load all custom care rules.
  Future<List<CustomCareRuleEntity>> loadCustomCareRules() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_customCareRulesKey);

    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => CustomCareRuleEntity.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Save the full list of custom care rules.
  Future<void> saveCustomCareRules(List<CustomCareRuleEntity> rules) async {
    final prefs = await SharedPreferences.getInstance();
    final json = rules.map((r) => r.toJson()).toList();
    await prefs.setString(_customCareRulesKey, jsonEncode(json));
  }
}
