import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:open_plants/core/constants.dart';
import 'package:open_plants/pages/home/page_navigator.dart';
import 'package:open_plants/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plants/pages/home/widgets/bottom_nav_bar.dart';
import 'package:open_plants/pages/home/widgets/side_nav_bar.dart';

/// The [HomePage] displays all general UI elements like the bottom nav-menu and
/// handles the switching between the different pages.
class HomePage extends StatefulWidget {
  final GlobalKey<NavigatorState> mainNavigatorKey;

  const HomePage({super.key, required this.mainNavigatorKey});

  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  /// Creates a [GlobalKey] for each page that should be accessable within the bottom nav-menu
  Map<PageItem, GlobalKey<NavigatorState>> navigatorKeys = {
    PageItem.dashboard: GlobalKey<NavigatorState>(),
    PageItem.careSchedule: GlobalKey<NavigatorState>(),
    PageItem.more: GlobalKey<NavigatorState>(),
  };

  /// Creates two [GlobalKey] for each page in order to control the exit- and
  /// entry-animation from outside the page
  Map<PageItem, GlobalKey<AnimatedExitState>> exitAnimationKeys = {
    PageItem.dashboard: GlobalKey<AnimatedExitState>(),
    PageItem.careSchedule: GlobalKey<AnimatedExitState>(),
    PageItem.more: GlobalKey<AnimatedExitState>(),
  };
  Map<PageItem, GlobalKey<AnimatedEntryState>> entryAnimationKeys = {
    PageItem.dashboard: GlobalKey<AnimatedEntryState>(),
    PageItem.careSchedule: GlobalKey<AnimatedEntryState>(),
    PageItem.more: GlobalKey<AnimatedEntryState>(),
  };

  /// Holds the currently active page.
  PageItem currentPage = PageItem.dashboard;

  /// Notifies child pages when a tab switch completes so they can reload data.
  final ValueNotifier<int> tabSwitchNotifier = ValueNotifier<int>(0);

  /// Controls the Page View
  final PageController pageController = PageController();
  double pagePosition = 0;

  /// Indicates whether swiping is disabled
  bool swipeDisabled = false;

  /// With 3 fixed tabs, all pages are always visible.
  List<PageItem> get _visiblePages => orderedPageItems();

  /// Temporarily disable swiping for certain pages e.g. in app web view
  void setSwipeDisabled({bool disableSwipe = false}) {
    setState(() {
      swipeDisabled = disableSwipe;
    });
  }

  /// Switches to another page when selected in the nav-menu on phones
  Future<bool> selectedPage(PageItem selectedPageItem) async {
    if (selectedPageItem == currentPage) return true;

    final pages = _visiblePages;
    if (!pages.contains(selectedPageItem)) return false;

    // Phone Layout
    if (MediaQuery.of(context).size.shortestSide < 600) {
      final int indexNewPage = pages.indexWhere((element) => element == selectedPageItem);

      // Switch to the selected page
      await pageController.animateToPage(
        indexNewPage,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
      );

      // Tablet Layout
    } else {
      // Reset the exit animation of the new page to make the content visible again
      exitAnimationKeys[selectedPageItem]?.currentState?.resetExitAnimation();
      // Start the exit animation of the old page
      await exitAnimationKeys[currentPage]?.currentState?.startExitAnimation();
      // Switch to the new page
      setState(() => currentPage = selectedPageItem);
      // Start the entry animation of the new page
      await entryAnimationKeys[selectedPageItem]?.currentState?.startEntryAnimation();
    }

    // Enable swiping upon navigation
    setSwipeDisabled();

    // Notify child pages to reload data after tab switch
    tabSwitchNotifier.value++;

    return true;
  }

  /// Returns the [NavBarNavigator] for the specified PageItem on phones
  Widget buildNavigator(PageItem tabItem) {
    return NavBarNavigator(
      mainNavigatorKey: widget.mainNavigatorKey,
      navigatorKey: navigatorKeys[tabItem]!,
      pageItem: tabItem,
      pageEntryAnimationKey: entryAnimationKeys[tabItem]!,
      pageExitAnimationKey: exitAnimationKeys[tabItem]!,
      tabSwitchNotifier: tabSwitchNotifier,
    );
  }

  /// Wraps the [NavBarNavigator] that holds the displayed page in an [Offstage] widget
  /// in order to stack them and show only the active page.
  /// Only used for tablets.
  Widget buildOffstateNavigator(PageItem tabItem) {
    return Offstage(
      offstage: currentPage != tabItem,
      child: NavBarNavigator(
        mainNavigatorKey: widget.mainNavigatorKey,
        navigatorKey: navigatorKeys[tabItem]!,
        pageItem: tabItem,
        pageEntryAnimationKey: entryAnimationKeys[tabItem]!,
        pageExitAnimationKey: exitAnimationKeys[tabItem]!,
        tabSwitchNotifier: tabSwitchNotifier,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    pageController.addListener(() {
      setState(() => pagePosition = pageController.page ?? 0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final isLight = theme.brightness == Brightness.light;
    final visiblePages = _visiblePages;

    final systemUiStyle = isPhone
        ? (isLight
            ? SystemUiOverlayStyle(
                statusBarBrightness: Brightness.light,
                statusBarColor: colorScheme.surface,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: colorScheme.surface,
                systemNavigationBarIconBrightness: Brightness.dark,
              )
            : const SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark,
                statusBarColor: Color(0xFF0E1420),
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: Color(0xFF111926),
                systemNavigationBarIconBrightness: Brightness.light,
              ))
        : (isLight
            ? SystemUiOverlayStyle(
                statusBarBrightness: Brightness.light,
                statusBarColor: colorScheme.surfaceContainerHighest,
                statusBarIconBrightness: Brightness.dark,
                systemNavigationBarColor: colorScheme.surfaceContainerHighest,
                systemNavigationBarIconBrightness: Brightness.dark,
              )
            : const SystemUiOverlayStyle(
                statusBarBrightness: Brightness.dark,
                statusBarColor: Color(0xFF111926),
                statusBarIconBrightness: Brightness.light,
                systemNavigationBarColor: Color(0xFF111926),
                systemNavigationBarIconBrightness: Brightness.light,
              ));

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: systemUiStyle,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          final nav = navigatorKeys[currentPage]?.currentState;
          if (nav == null) return;
          unawaited(nav.maybePop());
        },
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: colorScheme.surface,
          body: isPhone
              // Phone layout
              ? SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          bottom: bottomNavBarHeight + MediaQuery.of(context).padding.bottom,
                        ),
                        child: PageView.builder(
                          physics: swipeDisabled ? const NeverScrollableScrollPhysics() : const ScrollPhysics(),
                          controller: pageController,
                          itemCount: visiblePages.length,
                          onPageChanged: (page) {
                            // Find new PageItem and assign newPage the old value in case no element is found
                            final PageItem newPage = visiblePages[page];

                            // Set newPage as the currentPage
                            if (newPage != currentPage) {
                              setState(() => currentPage = newPage);
                            }
                          },
                          itemBuilder: (context, index) {
                            return AnimatedOpacity(
                              opacity: pagePosition - index < 0
                                  // Navigate left -> blend out the right page
                                  ? pagePosition - index + 1 >= 0.9
                                      ? 1
                                      : pagePosition - index + 1 <= 0.1
                                          ? 0
                                          : pagePosition - index + 1
                                  // Navigate right -> blend out the left page
                                  : (1 - (pagePosition - index)) >= 0.9
                                      ? 1
                                      : 1 - (pagePosition - index) <= 0.1
                                          ? 0
                                          : 1 - (pagePosition - index),
                              duration: const Duration(milliseconds: 100),
                              child: buildNavigator(
                                visiblePages[index],
                              ),
                            );
                          },
                        ),
                      ),
                      // BottomNavigationBar
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: BottomNavBar(
                          currentPage: currentPage,
                          pages: visiblePages,
                          onSelectedPage: selectedPage,
                        ),
                      ),
                    ],
                  ),
                )
              // Tablet layout
              : SafeArea(
                  child: Container(
                    color: colorScheme.surfaceContainerHighest,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 20,
                          color: colorScheme.surfaceContainerHighest,
                        ),
                        Expanded(
                          child: Row(
                            children: [
                              SideNavBar(
                                currentPage: currentPage,
                                pages: visiblePages,
                                onSelectedPage: selectedPage,
                              ),
                              // Pages
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: colorScheme.surface,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: 550,
                                      child: Stack(
                                        children: visiblePages.map(buildOffstateNavigator).toList(),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Detail space
                              Container(
                                width: 20,
                                color: colorScheme.surfaceContainerHighest,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 20,
                          color: colorScheme.surfaceContainerHighest,
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

/// Exception thrown when a plant is not found by ID.
class PlantNotFoundException implements Exception {
  final String plantId;
  const PlantNotFoundException(this.plantId);

  @override
  String toString() => 'Plant not found: $plantId';
}
