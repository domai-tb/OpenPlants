import 'package:flutter/material.dart';

import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plant/pages/care_schedule/care_schedule_page.dart';
import 'package:open_plant/pages/today_dashboard/today_dashboard_page.dart';
import 'package:open_plant/pages/more/more_page.dart';

enum PageItem { dashboard, careSchedule, more }

/// Returns the 3 fixed page items.
List<PageItem> orderedPageItems() => PageItem.values.toList();

class PageItemPresentation {
  final String title;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const PageItemPresentation({
    required this.title,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}

PageItemPresentation pageItemPresentation(BuildContext context, PageItem item) {
  return switch (item) {
    PageItem.dashboard => PageItemPresentation(
      title: context.l10n.todayDashboardTitle,
      activeIcon: Icons.today,
      inactiveIcon: Icons.today_outlined,
    ),
    PageItem.careSchedule => PageItemPresentation(
      title: context.l10n.careScheduleTitle,
      activeIcon: Icons.event_note,
      inactiveIcon: Icons.event_note_outlined,
    ),
    PageItem.more => PageItemPresentation(
      title: context.l10n.moreTitle,
      activeIcon: Icons.more_horiz,
      inactiveIcon: Icons.more_horiz,
    ),
  };
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
  final PageItem pageItem;
  final GlobalKey<AnimatedEntryState> pageEntryAnimationKey;
  final GlobalKey<AnimatedExitState> pageExitAnimationKey;
  final ValueNotifier<int>? tabSwitchNotifier;

  const NavBarNavigator({
    super.key,
    required this.mainNavigatorKey,
    required this.navigatorKey,
    required this.pageItem,
    required this.pageEntryAnimationKey,
    required this.pageExitAnimationKey,
    this.tabSwitchNotifier,
  });

  Map<String, WidgetBuilder> _routeBuilders(BuildContext context) {
    final Widget rootPage;
    switch (pageItem) {
      case PageItem.dashboard:
        rootPage = TodayDashboardPage(
          mainNavigatorKey: mainNavigatorKey,
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
          tabSwitchNotifier: tabSwitchNotifier,
        );
      case PageItem.careSchedule:
        rootPage = CareSchedulePage(
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
          tabSwitchNotifier: tabSwitchNotifier,
        );
      case PageItem.more:
        rootPage = MorePage(
          mainNavigatorKey: mainNavigatorKey,
          pageEntryAnimationKey: pageEntryAnimationKey,
          pageExitAnimationKey: pageExitAnimationKey,
        );
    }
    return {
      PageNavigatorRoutes.root: (context) => rootPage,
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
