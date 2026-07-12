import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/app_scope.dart';
import 'package:open_plants/core/injection.dart';
import 'package:open_plants/core/settings.dart';
import 'package:open_plants/l10n/l10n.dart';
import 'package:open_plants/pages/today_dashboard/plant_grid_section.dart';
import 'package:open_plants/widgets/app_search_bar.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await init();
  });

  /// Builds a PlantGridSection wrapped in the app's DI and localization tree.
  ///
  /// The widget is placed inside a [SingleChildScrollView] so the tall Column
  /// (header + chips + grid) does not trigger RenderFlex overflow errors at
  /// the default 800×600 test viewport.
  Widget buildPage() {
    return AppScope(
      settings: sl<SettingsController>(),
      services: sl(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PlantGridSection(
              onNavigateToPlantDetail: (_) {},
            ),
          ),
        ),
      ),
    );
  }

  /// Variation of [buildPage] with a custom [onNavigateToPlantDetail] callback.
  Widget buildPageWithCallback(
    void Function(String id) onNavigateToPlantDetail,
  ) {
    return AppScope(
      settings: sl<SettingsController>(),
      services: sl(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PlantGridSection(
              onNavigateToPlantDetail: onNavigateToPlantDetail,
            ),
          ),
        ),
      ),
    );
  }

  group('PlantGridSection', () {
    testWidgets('shows loading state initially', (tester) async {
      await tester.pumpWidget(buildPage());

      // The section header is visible immediately, but the empty-state
      // message only appears once the async data load finishes.
      expect(find.text('Plant Collection'), findsOneWidget);
      expect(find.text('No plants yet'), findsNothing);
    });

    testWidgets('shows empty state when no plants', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Plant Collection'), findsOneWidget);
      expect(find.text('No plants yet'), findsOneWidget);
    });

    testWidgets('shows search toggle button', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('toggling search shows AppSearchBar', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Search bar starts hidden.
      expect(find.byType(AppSearchBar), findsNothing);

      // Tap the search icon.
      await tester.tap(find.byIcon(Icons.search));
      await tester.pump();

      // AppSearchBar should now be visible and the icon changes to close.
      expect(find.byType(AppSearchBar), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('filter chips render', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Needs Water'), findsOneWidget);
      expect(find.text('Needs Fertilizer'), findsOneWidget);
    });

    testWidgets('plant grid renders with pre-populated plants', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'plant_collection_v1',
        jsonEncode([
          {
            'id': 'plant-1',
            'name': 'Test Plant',
            'speciesName': 'Test Species',
            'careStatus': 'happy',
            'createdAt': DateTime(2026).toIso8601String(),
            'updatedAt': DateTime(2026).toIso8601String(),
            'photos': <Map<String, dynamic>>[],
          },
        ]),
      );

      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('Test Plant'), findsOneWidget);
      expect(find.text('Test Species'), findsOneWidget);
    });

    testWidgets('calls onNavigateToPlantDetail on card tap', (tester) async {
      final navigatedPlants = <String>[];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'plant_collection_v1',
        jsonEncode([
          {
            'id': 'plant-1',
            'name': 'Tappable Plant',
            'careStatus': 'happy',
            'createdAt': DateTime(2026).toIso8601String(),
            'updatedAt': DateTime(2026).toIso8601String(),
            'photos': <Map<String, dynamic>>[],
          },
        ]),
      );

      await tester.pumpWidget(
        buildPageWithCallback(navigatedPlants.add),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tappable Plant'));
      await tester.pumpAndSettle();

      expect(navigatedPlants, ['plant-1']);
    });
  });
}
