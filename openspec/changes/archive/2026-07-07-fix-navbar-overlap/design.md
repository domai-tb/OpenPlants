## Context

OpenPlants uses a Stack-based layout in `home_page.dart` where the `BottomNavBar` is positioned via `Align(alignment: Alignment.bottomCenter)` on top of the page content. The `PageView.builder` containing all feature pages has a fixed bottom padding intended to reserve space for the navbar, but this padding doesn't match the actual navbar height.

Current state:
- **Navbar height**: 88px (iOS) / 98px (Android) — defined inline in `bottom_nav_bar.dart`
- **PageView bottom padding**: 80px (iOS) / 60px (Android) — defined inline in `home_page.dart`
- **Result**: 8px overlap on iOS, 38px overlap on Android

Pages handle bottom spacing inconsistently:
- `plant_collection_page.dart`: Uses `EdgeInsets.only(bottom: Platform.isIOS ? 110 : 90)` in ListView
- `today_dashboard_page.dart`: Uses `EdgeInsets.only(bottom: Platform.isIOS ? 110 : 90)` in SliverPadding
- `plant_collection_detail_page.dart`: Uses `EdgeInsets.all(16)` — no navbar adjustment at all
- Other pages: Varying approaches or none

## Goals / Non-Goals

**Goals:**
- Eliminate navbar overlap on all pages
- Create a single source of truth for navbar height
- Ensure all scrollable pages have adequate bottom padding
- Position FABs above the navbar, not behind it
- Prevent future regressions by establishing a clear contract

**Non-Goals:**
- Changing the navbar visual design or height
- Restructuring the Stack-based layout (would be a larger refactor)
- Adding dynamic height calculation based on safe area insets
- Tablet layout changes (side nav doesn't have this issue)

## Decisions

### Decision 1: Extract navbar height into a shared constant

**Chosen**: Define `kBottomNavBarHeight` as a top-level constant in `bottom_nav_bar.dart` (or a new shared constants file) and reference it everywhere.

**Alternatives considered:**
- Use `MediaQuery.of(context).padding.bottom` to calculate dynamically — rejected because the navbar is a fixed-height widget, not a system chrome element
- Pass height via InheritedWidget — overkill for a simple constant
- Hardcode in each page — prone to drift, already the source of the bug

**Rationale**: A single constant ensures consistency. The navbar height is a design constant, not a runtime value.

### Decision 2: Centralize bottom padding in home_page.dart

**Chosen**: The `PageView.builder` bottom padding should be `kBottomNavBarHeight + kSafeAreaBottomInset` where `kSafeAreaBottomInset` accounts for the system navigation bar (Android gestures / iOS home indicator).

**Current values:**
- Android: `kBottomNavBarHeight = 98` + system bar ~48px = ~146px total
- iOS: `kBottomNavBarHeight = 88` + system bar ~34px = ~122px total

The existing values (60/80) are significantly lower than needed.

**Alternatives considered:**
- Let each page handle its own bottom padding — rejected because it leads to inconsistent spacing and the current bug
- Use `Scaffold.bottomNavigationBar` instead of Stack — would require restructuring all pages, too invasive for a fix

**Rationale**: Centralizing in `home_page.dart` ensures all pages get consistent bottom spacing without individual page changes.

### Decision 3: Pages with scrollable content should NOT add their own bottom padding

**Chosen**: Remove per-page bottom padding adjustments (like the 110/90 in plant_collection and today_dashboard) since the PageView already handles it.

**Rationale**: Double-padding creates excessive whitespace. The PageView's padding is the single reservation for the navbar.

### Decision 4: FABs need explicit positioning

**Chosen**: FABs (like the one in plant_collection_page) should be positioned above the navbar by using `Scaffold.bottomNavigationBar` or `Padding` with the navbar height constant.

**Rationale**: FABs in a Stack behind the navbar will overlap. The cleanest fix is to ensure FABs are placed in a way that doesn't conflict with the navbar z-order.

## Risks / Trade-offs

- **[Risk] Pages with custom layouts may need individual adjustments** → Mitigation: Audit all feature pages; most use standard scrollable layouts that benefit from the centralized padding.
- **[Risk] Changing padding may affect scroll-to-top button positioning** → Mitigation: `ScrollToTopButton` already accepts `bottomOffset` parameter; update to use the shared constant.
- **[Trade-off] Increased padding reduces visible content area** → Accepted: The current layout is hiding content behind the navbar; proper spacing is more important than maximizing content density.
- **[Risk] System navigation bar height varies by device** → Mitigation: Use `MediaQuery.of(context).padding.bottom` for the system bar portion, but keep navbar height as a fixed constant.
