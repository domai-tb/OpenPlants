import 'package:flutter/material.dart';

import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_page.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_page.dart';
import 'package:open_plant/pages/page2/page2_page.dart';
import 'package:open_plant/pages/plant_identification/plant_identification_page.dart';
import 'package:open_plant/pages/page4/page4_page.dart';
import 'package:open_plant/pages/page5/page5_page.dart';
import 'package:open_plant/pages/page6/page6_page.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_page.dart';
import 'package:open_plant/pages/species_library/species_library_page.dart';

enum PageItem { todayDashboard, careSchedule, page2, plantIdentification, page4, page5, page6, plantCollection, speciesLibrary }

PageItem? pageItemFromId(String id) {
  for (final item in PageItem.values) {
    if (item.name == id) return item;
  }
  return null;
}

List<PageItem> orderedPageItemsFromSettings(List<String> order) {
  final orderedItems = <PageItem>[];
  final seenItems = <PageItem>{};

  for (final id in order) {
    final item = pageItemFromId(id);
    if (item != null && seenItems.add(item)) {
      orderedItems.add(item);
    }
  }

  for (final item in PageItem.values) {
    if (seenItems.add(item)) {
      orderedItems.add(item);
    }
  }

  return orderedItems;
}

Set<PageItem> hiddenPageItemsFromSettings(List<String> hiddenItems) {
  final hiddenPageItems = <PageItem>{};

  for (final id in hiddenItems) {
    final item = pageItemFromId(id);
    if (item != null && item != PageItem.page6) {
      hiddenPageItems.add(item);
    }
  }

  return hiddenPageItems;
}

List<String> pageItemIds(Iterable<PageItem> items) {
  return items.map((item) => item.name).toList();
}

class PageItemPresentation {
  final String title;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final double iconPaddingLeft;
  final double iconPaddingRight;

  const PageItemPresentation({
    required this.title,
    required this.activeIcon,
    required this.inactiveIcon,
    this.iconPaddingLeft = 10,
    this.iconPaddingRight = 10,
  });
}

PageItemPresentation pageItemPresentation(BuildContext context, PageItem item) {
  switch (item) {
    case PageItem.todayDashboard:
      return PageItemPresentation(
        title: context.l10n.todayDashboardTitle,
        activeIcon: Icons.today,
        inactiveIcon: Icons.today_outlined,
        iconPaddingLeft: 0,
      );
    case PageItem.careSchedule:
      return PageItemPresentation(
        title: context.l10n.careScheduleTitle,
        activeIcon: Icons.event_note,
        inactiveIcon: Icons.event_note_outlined,
      );
    case PageItem.page2:
      return PageItemPresentation(
        title: context.l10n.page2Title,
        activeIcon: Icons.calendar_month,
        inactiveIcon: Icons.calendar_month_outlined,
        iconPaddingLeft: 14,
      );
    case PageItem.plantIdentification:
      return PageItemPresentation(
        title: context.l10n.plantIdentificationTitle,
        activeIcon: Icons.camera_alt,
        inactiveIcon: Icons.camera_alt_outlined,
      );
    case PageItem.page4:
      return PageItemPresentation(
        title: context.l10n.page4Title,
        activeIcon: Icons.restaurant,
        inactiveIcon: Icons.restaurant_outlined,
      );
    case PageItem.page5:
      return PageItemPresentation(
        title: context.l10n.page5Title,
        activeIcon: Icons.account_balance_wallet,
        inactiveIcon: Icons.account_balance_wallet_outlined,
      );
    case PageItem.page6:
      return PageItemPresentation(
        title: context.l10n.page6Title,
        activeIcon: Icons.more_horiz,
        inactiveIcon: Icons.more_horiz,
        iconPaddingLeft: 5,
        iconPaddingRight: 0,
      );
    case PageItem.plantCollection:
      return PageItemPresentation(
        title: context.l10n.plantCollectionTitle,
        activeIcon: Icons.yard,
        inactiveIcon: Icons.yard_outlined,
      );
    case PageItem.speciesLibrary:
      return PageItemPresentation(
        title: context.l10n.speciesLibraryTitle,
        activeIcon: Icons.menu_book,
        inactiveIcon: Icons.menu_book_outlined,
      );
  }
}

class PageNavigatorRoutes {
  /// The root-page is shown initially when this navbar-tab is the active one.
  static const String root = '/';

  /// The detail-page is pushed onto the navigator-stack of this specific tab when,
  /// for example, a news-article is opened.
  static const String detail = '/detail';
}

/// Wraps the displayed page into a seperate [Navigator] in order to push new detail-pages
/// (like opening a news-article) to a specific navigator-stack instead of the app-wide navigator-stack.
///
/// This also allows to constantly show the bottom navigation bar across multiple pages, even during transitions.
class NavBarNavigator extends StatelessWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;

  final GlobalKey<NavigatorState> navigatorKey;

  /// Determines the type of the page in order to set the navigator correctly.
  final PageItem pageItem;

  /// Passes the animation key for the entry animation to the referenced page
  /// to control the animation from outside the page.
  final GlobalKey<AnimatedEntryState> pageEntryAnimationKey;

  /// Passes the animation key for the exit animation to the referenced page
  /// to control the animation from outside the page.
  final GlobalKey<AnimatedExitState> pageExitAnimationKey;

  /// Optional callback: switch to the species library tab when the
  /// identification result page requests a species detail view.
  final VoidCallback? onSwitchToSpeciesLibrary;

  const NavBarNavigator({
    super.key,
    required this.mainNavigatorKey,
    required this.navigatorKey,
    required this.pageItem,
    required this.pageEntryAnimationKey,
    required this.pageExitAnimationKey,
    this.onSwitchToSpeciesLibrary,
  });

  /// Creates a map of the root and detail page of the specific page.
  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    Widget rootPage;
    switch (pageItem) {
      case PageItem.todayDashboard:
        rootPage = TodayDashboardPage(
          mainNavigatorKey: mainNavigatorKey,
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
        );
        break;
      case PageItem.careSchedule:
        rootPage = CareSchedulePage(
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
        );
        break;
      case PageItem.page2:
        rootPage = Page2Page(
          mainNavigatorKey: mainNavigatorKey,
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
        );
        break;
      case PageItem.page4:
        rootPage = Page4Page(
          mainNavigatorKey: mainNavigatorKey,
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
        );
        break;
      case PageItem.plantIdentification:
        rootPage = PlantIdentificationPage(
          mainNavigatorKey: mainNavigatorKey,
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
          onViewSpeciesLibrary: onSwitchToSpeciesLibrary,
        );
        break;
      case PageItem.page5:
        rootPage = Page5Page(
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
        );
        break;
      case PageItem.page6:
        rootPage = Page6Page(
          mainNavigatorKey: mainNavigatorKey,
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
        );
        break;
      case PageItem.plantCollection:
        rootPage = PlantCollectionPage(
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
        );
        break;
      case PageItem.speciesLibrary:
        rootPage = SpeciesLibraryPage(
          mainNavigatorKey: mainNavigatorKey,
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
        );
        break;
    }
    return {
      PageNavigatorRoutes.root: (context) => rootPage,
      //TabNavigatorRoutes.detail: (context) => ,
    };
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, WidgetBuilder> routeBuilders = _routeBuilders(context);

    return Navigator(
      key: navigatorKey,
      initialRoute: PageNavigatorRoutes.root,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(
          builder: (context) => routeBuilders[routeSettings.name]!(context),
        );
      },
    );
  }
}
