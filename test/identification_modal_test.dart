import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/core/injection.dart';
import 'package:open_plant/core/settings.dart';
import 'package:open_plant/l10n/l10n.dart';
import 'package:open_plant/pages/plant_identification/plant_identification_page.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await init();
  });

  /// Builds a page with a button that opens the identification modal.
  ///
  /// Uses [Builder] so the button's [BuildContext] has [AppScope] in its
  /// ancestor chain — required for [AppScope.of] inside the modal.
  Widget buildPage() {
    return AppScope(
      settings: sl<SettingsController>(),
      services: sl(),
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => PlantIdentificationPage.showAsModal(context),
              child: const Text('Open ID'),
            ),
          ),
        ),
      ),
    );
  }

  group('PlantIdentificationPage modal', () {
    testWidgets('showAsModal opens a bottom sheet', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      // Button is visible; modal content is not.
      expect(find.text('Open ID'), findsOneWidget);
      expect(find.text('Plant ID'), findsNothing);

      // Tap the button to trigger showAsModal.
      await tester.tap(find.text('Open ID'));
      await tester.pumpAndSettle();

      // Modal title should now be on screen.
      expect(find.text('Plant ID'), findsOneWidget);
    });

    testWidgets('Shows initial capture prompt', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open ID'));
      await tester.pumpAndSettle();

      // The prompt instructing the user to take a photo.
      expect(
        find.text('Take a photo of a plant to identify it'),
        findsOneWidget,
      );
    });

    testWidgets('Shows camera and gallery buttons', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open ID'));
      await tester.pumpAndSettle();

      // Both action buttons are labeled.
      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);

      // Icons are present for each.
      expect(find.byIcon(Icons.camera_alt), findsOneWidget);
      expect(find.byIcon(Icons.photo_library), findsOneWidget);
    });

    testWidgets('Modal can be dismissed via Navigator.pop', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open ID'));
      await tester.pumpAndSettle();

      // Confirm modal is open.
      expect(find.text('Plant ID'), findsOneWidget);

      // Pop the modal route from the root navigator.
      final navState = tester.state<NavigatorState>(
        find.byType(Navigator).first,
      );
      await navState.maybePop();
      await tester.pumpAndSettle();

      // Modal content should no longer be visible.
      expect(find.text('Plant ID'), findsNothing);

      // The trigger button should still be present.
      expect(find.text('Open ID'), findsOneWidget);
    });
  });
}
