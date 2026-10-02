import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/pages/species_library/species_detail_page.dart';
import 'package:openplants/pages/species_library/species_library_item_entity.dart';

void main() {
  testWidgets('localizes care-plan guidance from species care needs', (tester) async {
    const species = SpeciesEntity(
      scientificName: 'Testus plantus',
      commonNames: ['Test plant'],
      difficulty: Difficulty.easy,
      lightNeeds: LightNeeds.direct,
      waterNeeds: WaterNeeds.frequent,
      humidityPreference: HumidityPreference.moderate,
      soilType: 'peat-free mix',
      repottingIntervalMonths: 36,
      toxicToHumans: false,
      toxicToPets: false,
      description: 'Test species',
      careSummary: 'Easy care',
    );

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('de'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SpeciesDetailPage(species: species),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(tester.element(find.byType(SpeciesDetailPage)))!;
    expect(l10n.localeName, 'de');
    expect(find.text(l10n.speciesCarePlanWaterFrequent), findsOneWidget);
    expect(find.text(l10n.speciesCarePlanLightDirect), findsOneWidget);
    expect(find.text(l10n.speciesCarePlanHumidityModerate), findsOneWidget);
    expect(find.text(l10n.speciesCarePlanSoil(l10n.speciesSoilPeatFree)), findsOneWidget);
    expect(find.text(l10n.speciesSoilPeatFree), findsOneWidget);
    expect(find.text(l10n.speciesCarePlanRepotWhenRootBound), findsOneWidget);
  });
}
