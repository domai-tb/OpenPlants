import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/exceptions.dart';
import 'package:open_plants/core/local_collection_codec.dart';
import 'package:open_plants/pages/care_schedule/care_schedule_action.dart';
import 'package:open_plants/pages/care_schedule/care_task_type.dart';
import 'package:open_plants/pages/care_schedule/custom_care_rule.dart';
import 'package:open_plants/pages/care_schedule/room_config.dart';
import 'package:open_plants/pages/care_schedule/schedule_config.dart';
import 'package:open_plants/pages/care_schedule/task_completion.dart';

/// Data source for care schedule persistence.
///
/// Stores schedule configs, room configs, and task completion log
/// as JSON in SharedPreferences.
///
/// Uses [LocalCollectionCodec] for list-based collections (completions,
/// custom rules) to distinguish missing keys from corruption, preserve raw
/// values on failure, and block mutations after a decode failure.
///
/// Map-based collections (schedule configs, room configs) use manual decoding
/// with corruption detection that throws on malformed data instead of
/// silently returning empty collections.
class CareScheduleDataSource {
  static const String _scheduleConfigsKey = 'care_schedule_configs_v1';
  static const String _roomConfigsKey = 'care_room_configs_v1';
  static const String _completionsKey = 'care_task_completions_v1';
  static const String _customCareRulesKey = 'custom_care_rules_v1';
  static const String _scheduleActionsKey = 'care_schedule_actions_v1';

  final SharedPreferences? _prefsOverride;
  LocalCollectionCodec<TaskCompletion>? _completionsCodec;
  LocalCollectionCodec<CustomCareRuleEntity>? _customRulesCodec;

  CareScheduleDataSource({SharedPreferences? prefs}) : _prefsOverride = prefs;

  Future<SharedPreferences> _getPrefs() async {
    return _prefsOverride ?? await SharedPreferences.getInstance();
  }

  Future<LocalCollectionCodec<TaskCompletion>> _getCompletionsCodec() async {
    if (_completionsCodec == null) {
      final prefs = await _getPrefs();
      _completionsCodec = LocalCollectionCodec<TaskCompletion>(
        prefs: prefs,
        key: _completionsKey,
        fromJson: TaskCompletion.fromJson,
        toJson: (c) => c.toJson(),
        keyExtractor: (c) => '${c.taskType.key}_${c.plantId}_${c.completedAt.toIso8601String()}',
      );
    }
    return _completionsCodec!;
  }

  Future<LocalCollectionCodec<CustomCareRuleEntity>> _getCustomRulesCodec() async {
    if (_customRulesCodec == null) {
      final prefs = await _getPrefs();
      _customRulesCodec = LocalCollectionCodec<CustomCareRuleEntity>(
        prefs: prefs,
        key: _customCareRulesKey,
        fromJson: CustomCareRuleEntity.fromJson,
        toJson: (r) => r.toJson(),
        keyExtractor: (r) => r.id,
      );
    }
    return _customRulesCodec!;
  }

  // --- Schedule Configs (per-plant) ---

  /// Load all schedule configs keyed by plant ID.
  ///
  /// Throws [CollectionDecodeFailure], [CollectionShapeFailure], or
  /// [RecordDecodeFailure] when stored data is malformed.
  Future<Map<String, ScheduleConfig>> loadScheduleConfigs() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_scheduleConfigsKey);

    if (raw == null || raw.trim().isEmpty) return {};

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      throw CollectionDecodeFailure(collection: _scheduleConfigsKey);
    }

    if (decoded is! Map<String, dynamic>) {
      throw CollectionShapeFailure(collection: _scheduleConfigsKey);
    }

    try {
      return decoded.map(
        (key, value) => MapEntry(key, ScheduleConfig.fromJson(value as Map<String, dynamic>)),
      );
    } catch (_) {
      throw CollectionDecodeFailure(collection: _scheduleConfigsKey);
    }
  }

  /// Save a schedule config for a specific plant.
  Future<void> saveScheduleConfig(String plantId, ScheduleConfig config) async {
    final configs = await loadScheduleConfigs();
    configs[plantId] = config;
    final prefs = await _getPrefs();
    final json = configs.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_scheduleConfigsKey, jsonEncode(json));
  }

  /// Delete a schedule config for a specific plant.
  Future<void> deleteScheduleConfig(String plantId) async {
    final configs = await loadScheduleConfigs();
    configs.remove(plantId);
    final prefs = await _getPrefs();
    final json = configs.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_scheduleConfigsKey, jsonEncode(json));
  }

  // --- Room Configs ---

  /// Load all room configs keyed by room name.
  ///
  /// Throws [CollectionDecodeFailure], [CollectionShapeFailure], or
  /// [RecordDecodeFailure] when stored data is malformed.
  Future<Map<String, RoomConfig>> loadRoomConfigs() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_roomConfigsKey);

    if (raw == null || raw.trim().isEmpty) return {};

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      throw CollectionDecodeFailure(collection: _roomConfigsKey);
    }

    if (decoded is! Map<String, dynamic>) {
      throw CollectionShapeFailure(collection: _roomConfigsKey);
    }

    try {
      return decoded.map(
        (key, value) => MapEntry(key, RoomConfig.fromJson(value as Map<String, dynamic>)),
      );
    } catch (_) {
      throw CollectionDecodeFailure(collection: _roomConfigsKey);
    }
  }

  /// Save a room config.
  Future<void> saveRoomConfig(RoomConfig config) async {
    final configs = await loadRoomConfigs();
    configs[config.roomName] = config;
    final prefs = await _getPrefs();
    final json = configs.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_roomConfigsKey, jsonEncode(json));
  }

  /// Delete a room config by name.
  Future<void> deleteRoomConfig(String roomName) async {
    final configs = await loadRoomConfigs();
    configs.remove(roomName);
    final prefs = await _getPrefs();
    final json = configs.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_roomConfigsKey, jsonEncode(json));
  }

  // --- Task Completions ---

  /// Load all task completions.
  ///
  /// Throws [CollectionDecodeFailure], [CollectionShapeFailure], or
  /// [RecordDecodeFailure] when stored data is malformed.
  Future<List<TaskCompletion>> loadCompletions() async {
    final codec = await _getCompletionsCodec();
    final result = await codec.load();
    if (result.isFailure) {
      throw result.asFailure!;
    }
    return result.asSuccess;
  }

  /// Save the full list of task completions.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> saveCompletions(List<TaskCompletion> completions) async {
    final codec = await _getCompletionsCodec();
    await codec.save(completions);
  }

  /// Add a single completion event.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> addCompletion(TaskCompletion completion) async {
    final codec = await _getCompletionsCodec();
    await codec.add(completion);
  }

  /// Delete a specific completion event.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> deleteCompletion(TaskCompletion completion) async {
    final codec = await _getCompletionsCodec();
    final key = '${completion.taskType.key}_${completion.plantId}_${completion.completedAt.toIso8601String()}';
    await codec.delete(key, matchKey: (c) => '${c.taskType.key}_${c.plantId}_${c.completedAt.toIso8601String()}');
  }

  /// Delete all task completions for a specific plant.
  ///
  /// Idempotent: succeeds even if plant has no completions.
  Future<void> deleteCompletionsForPlant(String plantId) async {
    final completions = await loadCompletions();
    final remaining = completions.where((c) => c.plantId != plantId).toList();
    await saveCompletions(remaining);
  }

  // --- Custom Care Rules ---

  /// Load all custom care rules.
  ///
  /// Throws [CollectionDecodeFailure], [CollectionShapeFailure], or
  /// [RecordDecodeFailure] when stored data is malformed.
  Future<List<CustomCareRuleEntity>> loadCustomCareRules() async {
    final codec = await _getCustomRulesCodec();
    final result = await codec.load();
    if (result.isFailure) {
      throw result.asFailure!;
    }
    return result.asSuccess;
  }

  /// Save the full list of custom care rules.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> saveCustomCareRules(List<CustomCareRuleEntity> rules) async {
    final codec = await _getCustomRulesCodec();
    await codec.save(rules);
  }

  /// Delete all custom care rules for a specific plant.
  ///
  /// Idempotent: succeeds even if plant has no rules.
  Future<void> deleteCustomRulesForPlant(String plantId) async {
    final rules = await loadCustomCareRules();
    final remaining = rules.where((r) => r.plantId != plantId).toList();
    await saveCustomCareRules(remaining);
  }

  // --- Schedule Actions (Snooze/Skip) ---

  /// Load all active schedule actions.
  ///
  /// Returns a map keyed by `${plantId}_${taskTypeKey}`.
  Future<Map<String, CareScheduleAction>> loadScheduleActions() async {
    final prefs = await _getPrefs();
    final raw = prefs.getString(_scheduleActionsKey);

    if (raw == null || raw.trim().isEmpty) return {};

    dynamic decoded;
    try {
      decoded = jsonDecode(raw);
    } catch (_) {
      throw CollectionDecodeFailure(collection: _scheduleActionsKey);
    }

    if (decoded is! Map<String, dynamic>) {
      throw CollectionShapeFailure(collection: _scheduleActionsKey);
    }

    try {
      return decoded.map(
        (key, value) => MapEntry(key, CareScheduleAction.fromJson(value as Map<String, dynamic>)),
      );
    } catch (_) {
      throw CollectionDecodeFailure(collection: _scheduleActionsKey);
    }
  }

  /// Load a single schedule action for a specific plant and task type.
  Future<CareScheduleAction?> loadScheduleAction(String plantId, CareTaskType taskType) async {
    final actions = await loadScheduleActions();
    return actions['${plantId}_${taskType.key}'];
  }

  /// Save a schedule action, replacing any existing action for the same plant/task pair.
  Future<void> saveScheduleAction(CareScheduleAction action) async {
    final actions = await loadScheduleActions();
    final key = '${action.plantId}_${action.taskType.key}';
    actions[key] = action;
    final prefs = await _getPrefs();
    final json = actions.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_scheduleActionsKey, jsonEncode(json));
  }

  /// Delete the schedule action for a specific plant and task type.
  Future<void> deleteScheduleAction(String plantId, CareTaskType taskType) async {
    final actions = await loadScheduleActions();
    actions.remove('${plantId}_${taskType.key}');
    final prefs = await _getPrefs();
    final json = actions.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_scheduleActionsKey, jsonEncode(json));
  }

  /// Delete all schedule actions for a specific plant.
  Future<void> deleteAllScheduleActionsForPlant(String plantId) async {
    final actions = await loadScheduleActions();
    actions.removeWhere((key, _) => key.startsWith('${plantId}_'));
    final prefs = await _getPrefs();
    final json = actions.map((k, v) => MapEntry(k, v.toJson()));
    await prefs.setString(_scheduleActionsKey, jsonEncode(json));
  }
}
