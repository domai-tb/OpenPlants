## 1. Extract Shared Constants

- [x] 1.1 Create `lib/core/constants.dart` with `kBottomNavBarHeight` constant (98 for Android, 88 for iOS) and `kNavBarItemWidth` constant (80)
- [x] 1.2 Update `lib/pages/home/widgets/bottom_nav_bar.dart` to use `kBottomNavBarHeight` from constants instead of hardcoded values
- [x] 1.3 Update `lib/pages/home/widgets/bottom_nav_bar.dart` to use `kNavBarItemWidth` from constants instead of hardcoded 80

## 2. Fix PageView Bottom Padding

- [x] 2.1 Update `lib/pages/home/home_page.dart` PageView.builder bottom padding to use `kBottomNavBarHeight + MediaQuery.of(context).padding.bottom` instead of hardcoded 80/60
- [x] 2.2 Verify the padding accounts for both iOS and Android system navigation bars correctly

## 3. Remove Redundant Page-Level Padding

- [x] 3.1 Update `lib/pages/plant_collection/plant_collection_page.dart` ListView to remove the `Platform.isIOS ? 110 : 90` bottom padding offset
- [x] 3.2 Update `lib/pages/today_dashboard/today_dashboard_page.dart` SliverPadding to remove the `Platform.isIOS ? 110 : 90` bottom padding offset
- [x] 3.3 Audit other feature pages for redundant bottom padding and remove if present

## 4. Fix FAB Positioning

- [x] 4.1 Update `lib/pages/plant_collection/plant_collection_page.dart` FAB to use `Scaffold.bottomNavigationBar` or adjust positioning to avoid navbar overlap
- [x] 4.2 Verify FAB is fully visible and tappable above the navbar

## 5. Update Scroll-to-Top Button

- [x] 5.1 Update `lib/widgets/scroll_to_top_button.dart` to use `kBottomNavBarHeight` from constants for bottom offset
- [x] 5.2 Update `lib/pages/plant_collection/plant_collection_page.dart` ScrollToTopButton bottomOffset to use the shared constant

## 6. Audit and Fix Remaining Pages

- [x] 6.1 Audit `lib/pages/care_schedule/care_schedule_page.dart` for bottom padding issues
- [x] 6.2 Audit `lib/pages/plant_identification/plant_identification_page.dart` for bottom padding issues
- [x] 6.3 Audit `lib/pages/species_library/species_library_page.dart` for bottom padding issues
- [x] 6.4 Audit `lib/pages/page2/page2_page.dart` through `lib/pages/page6/page6_page.dart` for bottom padding issues
- [x] 6.5 Fix any identified issues in audited pages

## 7. Verification

- [x] 7.1 Run `fvm flutter analyze` and resolve any lint issues
- [x] 7.2 Run `fvm flutter test` to verify existing tests still pass
- [x] 7.3 Manual smoke test: verify plant detail page "Mark as" buttons are fully visible
- [x] 7.4 Manual smoke test: verify plant collection FAB is above navbar
- [x] 7.5 Manual smoke test: verify all scrollable pages have content ending above navbar
