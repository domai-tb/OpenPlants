import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/app_scope.dart';
import 'package:open_plants/core/injection.dart' as ic;
import 'package:open_plants/core/settings.dart';
import 'package:open_plants/l10n/l10n.dart';
import 'package:open_plants/pages/notifications/notification_settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsController settings;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await ic.init();
    settings = ic.sl<SettingsController>();
  });

  group('NotificationSettingsPage', () {
    testWidgets('shows master toggle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: AppScope(
            settings: settings,
            services: ic.sl(),
            child: const NotificationSettingsPage(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.byType(SwitchListTile), findsWidgets);
    });
  });
}
