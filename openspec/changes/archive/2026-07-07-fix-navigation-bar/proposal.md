## Why

The bottom navigation bar overflows when many pages are visible (up to 9 possible tabs). Items are not symmetrically centered because each `PageItem` has different `iconPaddingLeft`/`iconPaddingRight` values, and the bar uses a static `Row` with `spaceEvenly` that can't adapt to varying content widths. The bar should rotate/scroll horizontally so the active item is always centered and the user can swipe to access other tabs.

## What Changes

- Replace the static `Row`-based `BottomNavBar` with a scrollable carousel that centers the active page item
- Remove per-item asymmetric padding (`iconPaddingLeft`/`iconPaddingRight`) in favor of uniform spacing
- Add horizontal scroll physics so the bar rotates around the active item
- Ensure the bar automatically scrolls to center the selected item on tap
- Maintain the existing active-item animation (slide up + label fade-in)

## Capabilities

### New Capabilities

- `scrollable-nav-bar`: A horizontally scrollable bottom navigation bar that centers the active item and rotates/swipes to reveal other tabs when content overflows

### Modified Capabilities

<!-- None — this is a UI fix, not a spec-level behavior change -->

## Impact

- **Files modified**: `lib/pages/home/widgets/bottom_nav_bar.dart`, `lib/pages/home/widgets/bottom_nav_bar_item.dart`, `lib/pages/home/page_navigator.dart`
- **No API changes**: The `BottomNavBar` widget signature stays the same (currentPage, pages, onSelectedPage)
- **No dependency changes**: Uses only Flutter built-in widgets
- **Behavioral change**: Navigation bar becomes horizontally scrollable on phones; tablet layout unaffected
