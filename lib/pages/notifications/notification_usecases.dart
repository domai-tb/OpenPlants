import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:openplants/pages/notifications/notification_entity.dart';
import 'package:openplants/pages/notifications/notification_repository.dart';

/// Use cases for managing care task notifications.
class NotificationUsecases {
  static const MethodChannel _timezoneChannel = MethodChannel('openplants/local_timezone');
  static const EventChannel _timezoneChangesChannel = EventChannel('openplants/timezone_changes');

  final NotificationRepository _repository;
  final FlutterLocalNotificationsPlugin _plugin;
  bool _hasResolvedLocalTimezone = false;

  bool get hasResolvedLocalTimezone => _hasResolvedLocalTimezone;

  NotificationUsecases({
    required NotificationRepository repository,
    required FlutterLocalNotificationsPlugin plugin,
  })  : _repository = repository,
        _plugin = plugin;

  /// Initialize the notification plugin.
  Future<NotificationPayload?> initialize({required void Function(NotificationPayload) onNotificationTap}) async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(
      settings: settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = NotificationPayload.decode(response.payload);
        if (payload != null) onNotificationTap(payload);
      },
    );

    final launchDetails = await _plugin.getNotificationAppLaunchDetails();
    return launchDetails?.didNotificationLaunchApp == true
        ? NotificationPayload.decode(launchDetails?.notificationResponse?.payload)
        : null;
  }

  /// Update the timezone database location from the operating system.
  Future<bool> refreshLocalTimezone() async {
    _hasResolvedLocalTimezone = false;
    try {
      final timezoneId = await _timezoneChannel.invokeMethod<String>('getLocalTimezone');
      final location = timezoneId == null ? null : tz.timeZoneDatabase.locations[timezoneId];
      if (location == null) return false;
      tz.setLocalLocation(location);
      _hasResolvedLocalTimezone = true;
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Emits when Android reports that the device timezone changed.
  Stream<String> get localTimezoneChanges =>
      _timezoneChangesChannel.receiveBroadcastStream().where((value) => value is String).cast<String>();

  /// Check if notifications are enabled.
  Future<bool> areNotificationsEnabled() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.areNotificationsEnabled();
        return granted ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final settings = await ios.checkPermissions();
        return settings?.isEnabled ?? false;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  /// Request notification permissions.
  Future<bool> requestPermissions() async {
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        final granted = await android.requestNotificationsPermission();
        return granted ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        final granted = await ios.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
        return granted ?? false;
      }
    } catch (_) {
      return false;
    }
    return false;
  }

  /// Open the operating system's app notification settings.
  Future<bool> openNotificationSettings() async {
    try {
      return await openAppSettings();
    } catch (_) {
      return false;
    }
  }

  /// Schedule a notification for a care task.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    required NotificationPayload payload,
    required String channelName,
    required String channelDescription,
  }) async {
    final tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'care_reminders',
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    final details = NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduled,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: payload.encode(),
    );
    try {
      await _repository.saveNotification(
        ScheduledNotification(
          id: id,
          plantId: payload.plantId,
          ruleId: payload.ruleId,
          taskType: payload.taskType,
          metricId: payload.metricId,
          scheduledTime: scheduledTime,
          title: title,
          body: body,
        ),
      );
    } catch (error, stackTrace) {
      try {
        await _plugin.cancel(id: id);
      } catch (cleanupError) {
        debugPrint('Failed to cancel untracked notification $id: $cleanupError');
      }
      Error.throwWithStackTrace(error, stackTrace);
    }
  }

  /// Cancel a scheduled notification.
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id: id);
    await _repository.deleteNotification(id);
  }

  /// Cancel all notifications.
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    await _repository.clearAll();
  }

  /// Get pending notification requests.
  Future<List<PendingNotificationRequest>> getPendingNotifications() => _plugin.pendingNotificationRequests();
}
