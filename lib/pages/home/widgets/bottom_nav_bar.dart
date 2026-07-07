import 'dart:io' show Platform;

import 'package:flutter/material.dart';

import 'package:open_plant/pages/home/page_navigator.dart';
import 'package:open_plant/pages/home/widgets/bottom_nav_bar_item.dart';

/// Creates the bottom navigation bar that lets the user switch between different pages.
class BottomNavBar extends StatefulWidget {
  /// Needs the currently active page in order to highlight it
  final PageItem currentPage;
  final List<PageItem> pages;

  /// Calls this function when an item of the navigation bar is selected.
  final Function(PageItem) onSelectedPage;

  const BottomNavBar({
    super.key,
    required this.currentPage,
    required this.pages,
    required this.onSelectedPage,
  });

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  final ScrollController _scrollController = ScrollController();

  /// All pages — the viewport width (~360px) naturally shows ~4-5 items.
  /// Scroll position is animated to center the active item.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToActive(animated: false);
    });
  }

  @override
  void didUpdateWidget(BottomNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentPage != oldWidget.currentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToActive(animated: true);
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToActive({required bool animated}) {
    if (!_scrollController.hasClients) return;

    final index = widget.pages.indexOf(widget.currentPage);
    if (index < 0) return;

    const itemWidth = 80.0;
    final viewportWidth = _scrollController.position.viewportDimension;
    final targetOffset = (index * itemWidth) - (viewportWidth / 2) + (itemWidth / 2);
    final clampedOffset = targetOffset.clamp(
      _scrollController.position.minScrollExtent,
      _scrollController.position.maxScrollExtent,
    );

    if (animated) {
      _scrollController.animateTo(
        clampedOffset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _scrollController.jumpTo(clampedOffset);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: Platform.isIOS ? 88 : 98,
      padding: Platform.isIOS ? const EdgeInsets.only(bottom: 20) : null,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(15),
          topRight: Radius.circular(15),
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, -1),
          ),
        ],
      ),
      child: SingleChildScrollView(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: widget.pages.map((page) {
            final presentation = pageItemPresentation(context, page);

            return SizedBox(
              width: 80,
              child: BottomNavBarItem(
                title: presentation.title,
                activeIcon: presentation.activeIcon,
                inactiveIcon: presentation.inactiveIcon,
                onTap: () => widget.onSelectedPage(page),
                isActive: widget.currentPage == page,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
