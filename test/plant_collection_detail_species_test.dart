import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/core/app_scope.dart';
import 'package:openplants/core/injection.dart';
import 'package:openplants/core/settings.dart';
import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/pages/plant_collection/plant_collection_detail_page.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await sl.reset();
    await init();
  });

  tearDown(() async {
    await sl.reset();
  });

  testWidgets('localizes the species display while keeping the plant name unchanged', (tester) async {
    final plant = PlantEntity(
      id: 'plant-1',
      name: 'My Plant Name',
      speciesId: 'monstera_deliciosa',
      speciesName: 'Monstera deliciosa',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );

    Widget buildPage(Locale locale) {
      return AppScope(
        settings: sl<SettingsController>(),
        services: sl(),
        child: MaterialApp(
          locale: locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: PlantCollectionDetailPage(plant: plant),
        ),
      );
    }

    await tester.pumpWidget(buildPage(const Locale('en')));
    await tester.pumpAndSettle();

    expect(find.text('My Plant Name'), findsOneWidget);
    expect(find.text('Swiss Cheese Plant'), findsOneWidget);

    await tester.pumpWidget(buildPage(const Locale('de')));
    await tester.pumpAndSettle();

    expect(find.text('My Plant Name'), findsOneWidget);
    expect(find.text('Monstera'), findsOneWidget);
    expect(find.text('Swiss Cheese Plant'), findsNothing);
  });
}
