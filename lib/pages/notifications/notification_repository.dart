import 'package:openplants/pages/notifications/notification_datasource.dart';
import 'package:openplants/pages/notifications/notification_entity.dart';

/// Repository for managing scheduled notifications.
class NotificationRepository {
  final NotificationDataSource _datasource;

  NotificationRepository({required NotificationDataSource datasource}) : _datasource = datasource;

  Future<List<ScheduledNotification>> loadNotifications() => _datasource.loadNotifications();

  Future<void> saveNotification(ScheduledNotification notification) => _datasource.saveNotification(notification);

  Future<void> deleteNotification(int id) => _datasource.deleteNotification(id);

  Future<void> deleteNotificationsForRule(String ruleId) => _datasource.deleteNotificationsForRule(ruleId);

  Future<void> deleteNotificationsForPlant(String plantId) => _datasource.deleteNotificationsForPlant(plantId);

  Future<void> clearAll() => _datasource.clearAll();

  /// Generate a stable integer ID from rule ID and task type.
  int generateNotificationId(String ruleId, String taskType) {
    final hash = Object.hash(ruleId, taskType);
    return hash.hashCode & 0x7FFFFFFF; // Ensure positive
  }
}
