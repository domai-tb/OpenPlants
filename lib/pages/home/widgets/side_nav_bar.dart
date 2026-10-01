import 'package:flutter/material.dart';

import 'package:openplants/pages/home/page_navigator.dart';
import 'package:openplants/pages/home/widgets/side_nav_bar_item.dart';

class SideNavBar extends StatelessWidget {
  /// Needs the currently active page in order to highlight it
  final PageItem currentPage;
  final List<PageItem> pages;

  /// Calls this function when an item of the navigation bar is selected.
  final ValueChanged<PageItem> onSelectedPage;

  const SideNavBar({
    super.key,
    required this.currentPage,
    required this.pages,
    required this.onSelectedPage,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: 80,
      padding: const EdgeInsets.only(top: 40, bottom: 10, left: 15, right: 15),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        children: pages.map((page) {
          final presentation = pageItemPresentation(context, page);

          return SideNavBarItem(
            title: presentation.title,
            activeIcon: presentation.activeIcon,
            inactiveIcon: presentation.inactiveIcon,
            onTap: () => onSelectedPage(page),
            isActive: currentPage == page,
          );
        }).toList(),
      ),
    );
  }
}
