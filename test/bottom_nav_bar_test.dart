import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:open_plant/l10n/l10n.dart';
import 'package:open_plant/pages/home/page_navigator.dart';
import 'package:open_plant/pages/home/widgets/bottom_nav_bar.dart';
import 'package:open_plant/pages/home/widgets/bottom_nav_bar_item.dart';

Widget buildNavBar({
  required PageItem currentPage,
  void Function(PageItem)? onSelectedPage,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: BottomNavBar(
        currentPage: currentPage,
        pages: orderedPageItems(),
        onSelectedPage: onSelectedPage ?? (_) {},
      ),
    ),
  );
}

void main() {
  testWidgets('BottomNavBar renders 3 items', (tester) async {
    await tester.pumpWidget(
      buildNavBar(currentPage: PageItem.dashboard),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BottomNavBarItem), findsNWidgets(3));
  });

  testWidgets('BottomNavBar shows correct localized labels', (tester) async {
    await tester.pumpWidget(
      buildNavBar(currentPage: PageItem.dashboard),
    );
    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Care Schedule'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });

  testWidgets('active item is highlighted when currentPage matches', (tester) async {
    await tester.pumpWidget(
      buildNavBar(currentPage: PageItem.dashboard),
    );
    await tester.pumpAndSettle();

    final items = tester.widgetList<BottomNavBarItem>(
      find.byType(BottomNavBarItem),
    ).toList();

    expect(items[0].isActive, isTrue);
    expect(items[1].isActive, isFalse);
    expect(items[2].isActive, isFalse);
  });

  testWidgets('tapping inactive item calls onSelectedPage', (tester) async {
    PageItem? selected;
    await tester.pumpWidget(
      buildNavBar(
        currentPage: PageItem.dashboard,
        onSelectedPage: (page) => selected = page,
      ),
    );
    await tester.pumpAndSettle();

    // Tap the Care Schedule icon (inactive, uses outlined icon)
    await tester.tap(find.byIcon(Icons.event_note_outlined));
    await tester.pumpAndSettle();

    expect(selected, equals(PageItem.careSchedule));
  });

  testWidgets('BottomNavBarItem shows active icon when isActive is true', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BottomNavBarItem(
            title: 'Test',
            activeIcon: Icons.star,
            inactiveIcon: Icons.star_border,
            onTap: () {},
            isActive: true,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final icon = tester.widget<Icon>(
      find.descendant(
        of: find.byType(BottomNavBarItem),
        matching: find.byType(Icon),
      ),
    );

    expect(icon.icon, equals(Icons.star));
  });
}
