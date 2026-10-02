import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/core/app_scope.dart';
import 'package:openplants/core/injection.dart';
import 'package:openplants/core/settings.dart';
import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:openplants/pages/today_dashboard/plant_grid_section.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await init();
  });

  /// Builds a PlantGridSection wrapped in the app's DI and localization tree.
  ///
  /// The widget is placed inside a [SingleChildScrollView] so the tall Column
  /// (header + chips + grid) does not trigger RenderFlex overflow errors at
  /// the default 800×600 test viewport.
  Widget buildPage({String query = '', CareStatus? filterStatus}) {
    return AppScope(
      settings: sl<SettingsController>(),
      services: sl(),
      child: MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            child: PlantGridSection(
              onNavigateToPlantDetail: (_) {},
              query: query,
              filterStatus: filterStatus,
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
        locale: const Locale('en'),
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

      final loadingGrid = find.byType(GridView);
      expect(loadingGrid, findsOneWidget);
      expect(
        find.descendant(
          of: loadingGrid,
          matching: find.byType(Container),
        ),
        findsNWidgets(4),
      );
      expect(find.text('No plants yet'), findsNothing);
    });

    testWidgets('shows empty state when no plants', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      expect(find.text('No plants yet'), findsOneWidget);
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

    testWidgets('combines search and care-status filters', (tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'plant_collection_v1',
        jsonEncode([
          {
            'id': 'plant-match',
            'name': 'Fern Mix',
            'careStatus': 'needsWater',
            'createdAt': DateTime(2026).toIso8601String(),
            'updatedAt': DateTime(2026).toIso8601String(),
            'photos': <Map<String, dynamic>>[],
          },
          {
            'id': 'plant-status-only',
            'name': 'Other Fern',
            'careStatus': 'needsWater',
            'createdAt': DateTime(2026).toIso8601String(),
            'updatedAt': DateTime(2026).toIso8601String(),
            'photos': <Map<String, dynamic>>[],
          },
          {
            'id': 'plant-query-only',
            'name': 'Fern Mix Two',
            'careStatus': 'needsFertilizer',
            'createdAt': DateTime(2026).toIso8601String(),
            'updatedAt': DateTime(2026).toIso8601String(),
            'photos': <Map<String, dynamic>>[],
          },
        ]),
      );

      await tester.pumpWidget(buildPage(query: 'fern mix', filterStatus: CareStatus.needsWater));
      await tester.pumpAndSettle();

      expect(find.text('Fern Mix'), findsOneWidget);
      expect(find.text('Other Fern'), findsNothing);
      expect(find.text('Fern Mix Two'), findsNothing);
    });
  });
}
