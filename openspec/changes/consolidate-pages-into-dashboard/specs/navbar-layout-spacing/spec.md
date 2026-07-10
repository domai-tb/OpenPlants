## MODIFIED Requirements

### Requirement: Shared navbar height constant
The system SHALL define a single constant `kBottomNavBarHeight` that represents the height of the bottom navigation bar. This constant SHALL be used by both the navbar widget and all pages that need to account for navbar spacing.

#### Scenario: Navbar uses the shared constant
- **WHEN** the `BottomNavBar` widget renders
- **THEN** its height SHALL be exactly `kBottomNavBarHeight` pixels

#### Scenario: Pages reference the shared constant
- **WHEN** any page calculates bottom padding or positions elements relative to the navbar
- **THEN** it SHALL use `kBottomNavBarHeight` instead of hardcoded values

### Requirement: PageView reserves navbar space
The `PageView.builder` in `home_page.dart` SHALL have bottom padding equal to `kBottomNavBarHeight` plus the system navigation bar inset. This ensures page content is never hidden behind the navbar.

#### Scenario: Page content is visible above navbar
- **WHEN** the app renders on any device
- **THEN** the bottom of page content SHALL be at least `kBottomNavBarHeight + systemNavigationBarHeight` pixels from the screen bottom edge

### Requirement: Pages do not add redundant bottom padding
Feature pages with scrollable content SHALL NOT add their own bottom padding to compensate for the navbar. The PageView's centralized padding handles this.

#### Scenario: Dashboard does not double-pad
- **WHEN** the unified dashboard renders its CustomScrollView
- **THEN** the scroll view's bottom padding SHALL NOT include an additional offset for the navbar

## REMOVED Requirements

### Requirement: FABs are not hidden behind navbar
**Reason**: With only 3 tabs, there is no standalone plant collection page with a FAB. The unified dashboard uses the quick-action strip and does not have a FAB. This requirement is no longer applicable.

**Migration**: Remove any FAB-related positioning logic that referenced `kBottomNavBarHeight`.

### Requirement: Scroll-to-top button respects navbar height
**Reason**: The scroll-to-top button behavior is unchanged where it exists (More page). This requirement is moved away from navbar-layout-spacing and into the individual page specs if needed. No migration is needed for existing functionality.
