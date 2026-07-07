## 1. l10n — Add Navigation Key

- [x] 1.1 Add `careScheduleGoToCollection` key to `assets/l10n/l10n_en.arb` with value "Go to Plant Collection"
- [x] 1.2 Add `careScheduleGoToCollection` key to `assets/l10n/l10n_de.arb` with value "Zur Pflanzensammlung"
- [x] 1.3 Run `fvm flutter gen-l10n` to regenerate localizations

## 2. HomePage — Add Navigation Callbacks

- [x] 2.1 Add `_onNavigateToAddPlant()` method to `HomePageState` that calls `selectedPage(PageItem.plantCollection)` then pushes `PlantCollectionFormPage` on `navigatorKeys[PageItem.plantCollection]`
- [x] 2.2 Add `_onNavigateToPlantCollection()` method to `HomePageState` that calls `selectedPage(PageItem.plantCollection)`
- [x] 2.3 Pass `_onNavigateToAddPlant` as `onNavigateToAddPlant` callback when constructing `TodayDashboardPage` in `buildNavigator()` and `buildOffstateNavigator()`
- [x] 2.4 Pass `_onNavigateToPlantCollection` as `onNavigateToPlantCollection` callback when constructing `NavBarNavigator` for `PageItem.careSchedule`

## 3. NavBarNavigator — Plumb Care Schedule Callback

- [x] 3.1 Add `VoidCallback? onNavigateToPlantCollection` parameter to `NavBarNavigator`
- [x] 3.2 Pass it through to `CareSchedulePage` constructor in `_routeBuilders()` for `PageItem.careSchedule`

## 4. CareSchedulePage — Pass Callback to Empty State

- [x] 4.1 Add `VoidCallback? onNavigateToPlantCollection` parameter to `CareSchedulePage` constructor
- [x] 4.2 Pass it to `EmptyScheduleState` constructor in the `_tasks.isEmpty` branch of `build()`

## 5. EmptyScheduleState — Fix Navigation & l10n

- [x] 5.1 Add `VoidCallback? onNavigateToPlantCollection` parameter to `EmptyScheduleState`
- [x] 5.2 Replace `Navigator.of(context).pop()` in button `onPressed` with `onNavigateToPlantCollection?.call()`
- [x] 5.3 Replace hardcoded `Text('No care tasks yet')` with `Text(context.l10n.careScheduleEmpty)` (reuse existing key as the primary heading)
- [x] 5.4 Replace hardcoded `Text('Go to Plant Collection')` with `Text(context.l10n.careScheduleGoToCollection)`

## 6. TodayDashboard — Replace Dead pushNamed Calls

- [x] 6.1 Add `VoidCallback? onNavigateToAddPlant` parameter to `TodayDashboardPage` constructor
- [x] 6.2 Replace `mainNavigatorKey.currentState?.pushNamed('/plant_collection/add')` in `_QuickActionStrip` with `onNavigateToAddPlant?.call()`
- [x] 6.3 Replace `mainNavigatorKey.currentState?.pushNamed('/plant_collection/add')` in `_OnboardingEmptyState` with `onNavigateToAddPlant?.call()`
- [x] 6.4 Remove `mainNavigatorKey` parameter from `_QuickActionStrip` and `_OnboardingEmptyState` if no longer needed (check for other uses in those widgets)
- [x] 6.5 Remove `mainNavigatorKey` parameter from `TodayDashboardPage` if no longer used elsewhere

## 7. Verification

- [x] 7.1 Run `fvm flutter analyze` and resolve any lint violations
- [x] 7.2 Run `fvm flutter test` to verify existing tests still pass
- [x] 7.3 Manual smoke test: open Today Dashboard with empty collection, tap "Add Plant" → verify it opens the add-plant form on the Plant Collection tab
- [x] 7.4 Manual smoke test: open Care Schedule with no plants, tap "Go to Plant Collection" → verify it switches to the Plant Collection tab without crashing

## 8. Data Refresh After Tab Switch

- [x] 8.1 Add `ValueNotifier<int> tabSwitchNotifier` to `HomePageState` that increments on every `selectedPage()` call
- [x] 8.2 Pass `tabSwitchNotifier` through `NavBarNavigator` to `TodayDashboardPage` and `CareSchedulePage`
- [x] 8.3 `TodayDashboardPage` subscribes to notifier and reloads data on tab switch
- [x] 8.4 `CareSchedulePage` subscribes to notifier and reloads data on tab switch
