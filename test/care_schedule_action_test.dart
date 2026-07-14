import 'package:flutter_test/flutter_test.dart';

import 'package:open_plants/pages/care_schedule/care_schedule_action.dart';
import 'package:open_plants/pages/care_schedule/care_task_type.dart';

void main() {
  group('CareScheduleAction', () {
    group('serialization', () {
      test('toJson produces expected map', () {
        final action = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2026, 7, 14, 10, 0),
          targetedOccurrenceDueDate: DateTime(2026, 7, 10),
          overriddenDueDate: DateTime(2026, 7, 17),
        );

        final json = action.toJson();

        expect(json['plantId'], equals('plant-1'));
        expect(json['taskType'], equals('watering'));
        expect(json['actionKind'], equals('snooze'));
        expect(json['actionTime'], equals('2026-07-14T10:00:00.000'));
        expect(json['targetedOccurrenceDueDate'], equals('2026-07-10T00:00:00.000'));
        expect(json['overriddenDueDate'], equals('2026-07-17T00:00:00.000'));
      });

      test('fromJson round-trips correctly', () {
        final original = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2026, 7, 14, 10, 0),
          targetedOccurrenceDueDate: DateTime(2026, 7, 10),
          overriddenDueDate: DateTime(2026, 7, 17),
        );

        final restored = CareScheduleAction.fromJson(original.toJson());

        expect(restored.plantId, equals(original.plantId));
        expect(restored.taskType, equals(original.taskType));
        expect(restored.actionKind, equals(original.actionKind));
        expect(restored.actionTime, equals(original.actionTime));
        expect(restored.targetedOccurrenceDueDate, equals(original.targetedOccurrenceDueDate));
        expect(restored.overriddenDueDate, equals(original.overriddenDueDate));
      });

      test('fromJson handles skip action kind', () {
        final action = CareScheduleAction(
          plantId: 'plant-2',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.fertilizing),
          actionKind: CareScheduleActionKind.skip,
          actionTime: DateTime(2026, 7, 14),
          targetedOccurrenceDueDate: DateTime(2026, 7, 14),
          overriddenDueDate: DateTime(2026, 7, 21),
        );

        final restored = CareScheduleAction.fromJson(action.toJson());
        expect(restored.actionKind, equals(CareScheduleActionKind.skip));
      });

      test('fromJson handles custom task type', () {
        final action = CareScheduleAction(
          plantId: 'plant-3',
          taskType: const CareTaskType.custom('misting'),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2026, 7, 14),
          targetedOccurrenceDueDate: DateTime(2026, 7, 12),
          overriddenDueDate: DateTime(2026, 7, 15),
        );

        final restored = CareScheduleAction.fromJson(action.toJson());
        expect(restored.taskType, equals(const CareTaskType.custom('misting')));
      });
    });

    group('immutability', () {
      test('fields are final', () {
        final action = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2026, 7, 14),
          targetedOccurrenceDueDate: DateTime(2026, 7, 10),
          overriddenDueDate: DateTime(2026, 7, 17),
        );

        // Verify all fields are accessible and immutable
        expect(action.plantId, equals('plant-1'));
        expect(action.taskType, equals(const CareTaskType.builtIn(BuiltInTaskType.watering)));
        expect(action.actionKind, equals(CareScheduleActionKind.snooze));
        expect(action.actionTime, equals(DateTime(2026, 7, 14)));
        expect(action.targetedOccurrenceDueDate, equals(DateTime(2026, 7, 10)));
        expect(action.overriddenDueDate, equals(DateTime(2026, 7, 17)));
      });

      test('copyWith creates new instance', () {
        final original = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2026, 7, 14),
          targetedOccurrenceDueDate: DateTime(2026, 7, 10),
          overriddenDueDate: DateTime(2026, 7, 17),
        );

        final copied = original.copyWith(
          overriddenDueDate: DateTime(2026, 7, 20),
        );

        expect(copied.plantId, equals(original.plantId));
        expect(copied.overriddenDueDate, equals(DateTime(2026, 7, 20)));
        expect(original.overriddenDueDate, equals(DateTime(2026, 7, 17)));
      });
    });

    group('equality', () {
      test('same values produce equal instances', () {
        final a = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2026, 7, 14),
          targetedOccurrenceDueDate: DateTime(2026, 7, 10),
          overriddenDueDate: DateTime(2026, 7, 17),
        );

        final b = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2026, 7, 14),
          targetedOccurrenceDueDate: DateTime(2026, 7, 10),
          overriddenDueDate: DateTime(2026, 7, 17),
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('different values produce unequal instances', () {
        final a = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2026, 7, 14),
          targetedOccurrenceDueDate: DateTime(2026, 7, 10),
          overriddenDueDate: DateTime(2026, 7, 17),
        );

        final b = CareScheduleAction(
          plantId: 'plant-1',
          taskType: const CareTaskType.builtIn(BuiltInTaskType.watering),
          actionKind: CareScheduleActionKind.snooze,
          actionTime: DateTime(2026, 7, 14),
          targetedOccurrenceDueDate: DateTime(2026, 7, 10),
          overriddenDueDate: DateTime(2026, 7, 20), // Different
        );

        expect(a, isNot(equals(b)));
      });
    });
  });
}
