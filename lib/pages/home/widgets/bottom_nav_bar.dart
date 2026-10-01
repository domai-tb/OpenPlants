import 'package:flutter/material.dart';

import 'package:openplants/core/constants.dart';
import 'package:openplants/pages/home/page_navigator.dart';
import 'package:openplants/pages/home/widgets/bottom_nav_bar_item.dart';

/// Creates the bottom navigation bar that lets the user switch between different pages.
/// With 3 fixed tabs, the items fit without scrolling.
class BottomNavBar extends StatelessWidget {
  /// Needs the currently active page in order to highlight it
  final PageItem currentPage;
  final List<PageItem> pages;

  /// Calls this function when an item of the navigation bar is selected.
  final ValueChanged<PageItem> onSelectedPage;

  const BottomNavBar({
    super.key,
    required this.currentPage,
    required this.pages,
    required this.onSelectedPage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: bottomNavBarHeight,
      padding: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow,
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: pages.map((page) {
          final presentation = pageItemPresentation(context, page);

          return Expanded(
            child: BottomNavBarItem(
              title: presentation.title,
              activeIcon: presentation.activeIcon,
              inactiveIcon: presentation.inactiveIcon,
              onTap: () => onSelectedPage(page),
              isActive: currentPage == page,
            ),
          );
        }).toList(),
      ),
    );
  }
}
