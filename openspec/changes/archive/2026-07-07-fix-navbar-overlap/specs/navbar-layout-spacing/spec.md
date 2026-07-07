## ADDED Requirements

### Requirement: Shared navbar height constant
The system SHALL define a single constant `kBottomNavBarHeight` that represents the height of the bottom navigation bar. This constant SHALL be used by both the navbar widget and all pages that need to account for navbar spacing.

#### Scenario: Navbar uses the shared constant
- **WHEN** the `BottomNavBar` widget renders
- **THEN** its height SHALL be exactly `kBottomNavBarHeight` pixels

#### Scenario: Pages reference the shared constant
- **WHEN** any page calculates bottom padding or positions elements relative to the navbar
- **THEN** it SHALL use `kBottomNavBarHeight` instead of hardcoded values

### Requirement: PageView reserves navbar space
The `PageView.builder` in `home_page.dart` SHALL have bottom padding equal to `kBottomNavBarHeight` plus the system navigation bar inset (`MediaQuery.of(context).padding.bottom`). This ensures page content is never hidden behind the navbar.

#### Scenario: Android page content is visible above navbar
- **WHEN** the app runs on an Android device
- **THEN** the bottom of page content SHALL be at least `kBottomNavBarHeight + systemNavigationBarHeight` pixels from the screen bottom edge

#### Scenario: iOS page content is visible above navbar
- **WHEN** the app runs on an iOS device
- **THEN** the bottom of page content SHALL be at least `kBottomNavBarHeight + systemNavigationBarHeight` pixels from the screen bottom edge

### Requirement: Pages do not add redundant bottom padding
Feature pages with scrollable content SHALL NOT add their own bottom padding to compensate for the navbar. The PageView's centralized padding handles this.

#### Scenario: Plant collection list does not double-pad
- **WHEN** the plant collection page renders its ListView
- **THEN** the ListView's bottom padding SHALL NOT include an additional offset for the navbar

#### Scenario: Today dashboard does not double-pad
- **WHEN** the today dashboard page renders its CustomScrollView
- **THEN** the scroll view's bottom padding SHALL NOT include an additional offset for the navbar

### Requirement: FABs are not hidden behind navbar
Floating action buttons in feature pages SHALL be positioned above the bottom navigation bar, not behind it.

#### Scenario: Plant collection FAB is accessible
- **WHEN** the plant collection page shows a FloatingActionButton
- **THEN** the FAB SHALL be fully visible and tappable above the navbar

### Requirement: Scroll-to-top button respects navbar height
The `ScrollToTopButton` widget SHALL position itself above the navbar using the shared height constant.

#### Scenario: Scroll-to-top button does not overlap navbar
- **WHEN** the scroll-to-top button appears on a page with a navbar
- **THEN** the button SHALL be positioned at least `kBottomNavBarHeight` pixels from the bottom of the screen
