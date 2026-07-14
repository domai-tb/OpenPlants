## 1. Add Missing Navigation Keys

- [x] 1.1 Add `PageItem.careSchedule: GlobalKey<NavigatorState>()` to the `navigatorKeys` map in `lib/pages/home/home_page.dart`
- [x] 1.2 Add `PageItem.careSchedule: GlobalKey<AnimatedExitState>()` to the `exitAnimationKeys` map in `lib/pages/home/home_page.dart`
- [x] 1.3 Add `PageItem.careSchedule: GlobalKey<AnimatedEntryState>()` to the `entryAnimationKeys` map in `lib/pages/home/home_page.dart`

## 2. Fix Stale Default Nav Bar Order

- [x] 2.1 Update `_defaultNavBarOrder` in `lib/core/settings.dart` — replace `'page1'` with `'todayDashboard'`, add `'careSchedule'`, add `'speciesLibrary'`

## 3. Verification

- [x] 3.1 Run `fvm flutter analyze` — zero new lint violations
- [x] 3.2 Run `fvm flutter test` — all existing tests pass
- [x] 3.3 Manual smoke test: tap the Care Schedule tab and confirm the page loads without crashing; verify overdue, due-today, and upcoming task sections render correctly
- [x] 3.4 Manual smoke test: switch between tabs (Today Dashboard → Care Schedule → Plant Collection → back to Care Schedule) to verify tab switching doesn't trigger the crash
