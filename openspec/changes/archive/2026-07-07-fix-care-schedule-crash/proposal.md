## Why

The Care Schedule page crashes with "Null check operator used on a null value" when the user navigates to it. This is a hard crash — the page becomes completely unusable.

The root cause is in `home_page.dart`: the three maps that hold navigator keys, entry animation keys, and exit animation keys for each tab (`navigatorKeys`, `exitAnimationKeys`, `entryAnimationKeys`) were never given an entry for `PageItem.careSchedule`. When the Care Schedule tab became a real feature page (replacing a placeholder), the maps weren't updated. When `buildNavigator(PageItem.careSchedule)` or `buildOffstateNavigator(PageItem.careSchedule)` is called, the `!` operator on `navigatorKeys[tabItem]!` (and the animation key lookups) throws because the key doesn't exist in the map.

## What Changes

- Add `PageItem.careSchedule` entries to the three per-tab maps in `home_page.dart` (`navigatorKeys`, `exitAnimationKeys`, `entryAnimationKeys`)
- Fix the stale `_defaultNavBarOrder` in `settings.dart`: replace the defunct `page1` with `todayDashboard`, add the missing `careSchedule` and `speciesLibrary` entries

## Capabilities

### New Capabilities
*(None — this is a bug fix, not a new feature.)*

### Modified Capabilities
*(None — no requirement changes.)*

## Impact

- **Modified files**:
  - `lib/pages/home/home_page.dart` — 3 lines added to map initializers
  - `lib/core/settings.dart` — `_defaultNavBarOrder` list updated
- **No new dependencies**
- **No breaking changes**
- **No migration needed**
