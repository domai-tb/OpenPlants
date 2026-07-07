## Context

The app uses a multi-navigator architecture: a root `MaterialApp` navigator (via `mainNavigatorKey`) that hosts `HomePage`, and separate `Navigator` widgets per tab created by `NavBarNavigator`. Cross-tab navigation must go through the `HomePageState` which owns all navigator keys and the `selectedPage()` tab-switching method.

**Bug 1 — Today Dashboard "Add Plant" does nothing:**

The dashboard's quick-action strip and empty-state CTA both call `mainNavigatorKey.currentState?.pushNamed('/plant_collection/add')`. The root navigator has no route registered for this path (and no `onGenerateRoute`), so `pushNamed` silently fails — the `?.` operator swallows the error. The intended behavior is to switch to the plant_collection tab and open the add-plant form.

```
┌─ Root Navigator (mainNavigatorKey) ─────────────────┐
│  HomePage                                            │
│                                                      │
│  ┌─ Tab: todayDashboard ─────────────────────────┐   │
│  │  _QuickActionStrip                             │   │
│  │    pushNamed('/plant_collection/add') ──❌──  │   │
│  │    Route doesn't exist → silent failure         │   │
│  └────────────────────────────────────────────────┘   │
│                                                      │
│  ┌─ Tab: plantCollection ─────────────────────────┐   │
│  │  PlantCollectionPage                            │   │
│  │  _addPlant(): Navigator.of(context).push(...) ✓  │   │
│  └────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────┘
```

**Bug 2 — Care Schedule "Go to Plant Collection" crashes:**

The `EmptyScheduleState` widget calls `Navigator.of(context).pop()` when tapped. Since the widget is rendered as the root (and only) route of the care_schedule tab's `Navigator`, there's nothing to pop back to. Flutter's `Navigator.pop()` asserts `_history.isNotEmpty: is not true` when called from the root route.

```
┌─ Tab: careSchedule Navigator ──────────────────────┐
│  Root route '/'                                     │
│  CareSchedulePage → EmptyScheduleState              │
│    Navigator.of(context).pop() ──💥──               │
│    Assertion: _history.isNotEmpty: is not true      │
│                                                     │
│  (history has 1 entry — only the root route)        │
└─────────────────────────────────────────────────────┘
```

## Goals / Non-Goals

**Goals:**
- Fix the "Add Plant" button on the Today Dashboard so it navigates to the plant_collection tab and opens the add-plant form
- Fix the "Go to Plant Collection" button on the Care Schedule empty state so it switches to the plant_collection tab
- Use the existing `navigatorKeys` and `selectedPage()` infrastructure in `HomePageState` — no new state management
- Replace hardcoded strings in `EmptyScheduleState` with l10n keys

**Non-Goals:**
- No changes to the root MaterialApp routing or adding onGenerateRoute
- No new state management patterns or DI changes
- No refactoring of the navigation architecture (which works fine for its normal flow)
- No changes to the plant_collection page or its form

## Decisions

### Decision 1: Callback-based cross-tab navigation

Pass `VoidCallback` closures from `HomePageState` down to the child pages instead of exposing navigator keys or adding route-based navigation on the root navigator.

**Rationale:** The `HomePageState` already owns the three things needed:
1. `navigatorKeys[PageItem.plantCollection]` — the tab's navigator
2. `selectedPage()` — switches visible tab
3. Import access to `PlantCollectionFormPage` — the target widget

A callback keeps the navigation logic centralized in `HomePageState` and avoids leaking navigator keys or navigator context across tab boundaries.

**Alternative considered:** Registering routes on the root `MaterialApp.onGenerateRoute`. Rejected because the root navigator shouldn't know about tab-internal routes — that breaks the encapsulation of the multi-navigator pattern.

**Alternative considered:** Exposing `navigatorKeys` through `AppScope` or a service. Rejected as over-engineering for two simple callbacks.

### Decision 2: Today Dashboard "Add Plant" → switch tab + push form

The callback for the dashboard chains `selectedPage(PageItem.plantCollection)` with `navigatorKeys[PageItem.plantCollection]?.currentState?.push(MaterialPageRoute(...))`. This matches the existing pattern in `PlantCollectionPage._addPlant()`.

### Decision 3: Care Schedule "Go to Plant Collection" → switch tab only

The callback for the care schedule empty state only calls `selectedPage(PageItem.plantCollection)`. The user lands on the plant_collection tab with the FAB visible — they can tap "+" to add a plant or view their existing collection. This is less intrusive than auto-pushing the form and gives the user context.

### Decision 4: Minimal l10n additions

Add one new l10n key `careScheduleGoToCollection` for the button label in `EmptyScheduleState`. The title "No care tasks yet" is replaced by using the existing subtitle `careScheduleEmpty` as the primary text (it already says "Add plants to see care tasks"), eliminating the need for a separate title string.

## Risks / Trade-offs

- **Risk: Adding callbacks increases HomePage's surface area.** → Mitigation: Two simple `VoidCallback` closures, each a few lines. If the pattern proliferates, future work could centralize navigation actions in a dedicated service.
- **Trade-off: Callback chaining may glitch during tab animation.** → Using `then()` after `selectedPage()` ensures the form push only happens after the tab switch completes. If the form pushes during animation, the navigator key will be ready since the navigator was already constructed.
- **Risk: Existing hardcoded strings were already present before this change.** → The `EmptyScheduleState` already has a hardcoded "No care tasks yet" heading. We address this by consolidating to the existing l10n `careScheduleEmpty` string, reducing hardcoded surface.
