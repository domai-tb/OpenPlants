import 'package:flutter/foundation.dart';

import 'package:openplants/core/exceptions.dart';
import 'package:openplants/pages/care_schedule/care_schedule_repository.dart';
import 'package:openplants/pages/care_schedule/custom_care_rule.dart';

import 'package:uuid/uuid.dart';

/// Use cases for managing custom care rules.
class CustomCareRuleUsecases {
  final CareScheduleRepository repository;
  final Future<void> Function()? onNotificationsChanged;

  const CustomCareRuleUsecases({required this.repository, this.onNotificationsChanged});

  /// Create a new custom care rule for a plant.
  Future<CustomCareRuleEntity> create({
    required String plantId,
    required String taskType,
    required int intervalDays,
    bool reminderEnabled = false,
    String? reminderTime,
    List<String>? reminderDays,
    String? metricId,
    bool isMeasurementRequired = false,
    bool isEnabled = true,
  }) async {
    final existing = await repository.getCustomCareRules(plantId);
    if (existing.any((rule) => rule.taskType == taskType)) {
      throw StateError('A care rule for "$taskType" already exists on plant "$plantId".');
    }

    final rule = CustomCareRuleEntity(
      id: const Uuid().v4(),
      plantId: plantId,
      taskType: taskType,
      intervalDays: intervalDays,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      reminderDays: reminderDays,
      createdAt: DateTime.now(),
      metricId: metricId,
      isMeasurementRequired: isMeasurementRequired,
      isEnabled: isEnabled,
    );

    await repository.saveCustomCareRule(rule);
    await _syncNotifications();
    return rule;
  }

  /// Update an existing custom care rule.
  ///
  /// Throws [RuleNotFoundException] if no rule with [ruleId] exists.
  Future<CustomCareRuleEntity> update(
    String ruleId, {
    int? intervalDays,
    bool? reminderEnabled,
    String? reminderTime,
    bool clearReminderTime = false,
    List<String>? reminderDays,
    bool clearReminderDays = false,
    String? metricId,
    bool clearMetricId = false,
    bool? isMeasurementRequired,
  }) async {
    final all = await repository.getAllCustomCareRules();
    final matches = all.where((r) => r.id == ruleId);
    final existing = matches.isEmpty ? null : matches.first;
    if (existing == null) throw RuleNotFoundException();

    final updated = existing.copyWith(
      intervalDays: intervalDays,
      reminderEnabled: reminderEnabled,
      reminderTime: reminderTime,
      clearReminderTime: clearReminderTime,
      reminderDays: reminderDays,
      clearReminderDays: clearReminderDays,
      metricId: metricId,
      clearMetricId: clearMetricId,
      isMeasurementRequired: isMeasurementRequired,
    );

    await repository.saveCustomCareRule(updated);
    await _syncNotifications();
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
    await _syncNotifications();
  }

  /// Deletes rules linked to [metricId] around the metric deletion.
  ///
  /// If metric persistence fails, the linked rules are restored before the
  /// original error is rethrown.
  Future<void> deleteForMetric(String metricId, Future<void> Function() deleteMetric) async {
    final removedRules = await repository.deleteCustomCareRulesForMetric(metricId);
    try {
      await deleteMetric();
    } catch (error, stackTrace) {
      try {
        await repository.restoreCustomCareRules(removedRules);
      } catch (rollbackError) {
        debugPrint('Failed to restore metric-linked care rules after delete failure: $rollbackError');
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
    if (removedRules.isNotEmpty) await _syncNotifications();
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
    await _syncNotifications();
    return updated;
  }

  /// Get all custom care rules for a plant, ordered by creation date.
  Future<List<CustomCareRuleEntity>> getByPlant(String plantId) async {
    return repository.getCustomCareRules(plantId);
  }

  /// Check if a custom rule exists for a given task type on a plant.
  Future<bool> hasCustomRuleForTaskType(String plantId, String taskType) async {
    final rules = await repository.getCustomCareRules(plantId);
    return rules.any((r) => r.taskType == taskType);
  }

  /// Create or update a custom override for a computed rule.
  ///
  /// If a custom rule with [taskType] already exists for [plantId], it is
  /// updated. Otherwise, a new rule is created.
  Future<CustomCareRuleEntity> createOrUpdateOverride({
    required String plantId,
    required String taskType,
    required int intervalDays,
    bool? isEnabled,
    bool? reminderEnabled,
    String? reminderTime,
    bool clearReminderTime = false,
    List<String>? reminderDays,
    bool clearReminderDays = false,
  }) async {
    final rules = await repository.getCustomCareRules(plantId);
    final existing = rules.where((r) => r.taskType == taskType);

    if (existing.isNotEmpty) {
      final updated = existing.first.copyWith(
        intervalDays: intervalDays,
        isEnabled: isEnabled,
        reminderEnabled: reminderEnabled,
        reminderTime: reminderTime,
        clearReminderTime: clearReminderTime,
        reminderDays: reminderDays,
        clearReminderDays: clearReminderDays,
      );
      await repository.saveCustomCareRule(updated);
      await _syncNotifications();
      return updated;
    }

    return create(
      plantId: plantId,
      taskType: taskType,
      intervalDays: intervalDays,
      isEnabled: isEnabled ?? true,
      reminderEnabled: reminderEnabled ?? false,
      reminderTime: reminderTime,
      reminderDays: reminderDays,
    );
  }

  Future<void> _syncNotifications() async {
    try {
      await onNotificationsChanged?.call();
    } catch (error) {
      debugPrint('Failed to sync notifications after care rule change: $error');
    }
  }
}
