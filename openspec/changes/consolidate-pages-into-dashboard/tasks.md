## 1. Foundation — Reduce PageItem enum and navigation structure

- [ ] 1.1 Remove `PageItem.plantCollection`, `PageItem.plantIdentification`, `PageItem.speciesLibrary` from the `PageItem` enum in `page_navigator.dart`; keep only `todayDashboard` (rename to `dashboard`), `careSchedule`, and `more`
- [ ] 1.2 Rename `PageItem.todayDashboard` to `PageItem.dashboard` across all references — update enum, all switch/match statements, `pageItemPresentation()`, and navigation keys in `home_page.dart`
- [ ] 1.3 Remove `NavBarNavigator` route builders for `plantCollection`, `plantIdentification`, and `speciesLibrary` from `_routeBuilders()` in `page_navigator.dart`
- [ ] 1.4 Remove `onSwitchToSpeciesLibrary`, `onNavigateToAddPlant`, `onNavigateToPlantDetail`, `onNavigateToPlantCollection` callbacks from `NavBarNavigator` — the unified dashboard handles navigation internally
- [ ] 1.5 Update `nav_bar.dart` widgets (`bottom_nav_bar.dart`, `side_nav_bar.dart`, `bottom_nav_bar_item.dart`, `side_nav_bar_item.dart`) to render 3 items instead of up to 6; remove scrollable behavior from bottom nav bar
- [ ] 1.6 Update `orderedPageItemsFromSettings()` and `hiddenPageItemsFromSettings()` in `page_navigator.dart` — with fixed 3-tab layout, these functions return the hardcoded list `[dashboard, careSchedule, more]` instead of reading from settings
- [ ] 1.7 Remove nav bar ordering/hiding settings UI from `MoreSettingsPage` — the `NavBarItemOrderEditor` and `NavBarVisibilityEditor` widgets are no longer needed
- [ ] 1.8 Remove `navBarItemOrder` and `hiddenNavBarItems` fields from `SettingsController` and settings serialization (JSON schema, defaults, load/save)
- [ ] 1.9 Remove `PageItemPresentation` unused localization strings for `plantCollectionTitle`, `plantIdentificationTitle`, `speciesLibraryTitle` if no longer referenced elsewhere
- [ ] 1.10 Run `fvm flutter analyze` and resolve any compilation errors from the PageItem and navigation changes

## 2. Core — Unified Dashboard (merge today_dashboard + plant_collection)

- [ ] 2.1 Extract the plant grid/search/filter UI from `PlantCollectionPage` into a reusable widget `PlantGridSection` (StatelessWidget that takes `List<PlantEntity>`, room map, search/filter callbacks) — keep the rendering logic, remove the page scaffolding
- [ ] 2.2 Extract the plant grid data-loading logic (plants, room names, journal counts) from `PlantCollectionPage._load()` — move to `TodayDashboardUsecases.getDashboardData()` or a new method on the usecases
- [ ] 2.3 Expand `TodayDashboardPage._buildBody()` to include the plant grid section: add search bar, filter chips (care status, room), and `PlantGridSection` below the existing due/overdue task sections
- [ ] 2.4 Update the quick-action strip so "Add Plant" opens `PlantCollectionFormPage` on the dashboard's navigator stack directly (no tab switch)
- [ ] 2.5 Update the quick-action strip so "Identify" opens the identification modal (full-screen dialog)
- [ ] 2.6 Update the empty state — when collection is empty, show the onboarding prompt with "Add your first plant" button instead of sections
- [ ] 2.7 Update `DashboardData` entity to include all plants (or remove the `recentPlants` field since the full grid replaces the carousel) — adjust `TodayDashboardUsecases` and datasource accordingly
- [ ] 2.8 Remove `PlantCollectionPage` widget file (its grid is now in `PlantGridSection`, its form/detail pages stay)
- [ ] 2.9 Update `TodayDashboardPage` to handle plant card tap — navigate to `PlantCollectionDetailPage` on the dashboard's own navigator stack
- [ ] 2.10 Run `fvm flutter analyze` and verify the unified dashboard compiles without errors

## 3. Feature — Identification as modal (remove tab, wrap as dialog)

- [ ] 3.1 Wrap the existing `PlantIdentificationPage` widget body (camera, inference, results) into a reusable `IdentificationModal` that can be shown via `showDialog()` or `Navigator.push()` as a full-screen dialog
- [ ] 3.2 Remove the `AnimatedEntry`/`AnimatedExit` wrapping from the identification flow (modal doesn't need tab animation wrappers)
- [ ] 3.3 Add result actions to the identification modal: "Add to collection" button navigates to `PlantCollectionFormPage` with top species pre-selected; tapping a species result card opens `SpeciesDetailPage` on the root navigator
- [ ] 3.4 Remove `PlantIdentificationPage` as a standalone widget (keep the logic in the modal)
- [ ] 3.5 Wire the identification entry point: dashboard "Identify" quick action opens `IdentificationModal`; remove the old tab-based navigation path
- [ ] 3.6 Run `fvm flutter analyze` and verify identification modal compiles

## 4. Feature — Species library page removal

- [ ] 4.1 Remove `SpeciesLibraryPage` widget file
- [ ] 4.2 Ensure `SpeciesDetailPage` is still reachable from:
  - Identification modal (tapping a species result)
  - Plant detail page (tapping the plant's species name)
  - Direct navigation from any `SpeciesLibraryUsecases` consumer
- [ ] 4.3 Remove `onViewSpeciesLibrary` callback from `PlantIdentificationPage` (moved to modal flow in task 3.3)
- [ ] 4.4 Run `fvm flutter analyze` and verify no dangling imports

## 5. Settings cleanup

- [ ] 5.1 Remove `NavBarItemOrderEditor` widget file from settings page
- [ ] 5.2 Remove `NavBarVisibilityEditor` widget file from settings page
- [ ] 5.3 Clean up settings JSON schema: remove `navBarItemOrder` and `hiddenNavBarItems` from default settings, serialization, and `Settings` entity; add migration to ignore old values on load
- [ ] 5.4 Run `fvm flutter analyze` and verify settings compile and load without errors

## 6. Localization cleanup

- [ ] 6.1 Remove unused l10n strings for deleted page titles (`plantCollectionTitle`, `plantIdentificationTitle`, `speciesLibraryTitle`, and any nav bar configuration strings) — verify no code references remain
- [ ] 6.2 Remove unused nav bar configuration strings from German locale (`l10n_de.arb`)
- [ ] 6.3 Run `fvm flutter gen-l10n` to regenerate localization code
- [ ] 6.4 Run `fvm flutter analyze` to verify no localization warnings

## 7. Tests

- [ ] 7.1 Update any unit tests that reference removed `PageItem` enum values (`plantCollection`, `plantIdentification`, `speciesLibrary`)
- [ ] 7.2 Update any unit tests that reference `PlantCollectionPage` directly — retarget to unified dashboard tests
- [ ] 7.3 Add unit tests for the unified dashboard: verify quick actions, task sections, plant grid rendering, search/filter, empty state
- [ ] 7.4 Add unit tests for identification modal: verify modal opens, camera/gallery buttons, results display, "Add to collection" navigation
- [ ] 7.5 Add unit tests for reduced nav bar: verify 3 items render, no scroll behavior, active item animation
- [ ] 7.6 Update any widget tests that depend on the old 6-item navigation structure
- [ ] 7.7 Run `fvm flutter test` and verify all tests pass
- [ ] 7.8 Run `fvm flutter analyze` and verify zero lint issues
