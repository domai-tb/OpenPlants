import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:open_plants/pages/notifications/notification_entity.dart';
import 'package:open_plants/pages/notifications/notification_repository.dart';

/// Use cases for managing care task notifications.
class NotificationUsecases {
  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationUsecases({
    required NotificationRepository repository,
    required FlutterLocalNotificationsPlugin plugin,
  })  : _repository = repository,
        _plugin = plugin;

  /// Initialize the notification plugin.
  Future<void> initialize() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  /// Check if notifications are enabled.
  Future<bool> areNotificationsEnabled() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.areNotificationsEnabled();
      return granted ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final settings = await ios.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    return false;
  }

  /// Request notification permissions.
  Future<bool> requestPermissions() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  /// Schedule a notification for a care task.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationPayload payload,
  }) async {
    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    const androidDetails = AndroidNotificationDetails(
      'care_reminders',
      'Care Reminders',
      channelDescription: 'Reminders for plant care tasks',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload.encode(),
    );

    // Track in datasource
    await _repository.saveNotification(
      ScheduledNotification(
        id: id,
        plantId: payload.plantId,
        ruleId: payload.ruleId,
        taskType: payload.taskType,
        metricId: payload.metricId,
        scheduledTime: scheduledTime,
      ),
    );
  }

  /// Cancel a scheduled notification.
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    await _repository.deleteNotification(id);
  }

  /// Cancel all notifications for a rule.
  Future<void> cancelNotificationsForRule(String ruleId) async {
    final notifications = await _repository.loadNotifications();
    for (final n in notifications) {
      if (n.ruleId == ruleId) {
        await _plugin.cancel(n.id);
      }
    }
    await _repository.deleteNotificationsForRule(ruleId);
  }

  /// Cancel all notifications for a plant.
  Future<void> cancelNotificationsForPlant(String plantId) async {
    final notifications = await _repository.loadNotifications();
    for (final n in notifications) {
      if (n.plantId == plantId) {
        await _plugin.cancel(n.id);
      }
    }
    await _repository.deleteNotificationsForPlant(plantId);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    await _repository.clearAll();
  }

  /// Get pending notification requests.
  Future<List<PendingNotificationRequest>> getPendingNotifications() =>
      _plugin.pendingNotificationRequests();
}
