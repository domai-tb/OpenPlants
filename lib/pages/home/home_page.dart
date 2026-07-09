import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/core/constants.dart';
import 'package:open_plant/core/settings.dart';
import 'package:open_plant/pages/home/page_navigator.dart';
import 'package:open_plant/pages/home/widgets/page_navigation_animation.dart';
import 'package:open_plant/pages/home/widgets/bottom_nav_bar.dart';
import 'package:open_plant/pages/home/widgets/side_nav_bar.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_detail_page.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_form_page.dart';

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
    PageItem.todayDashboard: GlobalKey<NavigatorState>(),
    PageItem.careSchedule: GlobalKey<NavigatorState>(),
    PageItem.plantIdentification: GlobalKey<NavigatorState>(),
    PageItem.more: GlobalKey<NavigatorState>(),
    PageItem.plantCollection: GlobalKey<NavigatorState>(),
    PageItem.speciesLibrary: GlobalKey<NavigatorState>(),
  };

  /// Creates two [GlobalKey] for each page in order to control the exit- and
  /// entry-animation from outside the page
  Map<PageItem, GlobalKey<AnimatedExitState>> exitAnimationKeys = {
    PageItem.todayDashboard: GlobalKey<AnimatedExitState>(),
    PageItem.careSchedule: GlobalKey<AnimatedExitState>(),
    PageItem.plantIdentification: GlobalKey<AnimatedExitState>(),
    PageItem.more: GlobalKey<AnimatedExitState>(),
    PageItem.plantCollection: GlobalKey<AnimatedExitState>(),
    PageItem.speciesLibrary: GlobalKey<AnimatedExitState>(),
  };
  Map<PageItem, GlobalKey<AnimatedEntryState>> entryAnimationKeys = {
    PageItem.todayDashboard: GlobalKey<AnimatedEntryState>(),
    PageItem.careSchedule: GlobalKey<AnimatedEntryState>(),
    PageItem.plantIdentification: GlobalKey<AnimatedEntryState>(),
    PageItem.more: GlobalKey<AnimatedEntryState>(),
    PageItem.plantCollection: GlobalKey<AnimatedEntryState>(),
    PageItem.speciesLibrary: GlobalKey<AnimatedEntryState>(),
  };

  final SystemUiOverlayStyle lightSystemUiStyle = const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light, // iOS
    statusBarColor: Colors.white, // Android
    statusBarIconBrightness: Brightness.dark, // Android
    systemNavigationBarColor: Colors.white, // Android
    systemNavigationBarIconBrightness: Brightness.dark, // Android
  );
  final SystemUiOverlayStyle darkSystemUiStyle = const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark, // iOS
    statusBarColor: Color.fromRGBO(14, 20, 32, 1), // Android
    statusBarIconBrightness: Brightness.light, // Android
    systemNavigationBarColor: Color.fromRGBO(17, 25, 38, 1), // Android
    systemNavigationBarIconBrightness: Brightness.light, // Android
  );
  final SystemUiOverlayStyle lightTabletSystemUiStyle = const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.light, // iOS
    statusBarColor: Color.fromRGBO(245, 246, 250, 1), // Android
    statusBarIconBrightness: Brightness.dark, // Android
    systemNavigationBarColor: Color.fromRGBO(245, 246, 250, 1), // Android
    systemNavigationBarIconBrightness: Brightness.dark, // Android
  );
  final SystemUiOverlayStyle darkTabletSystemUiStyle = const SystemUiOverlayStyle(
    statusBarBrightness: Brightness.dark, // iOS
    statusBarColor: Color.fromRGBO(17, 25, 38, 1), // Android
    statusBarIconBrightness: Brightness.light, // Android
    systemNavigationBarColor: Color.fromRGBO(17, 25, 38, 1), // Android
    systemNavigationBarIconBrightness: Brightness.light, // Android
  );

  /// Holds the currently active page.
  PageItem currentPage = PageItem.todayDashboard;

  /// Notifies child pages when a tab switch completes so they can reload data.
  final ValueNotifier<int> tabSwitchNotifier = ValueNotifier<int>(0);
  late SettingsController _settingsController;
  bool _settingsWired = false;

  /// Controls the Page View
  final PageController pageController = PageController();
  double pagePosition = 0;

  /// Indicates whether swiping is disabled
  bool swipeDisabled = false;

  List<PageItem> get _orderedPages => orderedPageItemsFromSettings(
        _settingsController.settings.navBarItemOrder,
      );

  Set<PageItem> get _hiddenPages => hiddenPageItemsFromSettings(
        _settingsController.settings.hiddenNavBarItems,
      );

  List<PageItem> get _visiblePages => _orderedPages.where((page) => !_hiddenPages.contains(page)).toList();

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

  /// Switches to the Plant Collection tab and opens the add-plant form.
  void _onNavigateToAddPlant() {
    unawaited(
      selectedPage(PageItem.plantCollection).then((_) {
        navigatorKeys[PageItem.plantCollection]?.currentState?.push(
              MaterialPageRoute(builder: (_) => const PlantCollectionFormPage()),
            );
      }),
    );
  }

  /// Switches to the Plant Collection tab and opens the detail page for the
  /// given plant ID.
  void _onNavigateToPlantDetail(String plantId) {
    unawaited(
      selectedPage(PageItem.plantCollection).then((_) {
        if (!mounted) return;
        final usecases = AppScope.of(context).services.plantCollection;
        usecases.loadPlants().then((plants) {
          final plant = plants.firstWhere(
            (p) => p.id == plantId,
            orElse: () => throw PlantNotFoundException(plantId),
          );
          navigatorKeys[PageItem.plantCollection]?.currentState?.push(
                MaterialPageRoute(builder: (_) => PlantCollectionDetailPage(plant: plant)),
              );
        }).catchError((Object error) {
          if (error is PlantNotFoundException && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Plant not found')),
            );
          }
        });
      }),
    );
  }

  /// Switches to the Plant Collection tab.
  void _onNavigateToPlantCollection() {
    unawaited(selectedPage(PageItem.plantCollection));
  }

  /// Returns the [NavBarNavigator] for the specified PageItem on phones
  Widget buildNavigator(PageItem tabItem) {
    return NavBarNavigator(
      mainNavigatorKey: widget.mainNavigatorKey,
      navigatorKey: navigatorKeys[tabItem]!,
      pageItem: tabItem,
      pageEntryAnimationKey: entryAnimationKeys[tabItem]!,
      pageExitAnimationKey: exitAnimationKeys[tabItem]!,
      onSwitchToSpeciesLibrary:
          tabItem == PageItem.plantIdentification ? () => selectedPage(PageItem.speciesLibrary) : null,
      onNavigateToAddPlant: tabItem == PageItem.todayDashboard ? _onNavigateToAddPlant : null,
      onNavigateToPlantDetail: tabItem == PageItem.todayDashboard ? _onNavigateToPlantDetail : null,
      onNavigateToPlantCollection: tabItem == PageItem.careSchedule ? _onNavigateToPlantCollection : null,
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
        onSwitchToSpeciesLibrary:
            tabItem == PageItem.plantIdentification ? () => selectedPage(PageItem.speciesLibrary) : null,
        onNavigateToAddPlant: tabItem == PageItem.todayDashboard ? _onNavigateToAddPlant : null,
        onNavigateToPlantDetail: tabItem == PageItem.todayDashboard ? _onNavigateToPlantDetail : null,
        onNavigateToPlantCollection: tabItem == PageItem.careSchedule ? _onNavigateToPlantCollection : null,
        tabSwitchNotifier: tabSwitchNotifier,
      ),
    );
  }

  void _handleSettingsChanged() {
    if (!mounted) return;

    final visiblePages = _visiblePages;
    if (visiblePages.isEmpty) return;

    final nextPage = visiblePages.contains(currentPage) ? currentPage : visiblePages.first;
    final nextIndex = visiblePages.indexOf(nextPage);

    if (pageController.hasClients) {
      final currentIndex = pageController.page?.round() ?? pageController.initialPage;
      if (currentIndex != nextIndex) {
        pageController.jumpToPage(nextIndex);
      }
    }

    if (currentPage != nextPage) {
      setState(() => currentPage = nextPage);
      return;
    }

    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    pageController.addListener(() {
      setState(() => pagePosition = pageController.page ?? 0);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_settingsWired) return;

    _settingsController = AppScope.of(context).settings;
    _settingsController.addListener(_handleSettingsChanged);

    final visiblePages = _visiblePages;
    if (visiblePages.isNotEmpty) {
      currentPage = visiblePages.first;
    }

    _settingsWired = true;
  }

  @override
  void dispose() {
    if (_settingsWired) {
      _settingsController.removeListener(_handleSettingsChanged);
    }
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPhone = MediaQuery.of(context).size.shortestSide < 600;
    final isLight = theme.brightness == Brightness.light;
    final visiblePages = _visiblePages;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isPhone
          ? (isLight ? lightSystemUiStyle : darkSystemUiStyle)
          : (isLight ? lightTabletSystemUiStyle : darkTabletSystemUiStyle),
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
          backgroundColor: theme.colorScheme.surface,
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
                    color: isLight ? const Color.fromRGBO(245, 246, 250, 1) : theme.cardColor,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 20,
                          color: isLight ? const Color.fromRGBO(245, 246, 250, 1) : theme.cardColor,
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
                                    color: theme.colorScheme.surface,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: Center(
                                    child: SizedBox(
                                      width: currentPage != PageItem.plantIdentification ? 550 : null,
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
                                color: isLight ? const Color.fromRGBO(245, 246, 250, 1) : theme.cardColor,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: 20,
                          color: isLight ? const Color.fromRGBO(245, 246, 250, 1) : theme.cardColor,
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
