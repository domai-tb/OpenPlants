import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/app_scope.dart';
import 'package:open_plants/core/injection.dart';
import 'package:open_plants/core/settings.dart';
import 'package:open_plants/l10n/l10n.dart';
import 'package:open_plants/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plants/pages/today_dashboard/today_dashboard_page.dart';
import 'package:open_plants/widgets/app_search_bar.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await init();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({
      'plant_collection_v1': jsonEncode([
        {
          'id': 'plant-1',
          'name': 'Dashboard Plant',
          'careStatus': 'happy',
          'createdAt': DateTime(2026).toIso8601String(),
          'updatedAt': DateTime(2026).toIso8601String(),
          'photos': <Map<String, dynamic>>[],
        },
      ]),
    });
  });

  Widget buildPage() {
    return AppScope(
      settings: sl<SettingsController>(),
      services: sl(),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: TodayDashboardPage(
          mainNavigatorKey: GlobalKey<NavigatorState>(),
          pageEntryAnimationKey: GlobalKey<AnimatedEntryState>(),
          pageExitAnimationKey: GlobalKey<AnimatedExitState>(),
        ),
      ),
    );
  }

  group('TodayDashboardPage collection controls', () {
    testWidgets('shows collection title, search toggle, and filter chips', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Plant Collection'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byType(AppSearchBar), findsNothing);
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Needs Water'), findsOneWidget);
      expect(find.text('Needs Fertilizer'), findsOneWidget);
    });

    testWidgets('search toggle shows and closes AppSearchBar', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      expect(find.byType(AppSearchBar), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(find.byType(AppSearchBar), findsNothing);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });
  });
}
