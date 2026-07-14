import 'package:flutter_test/flutter_test.dart';
import 'package:open_plants/core/exceptions.dart';
import 'package:open_plants/pages/care_schedule/care_schedule_datasource.dart';
import 'package:open_plants/pages/care_schedule/care_schedule_repository.dart';
import 'package:open_plants/pages/care_schedule/custom_care_rule.dart';
import 'package:open_plants/pages/care_schedule/custom_care_rule_usecases.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late CareScheduleDataSource dataSource;
  late CareScheduleRepository repository;
  late CustomCareRuleUsecases usecases;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dataSource = CareScheduleDataSource();
    repository = CareScheduleRepository(dataSource: dataSource);
    usecases = CustomCareRuleUsecases(repository: repository);
  });

  group('CustomCareRuleEntity', () {
    test('serialization roundtrip preserves all fields', () {
      final rule = CustomCareRuleEntity(
        id: 'test-id',
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 7,
        reminderEnabled: true,
        reminderTime: '09:00',
        reminderDays: ['monday', 'wednesday'],
        isEnabled: false,
        createdAt: DateTime(2025, 1, 15, 10, 30),
      );

      final json = rule.toJson();
      final restored = CustomCareRuleEntity.fromJson(json);

      expect(restored.id, rule.id);
      expect(restored.plantId, rule.plantId);
      expect(restored.taskType, rule.taskType);
      expect(restored.intervalDays, rule.intervalDays);
      expect(restored.reminderEnabled, rule.reminderEnabled);
      expect(restored.reminderTime, rule.reminderTime);
      expect(restored.reminderDays, rule.reminderDays);
      expect(restored.isEnabled, rule.isEnabled);
      expect(restored.createdAt, rule.createdAt);
    });

    test('copyWith creates modified copy', () {
      final rule = CustomCareRuleEntity(
        id: 'test-id',
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 7,
        createdAt: DateTime(2025),
      );

      final updated = rule.copyWith(intervalDays: 14, isEnabled: false);

      expect(updated.id, rule.id);
      expect(updated.intervalDays, 14);
      expect(updated.isEnabled, false);
      expect(rule.intervalDays, 7); // original unchanged
    });
  });

  group('CustomCareRuleUsecases', () {
    test('create generates UUID and persists rule', () async {
      final rule = await usecases.create(
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 7,
      );

      expect(rule.id.isNotEmpty, true);
      expect(rule.plantId, 'plant-1');
      expect(rule.taskType, 'watering');
      expect(rule.intervalDays, 7);
      expect(rule.isEnabled, true);
      expect(rule.reminderEnabled, false);
    });

    test('create with reminder config', () async {
      final rule = await usecases.create(
        plantId: 'plant-1',
        taskType: 'fertilizing',
        intervalDays: 30,
        reminderEnabled: true,
        reminderTime: '08:30',
        reminderDays: ['monday', 'thursday'],
      );

      expect(rule.reminderEnabled, true);
      expect(rule.reminderTime, '08:30');
      expect(rule.reminderDays, ['monday', 'thursday']);
    });

    test('getByPlant returns rules ordered by creation date', () async {
      await usecases.create(plantId: 'plant-1', taskType: 'A', intervalDays: 1);
      await usecases.create(plantId: 'plant-1', taskType: 'B', intervalDays: 2);
      await usecases.create(plantId: 'plant-2', taskType: 'C', intervalDays: 3);
      await usecases.create(plantId: 'plant-1', taskType: 'D', intervalDays: 4);

      final rules = await usecases.getByPlant('plant-1');

      expect(rules.length, 3);
      expect(rules[0].taskType, 'A');
      expect(rules[1].taskType, 'B');
      expect(rules[2].taskType, 'D');
    });

    test('update modifies existing rule', () async {
      final created = await usecases.create(
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 7,
      );

      final updated = await usecases.update(
        created.id,
        intervalDays: 14,
        reminderEnabled: true,
        reminderTime: '09:00',
      );

      expect(updated.id, created.id);
      expect(updated.intervalDays, 14);
      expect(updated.reminderEnabled, true);
      expect(updated.reminderTime, '09:00');
    });

    test('update throws RuleNotFoundException for non-existent rule', () async {
      expect(
        () => usecases.update('nonexistent', intervalDays: 14),
        throwsA(isA<RuleNotFoundException>()),
      );
    });

    test('update clears reminder when disabled', () async {
      final created = await usecases.create(
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 7,
        reminderEnabled: true,
        reminderTime: '09:00',
        reminderDays: ['monday'],
      );

      final updated = await usecases.update(
        created.id,
        reminderEnabled: false,
        clearReminderTime: true,
        clearReminderDays: true,
      );

      expect(updated.reminderEnabled, false);
      expect(updated.reminderTime, null);
      expect(updated.reminderDays, null);
    });

    test('delete removes rule', () async {
      final created = await usecases.create(
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 7,
      );

      await usecases.delete(created.id);

      final rules = await usecases.getByPlant('plant-1');
      expect(rules.isEmpty, true);
    });

    test('delete throws RuleNotFoundException for non-existent rule', () async {
      expect(
        () => usecases.delete('nonexistent'),
        throwsA(isA<RuleNotFoundException>()),
      );
    });

    test('toggle switches enabled state', () async {
      final created = await usecases.create(
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 7,
      );

      expect(created.isEnabled, true);

      final toggled = await usecases.toggle(created.id);
      expect(toggled.isEnabled, false);

      final toggledBack = await usecases.toggle(toggled.id);
      expect(toggledBack.isEnabled, true);
    });

    test('toggle throws RuleNotFoundException for non-existent rule', () async {
      expect(
        () => usecases.toggle('nonexistent'),
        throwsA(isA<RuleNotFoundException>()),
      );
    });
  });

  group('CareScheduleRepository - Custom Care Rules', () {
    test('getCustomCareRules returns empty list for new plant', () async {
      final rules = await repository.getCustomCareRules('plant-1');
      expect(rules.isEmpty, true);
    });

    test('saveCustomCareRule and getCustomCareRules roundtrip', () async {
      final rule = CustomCareRuleEntity(
        id: 'test-id',
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 7,
        createdAt: DateTime(2025),
      );

      await repository.saveCustomCareRule(rule);
      final rules = await repository.getCustomCareRules('plant-1');

      expect(rules.length, 1);
      expect(rules.first.id, 'test-id');
    });

    test('saveCustomCareRule updates existing rule with same ID', () async {
      final rule = CustomCareRuleEntity(
        id: 'test-id',
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 7,
        createdAt: DateTime(2025),
      );

      await repository.saveCustomCareRule(rule);

      final updated = rule.copyWith(intervalDays: 14);
      await repository.saveCustomCareRule(updated);

      final rules = await repository.getCustomCareRules('plant-1');
      expect(rules.length, 1);
      expect(rules.first.intervalDays, 14);
    });

    test('deleteCustomCareRule removes rule', () async {
      final rule = CustomCareRuleEntity(
        id: 'test-id',
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 7,
        createdAt: DateTime(2025),
      );

      await repository.saveCustomCareRule(rule);
      await repository.deleteCustomCareRule('test-id');

      final rules = await repository.getCustomCareRules('plant-1');
      expect(rules.isEmpty, true);
    });

    test('getAllCustomCareRules returns all rules across plants', () async {
      await repository.saveCustomCareRule(
        CustomCareRuleEntity(
          id: 'r1',
          plantId: 'plant-1',
          taskType: 'A',
          intervalDays: 1,
          createdAt: DateTime(2025),
        ),
      );
      await repository.saveCustomCareRule(
        CustomCareRuleEntity(
          id: 'r2',
          plantId: 'plant-2',
          taskType: 'B',
          intervalDays: 2,
          createdAt: DateTime(2025),
        ),
      );

      final all = await repository.getAllCustomCareRules();
      expect(all.length, 2);
    });
  });
}
