import 'package:openplants/pages/notifications/notification_datasource.dart';
import 'package:openplants/pages/notifications/notification_entity.dart';

/// Repository for managing scheduled notifications.
class NotificationRepository {
  final NotificationDataSource _datasource;

  NotificationRepository({required NotificationDataSource datasource}) : _datasource = datasource;

  Future<List<ScheduledNotification>> loadNotifications() => _datasource.loadNotifications();

  Future<void> saveNotification(ScheduledNotification notification) => _datasource.saveNotification(notification);

  Future<void> deleteNotification(int id) => _datasource.deleteNotification(id);

  Future<void> clearAll() => _datasource.clearAll();

  /// Generate a stable integer ID from a plant and care rule.
  int generateNotificationId(String plantId, String ruleId) {
    var hash = 0x811C9DC5;
    for (final codeUnit in '$plantId\u0000$ruleId'.codeUnits) {
      hash = ((hash ^ codeUnit) * 0x01000193) & 0xFFFFFFFF;
    }
    return hash & 0x7FFFFFFF;
  }
}
