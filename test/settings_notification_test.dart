import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/core/settings.dart';

void main() {
  group('Settings notification defaults', () {
    test('fromJson defaults notifications to true', () {
      final settings = Settings.fromJson({});
      expect(settings.notificationsEnabled, true);
      expect(settings.notifyDueTasks, true);
      expect(settings.notifyOverdueTasks, true);
    });

    test('fromJson preserves explicit false values', () {
      final settings = Settings.fromJson({
        'notificationsEnabled': false,
        'notifyDueTasks': false,
        'notifyOverdueTasks': false,
      });
      expect(settings.notificationsEnabled, false);
      expect(settings.notifyDueTasks, false);
      expect(settings.notifyOverdueTasks, false);
    });

    test('toJson includes notification fields', () {
      const settings = Settings(
        notificationsEnabled: false,
        notifyDueTasks: true,
        notifyOverdueTasks: false,
      );
      final json = settings.toJson();
      expect(json['notificationsEnabled'], false);
      expect(json['notifyDueTasks'], true);
      expect(json['notifyOverdueTasks'], false);
    });

    test('copyWith preserves notification fields', () {
      const settings = Settings(
        notificationsEnabled: false,
        notifyDueTasks: false,
        notifyOverdueTasks: true,
      );
      final updated = settings.copyWith(notificationsEnabled: true);
      expect(updated.notificationsEnabled, true);
      expect(updated.notifyDueTasks, false);
      expect(updated.notifyOverdueTasks, true);
    });

    test('round trip preserves notification settings', () {
      const settings = Settings(
        notificationsEnabled: false,
        notifyDueTasks: true,
        notifyOverdueTasks: false,
      );
      final json = settings.toJson();
      final restored = Settings.fromJson(json);
      expect(restored.notificationsEnabled, false);
      expect(restored.notifyDueTasks, true);
      expect(restored.notifyOverdueTasks, false);
    });
  });

  group('SettingsController persistence', () {
    test('loads with default notification settings when no stored data', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await SettingsController.load();
      expect(controller.settings.notificationsEnabled, true);
      expect(controller.settings.notifyDueTasks, true);
      expect(controller.settings.notifyOverdueTasks, true);
    });

    test('persists notification settings changes', () async {
      SharedPreferences.setMockInitialValues({});
      final controller = await SettingsController.load();

      controller.update(controller.settings.copyWith(
        notificationsEnabled: false,
        notifyDueTasks: false,
        notifyOverdueTasks: false,
      ));

      final reloaded = await SettingsController.load();
      expect(reloaded.settings.notificationsEnabled, false);
      expect(reloaded.settings.notifyDueTasks, false);
      expect(reloaded.settings.notifyOverdueTasks, false);
    });
  });
}
