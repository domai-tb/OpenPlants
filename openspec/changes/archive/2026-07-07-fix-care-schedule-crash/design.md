## Context

The Care Schedule page (`lib/pages/care_schedule/care_schedule_page.dart`) is a real feature built with the full 5-file pattern (datasource → repository → usecases → entity → page). It's registered in `PageItem.careSchedule`, has its own nav bar entry, and all DI wiring is correct.

However, `HomePage` (`lib/pages/home/home_page.dart`) manages three maps that hold per-tab state:

- `navigatorKeys: Map<PageItem, GlobalKey<NavigatorState>>` — per-tab Navigator keys
- `exitAnimationKeys: Map<PageItem, GlobalKey<AnimatedExitState>>` — per-tab exit animation controllers
- `entryAnimationKeys: Map<PageItem, GlobalKey<AnimatedEntryState>>` — per-tab entry animation controllers

These maps were initialized when the app had placeholder page1–page6. When `careSchedule` was introduced as a new `PageItem`, the maps were never updated. The `!` operator on `navigatorKeys[tabItem]!`, `entryAnimationKeys[tabItem]!`, and `exitAnimationKeys[tabItem]!` (used in both `buildNavigator` and `buildOffstateNavigator`) throws when `tabItem` is `PageItem.careSchedule` because the map returns `null`.

## Goals / Non-Goals

**Goals:**
- Add the missing `PageItem.careSchedule` entry to all three per-tab state maps
- Verify the Care Schedule page loads without crashing on navigation
- Extend the pattern: the same issue could affect other tabs added in the future

**Non-Goals:**
- Refactoring the map initialization pattern (that's a separate improvement)
- Changing the Care Schedule page itself (it's correct)
- Adding tests (no test infrastructure for widget-level integration yet)

## Decisions

### Decision 1: Add entries to all three maps

The fix is three one-line additions in `home_page.dart`:

```dart
Map<PageItem, GlobalKey<NavigatorState>> navigatorKeys = {
    PageItem.todayDashboard: GlobalKey<NavigatorState>(),
    PageItem.careSchedule: GlobalKey<NavigatorState>(),   // ← ADD
    ...
};

Map<PageItem, GlobalKey<AnimatedExitState>> exitAnimationKeys = {
    PageItem.todayDashboard: GlobalKey<AnimatedExitState>(),
    PageItem.careSchedule: GlobalKey<AnimatedExitState>(), // ← ADD
    ...
};

Map<PageItem, GlobalKey<AnimatedEntryState>> entryAnimationKeys = {
    PageItem.todayDashboard: GlobalKey<AnimatedEntryState>(),
    PageItem.careSchedule: GlobalKey<AnimatedEntryState>(), // ← ADD
    ...
};
```

**Alternative considered:** Initializing maps lazily or dynamically from `PageItem.values`. Rejected — this is a small, targeted fix. Refactoring the initialization pattern is a larger change that belongs in a separate cleanup.

### Decision 2: Fix stale default nav bar order

The `_defaultNavBarOrder` in `settings.dart` still references `page1` (which no longer exists as a PageItem) and is missing `careSchedule` and `speciesLibrary`. While this doesn't crash (the `orderedPageItemsFromSettings` fallback appends missing items), it means the out-of-box tab order is wrong on fresh installs — the default shows a phantom `page1`-labeled tab and doesn't surface the Care Schedule at all.

Fix: replace `'page1'` with `'todayDashboard'`, add `'careSchedule'` and `'speciesLibrary'` to the default order. This is a one-line list edit in the same file realm as the bug fix.

## Risks / Trade-offs

- **[Risk] Similar missing entries for future tabs** — The manual map pattern is fragile. **Mitigation:** Accept for now. A follow-up could refactor to `Map.fromIterable(PageItem.values, ...)` to automatically include all enum values.
- **[Risk] The `careSchedule` page still crashes after this fix** — If there's a secondary issue in the page itself. **Mitigation:** Verify with a manual smoke test after the fix.
