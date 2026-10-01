import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:openplants/l10n/l10n.dart';
import 'package:openplants/pages/light_assessment/light_assessment_datasource.dart';
import 'package:openplants/pages/light_assessment/light_assessment_page.dart';
import 'package:openplants/pages/light_assessment/light_assessment_repository.dart';
import 'package:openplants/pages/light_assessment/light_assessment_usecases.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';

void main() {
  testWidgets('shows light assessment content in the active German locale', (tester) async {
    final usecases = _createUsecases(_MemoryLightAssessmentDataSource());

    await tester.pumpWidget(_buildApp(usecases, locale: const Locale('de')));
    await tester.pumpAndSettle();

    expect(find.text('Lichtmessung — Monstera'), findsOneWidget);
    expect(find.text('Aktuelle Lichtstufe'), findsOneWidget);
    expect(find.text('Nicht festgelegt'), findsOneWidget);
    expect(find.text('Lichtstufe auswählen'), findsOneWidget);
    expect(find.text('Wenig Licht'), findsOneWidget);
    expect(find.text('Dunkle Ecken, Nordfenster und Innenräume'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Interaktive Kamera'), 400);
    expect(find.text('Interaktive Kamera'), findsOneWidget);
    expect(find.text('Mit Kamera einschätzen'), findsOneWidget);

    await tester.scrollUntilVisible(find.text('Licht anhand eines Fotos einschätzen'), 400);
    expect(find.text('Licht anhand eines Fotos einschätzen'), findsOneWidget);
    expect(find.text('Aus Galerie auswählen'), findsOneWidget);
    expect(find.textContaining('Noch kein Foto vorhanden.'), findsOneWidget);
  });

  testWidgets('localizes level set and clear snackbars', (tester) async {
    final usecases = _createUsecases(_MemoryLightAssessmentDataSource());

    await tester.pumpWidget(_buildApp(usecases, locale: const Locale('de')));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Wenig Licht'));
    await tester.pumpAndSettle();
    expect(find.text('Lichtstufe auf Wenig Licht gesetzt'), findsOneWidget);

    tester.state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger)).hideCurrentSnackBar();
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(TextButton, 'Zurücksetzen'));
    await tester.pumpAndSettle();
    expect(find.text('Lichtstufe zurückgesetzt'), findsOneWidget);
  });

  testWidgets('shows a localized generic message when saving a level fails', (tester) async {
    final dataSource = _MemoryLightAssessmentDataSource()..failWrites = true;
    final usecases = _createUsecases(dataSource);

    await tester.pumpWidget(_buildApp(usecases, locale: const Locale('de')));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ListTile, 'Wenig Licht'));
    await tester.pumpAndSettle();

    expect(find.text('Ein Fehler ist aufgetreten.'), findsOneWidget);
  });
}

Widget _buildApp(LightAssessmentUseCases usecases, {required Locale locale}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: LightAssessmentPage(
      plantId: 'plant-1',
      plantName: 'Monstera',
      usecases: usecases,
    ),
  );
}

LightAssessmentUseCases _createUsecases(_MemoryLightAssessmentDataSource dataSource) {
  return LightAssessmentUseCases(
    repository: LightAssessmentRepository(dataSource: dataSource),
    getLatestPhoto: (_) async => null,
    addPhoto: (_, __) async => throw StateError('Photo adding is unused in this test'),
  );
}

class _MemoryLightAssessmentDataSource implements LightAssessmentDataSource {
  LightLevel? level;
  bool failWrites = false;

  @override
  Future<LightLevel?> loadLightLevel(String plantId) async => level;

  @override
  Future<void> saveLightLevel(String plantId, LightLevel value) async {
    if (failWrites) throw StateError('Storage unavailable');
    level = value;
  }

  @override
  Future<void> clearLightLevel(String plantId) async {
    if (failWrites) throw StateError('Storage unavailable');
    level = null;
  }
}
