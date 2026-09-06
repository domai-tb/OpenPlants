import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/local_collection_codec.dart';
import 'package:open_plants/pages/notifications/notification_entity.dart';

/// Persistence layer for scheduled notifications.
class NotificationDataSource {
  static const String _prefsKey = 'scheduled_notifications_v1';
  LocalCollectionCodec<ScheduledNotification>? _codec;
  SharedPreferences? _prefs;

  NotificationDataSource({SharedPreferences? prefs}) : _prefs = prefs;

  Future<LocalCollectionCodec<ScheduledNotification>> _getCodec() async {
    if (_codec != null) return _codec!;
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    _codec = LocalCollectionCodec<ScheduledNotification>(
      prefs: prefs,
      key: _prefsKey,
      fromJson: ScheduledNotification.fromJson,
      toJson: (e) => e.toJson(),
      keyExtractor: (e) => e.id.toString(),
    );
    return _codec!;
  }

  Future<List<ScheduledNotification>> loadNotifications() async {
    final codec = await _getCodec();
    final decoded = await codec.load();
    if (decoded.isFailure) return [];
    return decoded.asSuccess;
  }

  Future<void> saveNotification(ScheduledNotification notification) async {
    final codec = await _getCodec();
    final current = await loadNotifications();
    final index = current.indexWhere((n) => n.id == notification.id);
    if (index >= 0) {
      current[index] = notification;
    } else {
      current.add(notification);
    }
    await codec.save(current);
  }

  Future<void> deleteNotification(int id) async {
    final codec = await _getCodec();
    final current = await loadNotifications();
    current.removeWhere((n) => n.id == id);
    await codec.save(current);
  }

  Future<void> deleteNotificationsForRule(String ruleId) async {
    final codec = await _getCodec();
    final current = await loadNotifications();
    current.removeWhere((n) => n.ruleId == ruleId);
    await codec.save(current);
  }

  Future<void> deleteNotificationsForPlant(String plantId) async {
    final codec = await _getCodec();
    final current = await loadNotifications();
    current.removeWhere((n) => n.plantId == plantId);
    await codec.save(current);
  }

  Future<void> clearAll() async {
    final codec = await _getCodec();
    await codec.save([]);
  }
}
