import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/app_scope.dart';
import 'package:open_plants/core/injection.dart' as ic;
import 'package:open_plants/core/settings.dart';
import 'package:open_plants/pages/notifications/notification_settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await ic.init();
  });

  group('NotificationSettingsPage', () {
    testWidgets('shows master toggle', (tester) async {
      final settings = ic.sl<SettingsController>();

      await tester.pumpWidget(
        MaterialApp(
          home: AppScope(
            settings: settings,
            services: ic.sl(),
            child: const NotificationSettingsPage(),
          ),
        ),
      );

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsWidgets);
    });

    testWidgets('toggles master notification setting', (tester) async {
      final settings = ic.sl<SettingsController>();

      await tester.pumpWidget(
        MaterialApp(
          home: AppScope(
            settings: settings,
            services: ic.sl(),
            child: const NotificationSettingsPage(),
          ),
        ),
      );

      // Find and tap the master toggle
      final masterToggle = find.byType(SwitchListTile).first;
      await tester.tap(masterToggle);
      await tester.pumpAndSettle();

      // Verify the setting was updated
      expect(settings.settings.notificationsEnabled, false);
    });
  });
}
