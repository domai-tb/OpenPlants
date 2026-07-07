## Why

Navigating to the plant collection from empty-state surfaces is broken in two places: the Today Dashboard's quick-action "Add Plant" button silently does nothing, and the Care Schedule's "Go to Plant Collection" button crashes with an assertion error. Both are critical UX blockages — the two features that most need the user to *have* plants both fail when trying to help the user *add* plants.

## What Changes

- **Today Dashboard quick-action "Add Plant"** — replaces the dead `pushNamed('/plant_collection/add')` call on the root navigator with proper navigation that switches to the plant_collection tab and opens the add-plant form
- **Today Dashboard empty-state CTA "Add your first plant"** — same fix, same broken route call
- **Care Schedule empty-state "Go to Plant Collection"** — replaces the `Navigator.pop()` crash on the root route with proper cross-tab navigation to the plant_collection tab
- **Navigation wiring** — adds a callback plumbing layer from `HomePage` (which owns all tab navigator keys) down to `TodayDashboardPage` and `CareSchedulePage` so they can trigger cross-tab navigation correctly

## Capabilities

### New Capabilities
- *(none — this is a bug-fix change that modifies existing feature code without introducing new capabilities)*

### Modified Capabilities
- *(no spec-level requirement changes — navigation behavior is an implementation detail of the existing features)*

## Impact

- **lib/pages/today_dashboard/today_dashboard_page.dart** — quick-action strip and empty-state button handlers change from `mainNavigatorKey.pushNamed(...)` to a callback that switches to plant_collection tab and pushes the add-plant form
- **lib/pages/care_schedule/care_schedule_page.dart** — passes navigation callback to `EmptyScheduleState`
- **lib/pages/care_schedule/widgets/empty_schedule_state.dart** — button handler changes from `Navigator.pop()` to a callback that switches to plant_collection tab; replaces hardcoded "No care tasks yet" and "Go to Plant Collection" with l10n strings
- **lib/pages/home/home_page.dart** — provides the cross-tab navigation callbacks when constructing `TodayDashboardPage` and `CareSchedulePage`
- **lib/pages/home/page_navigator.dart** — passes new callbacks through to `CareSchedulePage`
- **lib/l10n/** — may add one or two new l10n keys for the empty schedule state if existing keys don't fit
- **No new dependencies. No breaking changes.**
