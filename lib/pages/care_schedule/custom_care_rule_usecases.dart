import 'package:open_plant/core/exceptions.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_repository.dart';
import 'package:open_plant/pages/care_schedule/custom_care_rule.dart';

import 'package:uuid/uuid.dart';

/// Use cases for managing custom care rules.
class CustomCareRuleUsecases {
  final CareScheduleRepository repository;

  const CustomCareRuleUsecases({required this.repository});

  /// Create a new custom care rule for a plant.
  Future<CustomCareRuleEntity> create({
    required String plantId,
    required String taskType,
    required int intervalDays,
    bool reminderEnabled = false,
    String? reminderTime,
    List<String>? reminderDays,
  }) async {
    final rule = CustomCareRuleEntity(
      id: const Uuid().v4(),
      plantId: plantId,
      taskType: taskType,
      intervalDays: intervalDays,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      reminderDays: reminderDays,
      createdAt: DateTime.now(),
    );

    await repository.saveCustomCareRule(rule);
    return rule;
  }

  /// Update an existing custom care rule.
  ///
  /// Throws [RuleNotFoundException] if no rule with [ruleId] exists.
  Future<CustomCareRuleEntity> update(
    String ruleId, {
    String? taskType,
    int? intervalDays,
    bool? reminderEnabled,
    String? reminderTime,
    bool clearReminderTime = false,
    List<String>? reminderDays,
    bool clearReminderDays = false,
  }) async {
    final all = await repository.getAllCustomCareRules();
    final matches = all.where((r) => r.id == ruleId);
    final existing = matches.isEmpty ? null : matches.first;
    if (existing == null) throw RuleNotFoundException();

    final updated = existing.copyWith(
      taskType: taskType,
      intervalDays: intervalDays,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      clearReminderTime: clearReminderTime,
      reminderDays: reminderDays,
      clearReminderDays: clearReminderDays,
    );

    await repository.saveCustomCareRule(updated);
    return updated;
  }

  /// Delete a custom care rule by ID.
  ///
  /// Throws [RuleNotFoundException] if no rule with [ruleId] exists.
  Future<void> delete(String ruleId) async {
    final all = await repository.getAllCustomCareRules();
    final exists = all.any((r) => r.id == ruleId);
    if (!exists) throw RuleNotFoundException();

    await repository.deleteCustomCareRule(ruleId);
  }

  /// Toggle the enabled state of a custom care rule.
  ///
  /// Throws [RuleNotFoundException] if no rule with [ruleId] exists.
  Future<CustomCareRuleEntity> toggle(String ruleId) async {
    final all = await repository.getAllCustomCareRules();
    final matches = all.where((r) => r.id == ruleId);
    final existing = matches.isEmpty ? null : matches.first;
    if (existing == null) throw RuleNotFoundException();

    final updated = existing.copyWith(isEnabled: !existing.isEnabled);
    await repository.saveCustomCareRule(updated);
    return updated;
  }

  /// Get all custom care rules for a plant, ordered by creation date.
  Future<List<CustomCareRuleEntity>> getByPlant(String plantId) async {
    return repository.getCustomCareRules(plantId);
  }
}
