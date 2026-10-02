import 'package:flutter_test/flutter_test.dart';
import 'package:openplants/pages/care_schedule/care_schedule_action.dart';
import 'package:openplants/pages/care_schedule/care_task.dart';
import 'package:openplants/pages/care_schedule/care_task_type.dart';
import 'package:openplants/pages/care_schedule/custom_care_rule.dart';
import 'package:openplants/pages/care_schedule/overdue_detector.dart';
import 'package:openplants/pages/care_schedule/pot_type_modifier.dart';
import 'package:openplants/pages/care_schedule/room_config.dart';
import 'package:openplants/pages/care_schedule/room_modifier.dart';
import 'package:openplants/pages/care_schedule/schedule_config.dart';
import 'package:openplants/pages/care_schedule/schedule_engine.dart';
import 'package:openplants/pages/care_schedule/species_care_profile.dart';
import 'package:openplants/pages/care_schedule/task_completion.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:openplants/pages/room_profiles/room_profiles_entity.dart';

void main() {
  final today = DateTime(2025, 7, 1); // ignore: avoid_redundant_argument_values

  group('TaskCompletion', () {
    test('alert episode ID persists and older records remain readable', () {
      final completion = TaskCompletion(
        taskType: const CareTaskType.custom('watering_alert'),
        plantId: 'plant-1',
        completedAt: today,
        alertEpisodeId: 'metric-1:episode-1',
      );

      final restored = TaskCompletion.fromJson(completion.toJson());
      final older = TaskCompletion.fromJson({
        'taskType': 'watering',
        'plantId': 'plant-1',
        'completedAt': today.toIso8601String(),
      });

      expect(restored.alertEpisodeId, 'metric-1:episode-1');
      expect(older.alertEpisodeId, isNull);
    });
  });

  group('OverdueDetector', () {
    test('never completed task is due today', () {
      final status = OverdueDetector.detect(
        today: today,
        lastCompletedAt: null,
        effectiveIntervalDays: 7,
      );
      expect(status, CareTaskStatus.dueToday);
    });

    test('task within interval is upcoming', () {
      final status = OverdueDetector.detect(
        today: today,
        lastCompletedAt: DateTime(2025, 6, 28), // 3 days ago, interval 7
        effectiveIntervalDays: 7,
      );
      expect(status, CareTaskStatus.upcoming);
    });

    test('elapsed interval uses calendar dates instead of time of day', () {
      final status = OverdueDetector.detect(
        today: DateTime(2025, 7, 1, 0, 5),
        lastCompletedAt: DateTime(2025, 6, 30, 23, 55),
        effectiveIntervalDays: 1,
      );

      expect(status, CareTaskStatus.dueToday);
    });

    test('due date labels use calendar dates instead of elapsed hours', () {
      final task = CareTask(
        taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
        plantId: 'plant-1',
        plantName: 'My Pothos',
        dueDate: DateTime(2025, 7, 2, 23, 59),
        status: CareTaskStatus.upcoming,
        effectiveIntervalDays: 1,
      );

      expect(task.daysUntilDue(DateTime(2025, 7, 1, 0, 1)), 1);
    });

    test('task past interval is due today', () {
      final status = OverdueDetector.detect(
        today: today,
        lastCompletedAt: DateTime(2025, 6, 24), // 7 days ago, interval 7
        effectiveIntervalDays: 7,
      );
      expect(status, CareTaskStatus.dueToday);
    });

    test('task past interval + tolerance is overdue', () {
      final status = OverdueDetector.detect(
        today: today,
        lastCompletedAt: DateTime(2025, 6, 20), // 11 days ago, interval 7 (threshold: 8.4)
        effectiveIntervalDays: 7,
      );
      expect(status, CareTaskStatus.overdue);
    });
  });

  group('PotTypeModifier', () {
    test('terracotta shortens watering interval', () {
      final mod = PotTypeModifier.compute(
        taskType: BuiltInTaskType.watering,
        potType: PotType.terracotta,
      );
      expect(mod, 0.8);
    });

    test('plastic is baseline', () {
      final mod = PotTypeModifier.compute(
        taskType: BuiltInTaskType.watering,
        potType: PotType.plastic,
      );
      expect(mod, 1.0);
    });

    test('self-watering lengthens interval', () {
      final mod = PotTypeModifier.compute(
        taskType: BuiltInTaskType.watering,
        potType: PotType.selfWatering,
      );
      expect(mod, 1.5);
    });

    test('non-watering tasks are unaffected', () {
      final mod = PotTypeModifier.compute(
        taskType: BuiltInTaskType.fertilizing,
        potType: PotType.terracotta,
      );
      expect(mod, 1.0);
    });
  });

  group('RoomModifier', () {
    test('full sun shortens watering interval', () {
      final mod = RoomModifier.compute(
        taskType: BuiltInTaskType.watering,
        room: const RoomConfig(
          roomName: 'Test',
          sunlightLevel: SunlightLevel.fullSun,
        ),
      );
      expect(mod, lessThan(1.0));
    });

    test('high humidity lengthens watering interval', () {
      final mod = RoomModifier.compute(
        taskType: BuiltInTaskType.watering,
        room: const RoomConfig(
          roomName: 'Test',
          humidityLevel: HumidityLevel.high,
        ),
      );
      expect(mod, greaterThan(1.0));
    });

    test('missing room config returns 1.0', () {
      final mod = RoomModifier.compute(
        taskType: BuiltInTaskType.watering,
      );
      expect(mod, 1.0);
    });

    test('non-watering/misting tasks are unaffected', () {
      final mod = RoomModifier.compute(
        taskType: BuiltInTaskType.fertilizing,
        room: const RoomConfig(
          roomName: 'Test',
          sunlightLevel: SunlightLevel.fullSun,
        ),
      );
      expect(mod, 1.0);
    });

    test('RoomEntity direct sun shortens watering interval', () {
      final mod = RoomModifier.compute(
        taskType: BuiltInTaskType.watering,
        roomEntity: RoomEntity(
          id: 'room-1',
          name: 'Test',
          lightLevel: RoomLightLevel.directSun,
          createdAt: DateTime(2025),
          updatedAt: DateTime(2025),
        ),
      );
      expect(mod, lessThan(1.0));
    });

    test('RoomEntity high humidity lengthens watering interval', () {
      final mod = RoomModifier.compute(
        taskType: BuiltInTaskType.watering,
        roomEntity: RoomEntity(
          id: 'room-1',
          name: 'Test',
          humidityLevel: RoomHumidityLevel.high,
          createdAt: DateTime(2025),
          updatedAt: DateTime(2025),
        ),
      );
      expect(mod, greaterThan(1.0));
    });

    test('RoomEntity low humidity shortens misting interval', () {
      final mod = RoomModifier.compute(
        taskType: BuiltInTaskType.misting,
        roomEntity: RoomEntity(
          id: 'room-1',
          name: 'Test',
          humidityLevel: RoomHumidityLevel.low,
          createdAt: DateTime(2025),
          updatedAt: DateTime(2025),
        ),
      );
      expect(mod, lessThan(1.0));
    });

    test('RoomEntity non-watering/misting tasks are unaffected', () {
      final mod = RoomModifier.compute(
        taskType: BuiltInTaskType.fertilizing,
        roomEntity: RoomEntity(
          id: 'room-1',
          name: 'Test',
          lightLevel: RoomLightLevel.directSun,
          createdAt: DateTime(2025),
          updatedAt: DateTime(2025),
        ),
      );
      expect(mod, 1.0);
    });
  });

  group('ScheduleEngine', () {
    const testProfile = SpeciesCareProfile(
      id: 'pothos',
      name: 'Pothos',
      defaultIntervals: {
        'watering': 7,
        'fertilizing': 30,
        'misting': 3,
        'pruning': 60,
        'rotating': 14,
        'repotting': 365,
        'leafCleaning': 14,
        'pestInspection': 7,
      },
    );

    test('returns all 8 task types for a plant', () {
      final tasks = ScheduleEngine.computeForPlant(
        input: PlantScheduleInput(
          plantId: 'plant-1',
          plantName: 'My Pothos',
          config: ScheduleConfig.defaults(),
          profile: testProfile,
        ),
        today: today,
      );

      expect(tasks.length, 8);
    });

    test('same inputs produce identical output', () {
      final input = PlantScheduleInput(
        plantId: 'plant-1',
        plantName: 'My Pothos',
        config: ScheduleConfig.defaults(),
        profile: testProfile,
      );

      final tasks1 = ScheduleEngine.computeForPlant(input: input, today: today);
      final tasks2 = ScheduleEngine.computeForPlant(input: input, today: today);

      expect(tasks1.length, tasks2.length);
      for (var i = 0; i < tasks1.length; i++) {
        expect(tasks1[i].taskType, tasks2[i].taskType);
        expect(tasks1[i].dueDate, tasks2[i].dueDate);
        expect(tasks1[i].status, tasks2[i].status);
      }
    });

    test('completion resets the timer', () {
      final history = [
        TaskCompletion(
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          plantId: 'plant-1',
          completedAt: DateTime(2025, 7, 1), // ignore: avoid_redundant_argument_values
        ),
      ];

      final tasks = ScheduleEngine.computeForPlant(
        input: PlantScheduleInput(
          plantId: 'plant-1',
          plantName: 'My Pothos',
          config: ScheduleConfig.defaults(),
          profile: testProfile,
          completionHistory: history,
        ),
        today: today,
      );

      final watering = tasks.firstWhere(
        (t) => t.taskType.builtIn == BuiltInTaskType.watering,
      );
      expect(watering.status, CareTaskStatus.upcoming);
      expect(watering.dueDate, DateTime(2025, 7, 8));
    });

    test('custom task types appear in schedule', () {
      final tasks = ScheduleEngine.computeForPlant(
        input: const PlantScheduleInput(
          plantId: 'plant-1',
          plantName: 'My Pothos',
          config: ScheduleConfig(
            intervalOverrides: {'custom_Check for flowers': 7},
          ),
          profile: testProfile,
          customTaskTypes: [
            CareTaskType.custom('Check for flowers'),
          ],
        ),
        today: today,
      );

      expect(tasks.length, 9); // 8 built-in + 1 custom
      expect(tasks.any((t) => t.taskType.isCustom), isTrue);
    });

    test('terracotta pot shortens watering interval', () {
      final march = DateTime(2025, 3, 1); // ignore: avoid_redundant_argument_values
      final tasks = ScheduleEngine.computeForPlant(
        input: const PlantScheduleInput(
          plantId: 'plant-1',
          plantName: 'My Pothos',
          config: ScheduleConfig(potType: PotType.terracotta),
          profile: testProfile,
        ),
        today: march, // March — seasonal modifier 1.0
      );

      final watering = tasks.firstWhere(
        (t) => t.taskType.builtIn == BuiltInTaskType.watering,
      );
      // 7 days (seasonal 1.0) * 0.8 (terracotta) = 5.6 → 6 days
      expect(watering.effectiveIntervalDays, 6);
    });

    test('custom care rule overrides species default', () {
      final rule = CustomCareRuleEntity(
        id: 'rule-1',
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 10,
        createdAt: DateTime(2025),
      );

      final tasks = ScheduleEngine.computeForPlant(
        input: PlantScheduleInput(
          plantId: 'plant-1',
          plantName: 'My Pothos',
          config: ScheduleConfig.defaults(),
          profile: testProfile,
          customCareRules: [rule],
        ),
        today: today,
      );

      final watering = tasks.firstWhere(
        (t) => t.taskType.builtIn == BuiltInTaskType.watering,
      );
      // Rule says 10 days, no modifiers applied
      expect(watering.effectiveIntervalDays, 10);
    });

    test('disabled custom care rule suppresses task', () {
      final rule = CustomCareRuleEntity(
        id: 'rule-1',
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 10,
        isEnabled: false,
        createdAt: DateTime(2025),
      );

      final tasks = ScheduleEngine.computeForPlant(
        input: PlantScheduleInput(
          plantId: 'plant-1',
          plantName: 'My Pothos',
          config: ScheduleConfig.defaults(),
          profile: testProfile,
          customCareRules: [rule],
        ),
        today: today,
      );

      final watering = tasks.where((t) => t.taskType.builtIn == BuiltInTaskType.watering);
      // Disabled override suppresses computed rule instead of falling back
      expect(watering, isEmpty);
    });

    test('no matching rule uses fallback', () {
      final rule = CustomCareRuleEntity(
        id: 'rule-1',
        plantId: 'plant-1',
        taskType: 'fertilizing',
        intervalDays: 20,
        createdAt: DateTime(2025),
      );

      final tasks = ScheduleEngine.computeForPlant(
        input: PlantScheduleInput(
          plantId: 'plant-1',
          plantName: 'My Pothos',
          config: ScheduleConfig.defaults(),
          profile: testProfile,
          customCareRules: [rule],
        ),
        today: today,
      );

      final watering = tasks.firstWhere(
        (t) => t.taskType.builtIn == BuiltInTaskType.watering,
      );
      // No watering rule → species default (7 days)
      expect(watering.effectiveIntervalDays, 7);
    });

    test('custom rule for user-defined task type adds task', () {
      final rule = CustomCareRuleEntity(
        id: 'rule-1',
        plantId: 'plant-1',
        taskType: 'Check for flowers',
        intervalDays: 7,
        createdAt: DateTime(2025),
      );

      final tasks = ScheduleEngine.computeForPlant(
        input: PlantScheduleInput(
          plantId: 'plant-1',
          plantName: 'My Pothos',
          config: ScheduleConfig.defaults(),
          profile: testProfile,
          customCareRules: [rule],
        ),
        today: today,
      );

      // 8 built-in + 1 from rule
      expect(tasks.length, 9);
      final customTask = tasks.firstWhere((t) => t.taskType.isCustom);
      expect(customTask.effectiveIntervalDays, 7);
    });

    test('custom rule bypasses room and pot modifiers', () {
      final rule = CustomCareRuleEntity(
        id: 'rule-1',
        plantId: 'plant-1',
        taskType: 'watering',
        intervalDays: 10,
        createdAt: DateTime(2025),
      );

      final march = DateTime(2025, 3, 1); // ignore: avoid_redundant_argument_values
      final tasks = ScheduleEngine.computeForPlant(
        input: PlantScheduleInput(
          plantId: 'plant-1',
          plantName: 'My Pothos',
          config: const ScheduleConfig(potType: PotType.terracotta),
          roomConfig: const RoomConfig(
            roomName: 'Test',
            sunlightLevel: SunlightLevel.fullSun,
          ),
          profile: testProfile,
          customCareRules: [rule],
        ),
        today: march,
      );

      final watering = tasks.firstWhere(
        (t) => t.taskType.builtIn == BuiltInTaskType.watering,
      );
      // Rule interval used directly, modifiers ignored
      expect(watering.effectiveIntervalDays, 10);
    });

    test('room and plant light do not change misting intervals', () {
      final tasks = ScheduleEngine.computeForPlant(
        input: PlantScheduleInput(
          plantId: 'plant-1',
          plantName: 'My Pothos',
          config: ScheduleConfig.defaults(),
          profile: testProfile,
          lightLevel: LightLevel.direct,
          roomEntity: RoomEntity(
            id: 'room-1',
            name: 'Sunny room',
            lightLevel: RoomLightLevel.directSun,
            createdAt: DateTime(2025),
            updatedAt: DateTime(2025),
          ),
        ),
        today: today,
      );

      final misting = tasks.firstWhere((task) => task.taskType.builtIn == BuiltInTaskType.misting);
      expect(misting.effectiveIntervalDays, 3);
    });

    group('schedule actions', () {
      test('snooze overrides due date', () {
        final action = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2025, 7, 1), // ignore: avoid_redundant_argument_values
          targetedOccurrenceDueDate: DateTime(2025, 7, 1), // ignore: avoid_redundant_argument_values
          overriddenDueDate: DateTime(2025, 7, 8),
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'My Pothos',
            config: ScheduleConfig.defaults(),
            profile: testProfile,
            activeScheduleActions: [action],
          ),
          today: today,
        );

        final watering = tasks.firstWhere(
          (t) => t.taskType.builtIn == BuiltInTaskType.watering,
        );
        expect(watering.dueDate, DateTime(2025, 7, 8));
        expect(watering.status, CareTaskStatus.upcoming);
      });

      test('skip advances due date by one effective interval', () {
        final action = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.skip,
          actionTime: DateTime(2025, 7, 1), // ignore: avoid_redundant_argument_values
          targetedOccurrenceDueDate: DateTime(2025, 7, 1), // ignore: avoid_redundant_argument_values
          overriddenDueDate: DateTime(2025, 7, 8), // 7 days from current due date
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'My Pothos',
            config: ScheduleConfig.defaults(),
            profile: testProfile,
            activeScheduleActions: [action],
          ),
          today: today,
        );

        final watering = tasks.firstWhere(
          (t) => t.taskType.builtIn == BuiltInTaskType.watering,
        );
        expect(watering.dueDate, DateTime(2025, 7, 8));
        expect(watering.status, CareTaskStatus.upcoming);
      });

      test('stale action is ignored', () {
        final action = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2025, 6, 15),
          targetedOccurrenceDueDate: DateTime(2025, 6, 20), // Old occurrence
          overriddenDueDate: DateTime(2025, 6, 25), // Old override
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'My Pothos',
            config: ScheduleConfig.defaults(),
            profile: testProfile,
            completionHistory: [
              TaskCompletion(
                taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
                plantId: 'plant-1',
                completedAt: DateTime(2025, 6, 28),
              ),
            ],
            activeScheduleActions: [action],
          ),
          today: today,
        );

        final watering = tasks.firstWhere(
          (t) => t.taskType.builtIn == BuiltInTaskType.watering,
        );
        // Action is stale, so the due date is based on the latest completion.
        expect(watering.dueDate, DateTime(2025, 7, 5));
        expect(watering.status, CareTaskStatus.upcoming);
      });

      test('keeps action on the same uncompleted occurrence across days', () {
        final action = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2025, 7, 1, 10),
          targetedOccurrenceDueDate: DateTime(2025, 7, 1, 8),
          overriddenDueDate: DateTime(2025, 7, 4, 10),
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'My Pothos',
            config: ScheduleConfig.defaults(),
            profile: testProfile,
            activeScheduleActions: [action],
          ),
          today: DateTime(2025, 7, 2, 14),
        );

        final watering = tasks.firstWhere((task) => task.taskType.builtIn == BuiltInTaskType.watering);
        expect(watering.dueDate, DateTime(2025, 7, 4));
        expect(watering.scheduleOccurrenceDueDate, DateTime(2025, 7));
      });

      test('action does not replace completion anchor', () {
        final completion = TaskCompletion(
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          plantId: 'plant-1',
          completedAt: DateTime(2025, 6, 28),
        );

        final action = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2025, 7, 1), // ignore: avoid_redundant_argument_values
          targetedOccurrenceDueDate: DateTime(2025, 7, 5),
          overriddenDueDate: DateTime(2025, 7, 10), // Snoozed to July 10
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'My Pothos',
            config: ScheduleConfig.defaults(),
            profile: testProfile,
            completionHistory: [completion],
            activeScheduleActions: [action],
          ),
          today: today,
        );

        final watering = tasks.firstWhere(
          (t) => t.taskType.builtIn == BuiltInTaskType.watering,
        );
        // Due date is the snoozed date, not completion-based
        expect(watering.dueDate, DateTime(2025, 7, 10));
        // But completedAt still reflects the genuine completion
        expect(watering.completedAt, DateTime(2025, 6, 28));
      });
    });

    group('Metric-linked rules', () {
      test('metric care task is generated once for an active care-task alert', () {
        final rules = [
          CustomCareRuleEntity(
            id: 'rule-1',
            plantId: 'plant-1',
            taskType: 'watering',
            intervalDays: 7,
            metricId: 'metric-1',
            createdAt: today,
          ),
          CustomCareRuleEntity(
            id: 'rule-2',
            plantId: 'plant-1',
            taskType: 'fertilizing',
            intervalDays: 14,
            metricId: 'metric-1',
            createdAt: today,
          ),
        ];

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'Test Plant',
            config: const ScheduleConfig(),
            profile: testProfile,
            customCareRules: rules,
            careTaskMetricIds: {'metric-1'},
            activeAlertEpisodeIds: {'metric-1': 'metric-1:episode-1'},
            metricNamesById: {'metric-1': 'Soil moisture'},
          ),
          today: today,
        );

        final alertTasks = tasks.where((task) => task.alertEpisodeId != null).toList();
        expect(alertTasks, hasLength(1));
        expect(alertTasks.single.alertEpisodeId, 'metric-1:episode-1');
        expect(alertTasks.single.taskType, const CareTaskType.custom('metric_alert:metric-1'));
        expect(alertTasks.single.alertMetricName, 'Soil moisture');
      });

      test('metric-linked rule anchors from newest measurement', () {
        final rule = CustomCareRuleEntity(
          id: 'rule-1',
          plantId: 'plant-1',
          taskType: 'watering',
          intervalDays: 3,
          metricId: 'metric-1',
          createdAt: today,
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'Test Plant',
            config: const ScheduleConfig(),
            profile: testProfile,
            customCareRules: [rule],
            metricLatestMeasurementTimes: {
              'metric-1': DateTime(2025, 6, 25), // 6 days ago
            },
          ),
          today: today,
        );

        final watering = tasks.firstWhere(
          (t) => t.taskType.builtIn == BuiltInTaskType.watering,
        );
        // Due date = measurement time + interval = 6/25 + 3 = 6/28
        expect(watering.dueDate, DateTime(2025, 6, 28));
        expect(watering.status, CareTaskStatus.overdue);
      });

      test('metric-linked rule without measurement uses today', () {
        final rule = CustomCareRuleEntity(
          id: 'rule-1',
          plantId: 'plant-1',
          taskType: 'watering',
          intervalDays: 3,
          metricId: 'metric-1',
          createdAt: today,
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'Test Plant',
            config: const ScheduleConfig(),
            profile: testProfile,
            customCareRules: [rule],
            metricLatestMeasurementTimes: {},
          ),
          today: today,
        );

        final watering = tasks.firstWhere(
          (t) => t.taskType.builtIn == BuiltInTaskType.watering,
        );
        // No measurement => anchor from today
        expect(watering.dueDate, today);
      });

      test('metric-linked rule without an active care-task alert emits no alert task', () {
        final rule = CustomCareRuleEntity(
          id: 'rule-1',
          plantId: 'plant-1',
          taskType: 'watering',
          intervalDays: 7,
          metricId: 'metric-1',
          createdAt: today,
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'Test Plant',
            config: const ScheduleConfig(),
            profile: testProfile,
            customCareRules: [rule],
            careTaskMetricIds: {'metric-1'},
            activeAlertEpisodeIds: {},
          ),
          today: today,
        );

        expect(tasks.where((task) => task.alertEpisodeId != null), isEmpty);
      });

      test('warning-configured metric does not emit a care task', () {
        final rule = CustomCareRuleEntity(
          id: 'rule-1',
          plantId: 'plant-1',
          taskType: 'watering',
          intervalDays: 7,
          metricId: 'metric-1',
          createdAt: today,
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'Test Plant',
            config: const ScheduleConfig(),
            profile: testProfile,
            customCareRules: [rule],
            // The active episode map can be populated for warning metrics too;
            // only metrics configured for care tasks should create a task.
            activeAlertEpisodeIds: {'metric-1': 'metric-1:episode-1'},
          ),
          today: today,
        );

        expect(tasks.where((task) => task.alertEpisodeId != null), isEmpty);
      });

      test('completed alert episode suppresses alert task', () {
        final rule = CustomCareRuleEntity(
          id: 'rule-1',
          plantId: 'plant-1',
          taskType: 'watering',
          intervalDays: 7,
          metricId: 'metric-1',
          createdAt: today,
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'Test Plant',
            config: const ScheduleConfig(),
            profile: testProfile,
            customCareRules: [rule],
            careTaskMetricIds: {'metric-1'},
            activeAlertEpisodeIds: {'metric-1': 'metric-1:episode-1'},
            completedAlertEpisodeIds: {'metric-1:episode-1'},
          ),
          today: today,
        );

        // Alert task should not be generated for completed episode
        final alertTasks = tasks.where(
          (t) => t.taskType.customName == 'watering_alert',
        );
        expect(alertTasks, isEmpty);
      });

      test('new alert episode creates a task after an earlier episode was completed', () {
        final rule = CustomCareRuleEntity(
          id: 'rule-1',
          plantId: 'plant-1',
          taskType: 'watering',
          intervalDays: 7,
          metricId: 'metric-1',
          createdAt: today,
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'Test Plant',
            config: const ScheduleConfig(),
            profile: testProfile,
            customCareRules: [rule],
            careTaskMetricIds: {'metric-1'},
            activeAlertEpisodeIds: {'metric-1': 'metric-1:episode-2'},
            completedAlertEpisodeIds: {'metric-1:episode-1'},
          ),
          today: today,
        );

        final alertTasks = tasks.where((task) => task.alertEpisodeId != null).toList();
        expect(alertTasks, hasLength(1));
        expect(alertTasks.single.alertEpisodeId, 'metric-1:episode-2');
      });

      test('disabled metric suppresses its measurement reminder and alert task', () {
        final rule = CustomCareRuleEntity(
          id: 'rule-1',
          plantId: 'plant-1',
          taskType: 'watering',
          intervalDays: 7,
          metricId: 'metric-1',
          createdAt: today,
        );

        final tasks = ScheduleEngine.computeForPlant(
          input: PlantScheduleInput(
            plantId: 'plant-1',
            plantName: 'Test Plant',
            config: const ScheduleConfig(),
            profile: testProfile,
            customCareRules: [rule],
            metricLatestMeasurementTimes: {'metric-1': DateTime(2025, 6, 20)},
            careTaskMetricIds: {'metric-1'},
            activeAlertEpisodeIds: {'metric-1': 'metric-1:episode-1'},
            disabledMetricIds: {'metric-1'},
          ),
          today: today,
        );

        expect(tasks.where((task) => task.taskType.builtIn == BuiltInTaskType.watering), isEmpty);
        expect(tasks.where((task) => task.alertEpisodeId != null), isEmpty);
      });
    });
  });
}
