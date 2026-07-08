import 'package:flutter_test/flutter_test.dart';
import 'package:open_plant/pages/care_schedule/care_task.dart';
import 'package:open_plant/pages/care_schedule/care_task_type.dart';
import 'package:open_plant/pages/care_schedule/overdue_detector.dart';
import 'package:open_plant/pages/care_schedule/pot_type_modifier.dart';
import 'package:open_plant/pages/care_schedule/room_config.dart';
import 'package:open_plant/pages/care_schedule/room_modifier.dart';
import 'package:open_plant/pages/care_schedule/schedule_config.dart';
import 'package:open_plant/pages/care_schedule/schedule_engine.dart';
import 'package:open_plant/pages/care_schedule/species_care_profile.dart';
import 'package:open_plant/pages/care_schedule/task_completion.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_entity.dart';

void main() {
  final today = DateTime(2025, 7, 1); // ignore: avoid_redundant_argument_values

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
  });
}
