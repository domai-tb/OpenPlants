import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:open_plants/pages/notifications/notification_entity.dart';

void main() {
  setUpAll(() {
    tz.initializeTimeZones();
  });

  group('NotificationPayload', () {
    test('encode and decode round trip', () {
      final payload = NotificationPayload(
        plantId: 'plant-1',
        ruleId: 'rule-1',
        taskType: 'watering',
        metricId: 'metric-1',
      );

      final encoded = payload.encode();
      final decoded = NotificationPayload.decode(encoded);

      expect(decoded, isNotNull);
      expect(decoded!.plantId, 'plant-1');
      expect(decoded.ruleId, 'rule-1');
      expect(decoded.taskType, 'watering');
      expect(decoded.metricId, 'metric-1');
    });

    test('decode returns null for invalid input', () {
      expect(NotificationPayload.decode(null), isNull);
      expect(NotificationPayload.decode(''), isNull);
      expect(NotificationPayload.decode('invalid'), isNull);
    });
  });

  group('ScheduledNotification', () {
    test('copyWith preserves fields', () {
      final notification = ScheduledNotification(
        id: 1,
        plantId: 'plant-1',
        ruleId: 'rule-1',
        taskType: 'watering',
        metricId: 'metric-1',
        scheduledTime: DateTime(2026, 1, 1),
      );

      final copied = notification.copyWith(isActive: false);

      expect(copied.id, 1);
      expect(copied.plantId, 'plant-1');
      expect(copied.ruleId, 'rule-1');
      expect(copied.taskType, 'watering');
      expect(copied.metricId, 'metric-1');
      expect(copied.isActive, false);
    });

    test('toJson and fromJson round trip', () {
      final notification = ScheduledNotification(
        id: 1,
        plantId: 'plant-1',
        ruleId: 'rule-1',
        taskType: 'watering',
        metricId: 'metric-1',
        scheduledTime: DateTime(2026, 1, 1),
        isActive: true,
      );

      final json = notification.toJson();
      final restored = ScheduledNotification.fromJson(json);

      expect(restored.id, 1);
      expect(restored.plantId, 'plant-1');
      expect(restored.ruleId, 'rule-1');
      expect(restored.taskType, 'watering');
      expect(restored.metricId, 'metric-1');
      expect(restored.scheduledTime, DateTime(2026, 1, 1));
      expect(restored.isActive, true);
    });
  });

  group('Notification ID generation', () {
    test('stable ID from rule and task type', () {
      int generateId(String ruleId, String taskType) {
        final hash = Object.hash(ruleId, taskType);
        return hash.hashCode & 0x7FFFFFFF;
      }

      final id1 = generateId('rule-1', 'watering');
      final id2 = generateId('rule-1', 'watering');
      final id3 = generateId('rule-1', 'fertilizing');
      final id4 = generateId('rule-2', 'watering');

      expect(id1, equals(id2));
      expect(id1, isNot(equals(id3)));
      expect(id1, isNot(equals(id4)));
    });
  });
}
