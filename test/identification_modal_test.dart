import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/app_scope.dart';
import 'package:open_plants/core/injection.dart';
import 'package:open_plants/core/settings.dart';
import 'package:open_plants/l10n/l10n.dart';
import 'package:open_plants/pages/plant_identification/plant_identification_page.dart';
import 'package:open_plants/widgets/inline_camera_preview.dart';

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
      await tester.pump(const Duration(seconds: 1));

      // Modal title should now be on screen.
      expect(find.text('Plant ID'), findsOneWidget);
    });

    testWidgets('Shows inline camera preview by default', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open ID'));
      await tester.pump(const Duration(seconds: 1));

      // The inline camera preview should be shown.
      expect(find.byType(InlineCameraPreview), findsOneWidget);
    });

    testWidgets('Shows permission request UI when camera not available', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open ID'));
      await tester.pump(const Duration(seconds: 2));

      // In test environment, camera permission is not available,
      // so we should see either the permission request UI or the loading state.
      // The widget will show loading while checking permission, then show the UI.
      final hasGrantAccess = find.text('Grant access').evaluate().isNotEmpty;
      final hasLoading = find.text('Initializing camera...').evaluate().isNotEmpty;
      expect(hasGrantAccess || hasLoading, isTrue);
    });

    testWidgets('Modal can be dismissed via Navigator.pop', (tester) async {
      await tester.pumpWidget(buildPage());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open ID'));
      await tester.pump(const Duration(seconds: 1));

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
