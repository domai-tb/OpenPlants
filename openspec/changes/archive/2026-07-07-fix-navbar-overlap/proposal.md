## Why

The bottom navigation bar overlaps page content, causing buttons and interactive elements to be partially hidden behind the navbar. This is visible in the plant detail page (where "Mark as" buttons are cut off) and the plant collection page (where the FAB positioning is affected). The root cause is a mismatch between the navbar height (88px iOS / 98px Android) and the bottom padding reserved for pages (80px iOS / 60px Android).

## What Changes

- Extract navbar height into a shared constant used by both the navbar widget and all pages
- Update the `PageView.builder` bottom padding in `home_page.dart` to match the actual navbar height
- Add bottom padding to scrollable pages that currently don't account for the navbar (e.g., plant detail page)
- Ensure FABs are positioned above the navbar, not behind it
- Document the navbar height contract for future page development

## Capabilities

### New Capabilities

- `navbar-layout-spacing`: A shared layout constant defining the bottom navigation bar height, ensuring consistent spacing between the navbar and page content across all feature pages.

### Modified Capabilities

*(No existing capability requirements are changing — this is a layout fix, not a behavior change.)*

## Impact

- **Modified files:**
  - `lib/pages/home/home_page.dart` — update bottom padding to match navbar height
  - `lib/pages/home/widgets/bottom_nav_bar.dart` — extract height to a shared constant
  - `lib/pages/plant_collection/plant_collection_detail_page.dart` — add bottom padding for navbar overlap
  - `lib/pages/plant_collection/plant_collection_page.dart` — verify FAB positioning
  - `lib/pages/care_schedule/care_schedule_page.dart` — verify bottom padding
  - `lib/pages/today_dashboard/today_dashboard_page.dart` — verify bottom padding
  - Other feature pages — audit and fix if needed
- **No new dependencies**
- **No breaking changes** — purely additive layout adjustments
