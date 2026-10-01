import 'package:flutter_test/flutter_test.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'package:openplants/pages/notifications/notification_entity.dart';
import 'package:openplants/pages/notifications/notification_datasource.dart';
import 'package:openplants/pages/notifications/notification_repository.dart';

void main() {
  setUpAll(tz.initializeTimeZones);

  group('NotificationPayload', () {
    test('encode and decode round trip', () {
      const payload = NotificationPayload(
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

    test('decode preserves percent sequences in JSON values', () {
      const payload = NotificationPayload(
        plantId: 'plant-%20-100%',
        ruleId: 'rule-1',
        taskType: 'watering',
      );

      expect(NotificationPayload.decode(payload.encode())?.plantId, payload.plantId);
    });
  });

  group('ScheduledNotification', () {
    test('copyWith preserves persisted fields', () {
      final notification = ScheduledNotification(
        id: 1,
        plantId: 'plant-1',
        ruleId: 'rule-1',
        taskType: 'watering',
        metricId: 'metric-1',
        scheduledTime: DateTime(2026),
        title: 'Care reminder',
        body: 'Water the fern',
      );

      final copied = notification.copyWith(body: 'Water the fern today');

      expect(copied.id, 1);
      expect(copied.plantId, 'plant-1');
      expect(copied.ruleId, 'rule-1');
      expect(copied.taskType, 'watering');
      expect(copied.metricId, 'metric-1');
      expect(copied.title, 'Care reminder');
      expect(copied.body, 'Water the fern today');
    });

    test('toJson and fromJson round trip', () {
      final notification = ScheduledNotification(
        id: 1,
        plantId: 'plant-1',
        ruleId: 'rule-1',
        taskType: 'watering',
        metricId: 'metric-1',
        scheduledTime: DateTime(2026),
      );

      final json = notification.toJson();
      final restored = ScheduledNotification.fromJson(json);

      expect(restored.id, 1);
      expect(restored.plantId, 'plant-1');
      expect(restored.ruleId, 'rule-1');
      expect(restored.taskType, 'watering');
      expect(restored.metricId, 'metric-1');
      expect(restored.scheduledTime, DateTime(2026));
      expect(restored.title, '');
      expect(restored.body, '');
    });

    test('reads older persisted records without localized content', () {
      final restored = ScheduledNotification.fromJson({
        'id': 1,
        'plantId': 'plant-1',
        'ruleId': 'rule-1',
        'taskType': 'watering',
        'scheduledTime': DateTime(2026).toIso8601String(),
      });

      expect(restored.title, '');
      expect(restored.body, '');
    });
  });

  group('Notification ID generation', () {
    test('stable ID from plant and rule', () {
      final repository = NotificationRepository(datasource: NotificationDataSource());

      expect(repository.generateNotificationId('plant-1', 'rule-1'), 1386689636);
      expect(
        repository.generateNotificationId('plant-1', 'rule-1'),
        repository.generateNotificationId('plant-1', 'rule-1'),
      );
      expect(
        repository.generateNotificationId('plant-1', 'rule-1'),
        isNot(repository.generateNotificationId('plant-2', 'rule-1')),
      );
      expect(
        repository.generateNotificationId('plant-1', 'rule-1'),
        isNot(repository.generateNotificationId('plant-1', 'rule-2')),
      );
    });
  });
}
