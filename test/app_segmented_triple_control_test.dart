import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:openplants/widgets/app_segmented_triple_control.dart';

void main() {
  testWidgets('exposes each option as a button and marks the selected option', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: AppSegmentedTripleControl(
            leftTitle: 'System',
            centerTitle: 'Light',
            rightTitle: 'Dark',
            onChanged: _ignoreSelection,
          ),
        ),
      ),
    );

    final system = tester.getSemantics(find.bySemanticsLabel('System')).getSemanticsData();
    expect(system.label, 'System');
    expect(system.flagsCollection.isButton, isTrue);
    expect(system.flagsCollection.isSelected, ui.Tristate.isTrue);
    expect(system.hasAction(SemanticsAction.tap), isTrue);

    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    expect(
      tester.getSemantics(find.bySemanticsLabel('System')).getSemanticsData().flagsCollection.isSelected,
      ui.Tristate.isFalse,
    );
    final dark = tester.getSemantics(find.bySemanticsLabel('Dark')).getSemanticsData();
    expect(dark.flagsCollection.isButton, isTrue);
    expect(dark.flagsCollection.isSelected, ui.Tristate.isTrue);
    expect(dark.hasAction(SemanticsAction.tap), isTrue);
    semantics.dispose();
  });
}

void _ignoreSelection(int _) {}
