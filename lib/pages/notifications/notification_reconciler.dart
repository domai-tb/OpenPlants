import 'package:openplants/pages/notifications/notification_entity.dart';
import 'package:openplants/pages/notifications/notification_repository.dart';
import 'package:openplants/pages/notifications/notification_usecases.dart';

/// Reconciliation service for care task notifications.
///
/// Handles scheduling, updating, and canceling notifications based on
/// care rules, settings, and plant state.
class NotificationReconciler {
  final NotificationRepository _repository;
  final NotificationUsecases _usecases;

  NotificationReconciler({
    required NotificationRepository repository,
    required NotificationUsecases usecases,
  })  : _repository = repository,
        _usecases = usecases;

  /// Reconcile all notifications based on current state.
  ///
  /// This method:
  /// 1. Reads all plants, rules, and settings
  /// 2. Computes next occurrence for each eligible rule
  /// 3. Schedules or updates notifications
  /// 4. Cancels stale notifications
  Future<void> reconcileAll({
    required List<ReconcilerInput> inputs,
    required bool notificationsEnabled,
    required bool notifyDueTasks,
    required bool notifyOverdueTasks,
  }) async {
    // Check if notifications are enabled globally
    if (!notificationsEnabled) {
      await _usecases.cancelAll();
      return;
    }

    // Check permission status
    final hasPermission = await _usecases.areNotificationsEnabled();
    if (!hasPermission) {
      return;
    }

    // Get existing notifications
    final existingNotifications = await _repository.loadNotifications();
    final existingIds = existingNotifications.map((n) => n.id).toSet();

    final newIds = <int>{};

    for (final input in inputs) {
      // Skip if notifications are disabled for this category
      if (input.isOverdue && !notifyOverdueTasks) continue;
      if (!input.isOverdue && !notifyDueTasks) continue;

      // Compute notification ID
      final notificationId = _repository.generateNotificationId(input.ruleId, input.taskType);

      // Check if notification already exists
      if (existingIds.contains(notificationId)) {
        newIds.add(notificationId);
        continue;
      }

      // Schedule new notification
      await _usecases.scheduleNotification(
        id: notificationId,
        title: input.title,
        body: input.body,
        scheduledTime: input.scheduledTime,
        payload: NotificationPayload(
          plantId: input.plantId,
          ruleId: input.ruleId,
          taskType: input.taskType,
          metricId: input.metricId,
        ),
      );

      newIds.add(notificationId);
    }

    // Cancel stale notifications
    for (final notification in existingNotifications) {
      if (!newIds.contains(notification.id)) {
        await _usecases.cancelNotification(notification.id);
      }
    }
  }
}

/// Input data for reconciling a single notification.
class ReconcilerInput {
  final String plantId;
  final String plantName;
  final String ruleId;
  final String taskType;
  final String? metricId;
  final DateTime scheduledTime;
  final bool isOverdue;
  final String title;
  final String body;

  const ReconcilerInput({
    required this.plantId,
    required this.plantName,
    required this.ruleId,
    required this.taskType,
    this.metricId,
    required this.scheduledTime,
    required this.isOverdue,
    required this.title,
    required this.body,
  });
}
