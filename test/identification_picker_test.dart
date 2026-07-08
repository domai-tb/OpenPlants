import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_plant/l10n/l10n.dart';
import 'package:open_plant/pages/plant_identification/classifier/classification_result.dart';
import 'package:open_plant/pages/plant_identification/widgets/identification_picker.dart';

void main() {
  Widget buildTestWidget({
    List<SpeciesPrediction>? predictions,
    ValueChanged<String>? onSelected,
    VoidCallback? onSkip,
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: IdentificationPicker(
          predictions: predictions ?? const [],
          onSelected: onSelected ?? (_) {},
          onSkip: onSkip,
        ),
      ),
    );
  }

  group('IdentificationPicker', () {
    testWidgets('renders result cards for each prediction', (tester) async {
      final predictions = [
        const SpeciesPrediction(name: 'Monstera deliciosa', confidence: 0.9, index: 0),
        const SpeciesPrediction(name: 'Epipremnum aureum', confidence: 0.7, index: 1),
      ];

      await tester.pumpWidget(buildTestWidget(predictions: predictions));

      expect(find.text('Monstera deliciosa'), findsOneWidget);
      expect(find.text('Epipremnum aureum'), findsOneWidget);
      expect(find.text('Select a species'), findsOneWidget);
    });

    testWidgets('tap on result triggers onSelected callback', (tester) async {
      String? selectedName;
      final predictions = [
        const SpeciesPrediction(name: 'Monstera deliciosa', confidence: 0.9, index: 0),
      ];

      await tester.pumpWidget(
        buildTestWidget(
          predictions: predictions,
          onSelected: (name) => selectedName = name,
        ),
      );

      await tester.tap(find.text('Monstera deliciosa'));
      await tester.pump();

      expect(selectedName, 'Monstera deliciosa');
    });

    testWidgets('manual entry field triggers onSelected on confirm', (tester) async {
      String? selectedName;

      await tester.pumpWidget(
        buildTestWidget(
          onSelected: (name) => selectedName = name,
        ),
      );

      await tester.enterText(find.byType(TextField), 'Custom species');
      await tester.pump();

      // Tap the confirm button
      await tester.tap(find.byIcon(Icons.check));
      await tester.pump();

      expect(selectedName, 'Custom species');
    });

    testWidgets('empty predictions shows manual-only mode', (tester) async {
      await tester.pumpWidget(buildTestWidget(predictions: const []));

      expect(find.text('Could not identify species. Enter manually below.'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('onSkip callback is invoked when skip button tapped', (tester) async {
      bool skipTapped = false;

      await tester.pumpWidget(
        buildTestWidget(
          onSkip: () => skipTapped = true,
        ),
      );

      await tester.tap(find.text('Skip identification / enter manually'));
      await tester.pump();

      expect(skipTapped, isTrue);
    });

    testWidgets('skip button not shown when onSkip is null', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      expect(find.text('Skip identification / enter manually'), findsNothing);
    });

    testWidgets('manual entry clears on clear button tap', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      await tester.enterText(find.byType(TextField), 'Test species');
      await tester.pump();

      expect(find.text('Test species'), findsOneWidget);

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller!.text, isEmpty);
    });
  });
}
