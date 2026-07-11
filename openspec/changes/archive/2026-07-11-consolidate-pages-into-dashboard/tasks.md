## 1. Foundation — Reduce PageItem enum and navigation structure

- [x] 1.1 Removed `PageItem.plantCollection`, `PageItem.plantIdentification`, `PageItem.speciesLibrary` from the `PageItem` enum; kept only `dashboard`, `careSchedule`, `more`
- [x] 1.2 Renamed `PageItem.todayDashboard` to `PageItem.dashboard` across all references
- [x] 1.3 Removed route builders for deleted pages from `_routeBuilders()`
- [x] 1.4 Removed `onSwitchToSpeciesLibrary`, `onNavigateToAddPlant`, `onNavigateToPlantDetail`, `onNavigateToPlantCollection` callbacks
- [x] 1.5 Updated bottom nav bar (3 fixed `Expanded` items, no scroll); side nav bar widgets already clean
- [x] 1.6 Replaced `orderedPageItemsFromSettings()`/`hiddenPageItemsFromSettings()` with `orderedPageItems()` returning hardcoded 3-item list
- [x] 1.7 Removed `NavBarPreferencesEditor` from `MoreSettingsPage` and `onboarding.dart`; deleted `nav_bar_preferences_editor.dart`
- [x] 1.8 Removed `navBarItemOrder` and `hiddenNavBarItems` from `Settings` model, `copyWith`, JSON serialization
- [x] 1.9 Removed unused localization keys (`navigationLabel`, `navigationOrderHint`, `navigationVisibilityLabel`, `navigationSettingsAlwaysVisibleHint`, `careScheduleGoToCollection`, `speciesLibraryTitle`); kept `plantCollectionTitle` (grid section header) and `plantIdentificationTitle` (modal title)
- [x] 1.10 `fvm flutter analyze lib/` — No issues found

## 2. Core — Unified Dashboard (merge today_dashboard + plant_collection)

- [x] 2.1 Created `PlantGridSection` widget with search bar, filter chips (care status + room), and 2-column plant card grid
- [x] 2.2 Data loading logic built into `PlantGridSection` (loads plants, room names, filters)
- [x] 2.3 Added plant grid section to `TodayDashboardPage._buildBody()` with search bar and filter chips below due/overdue task sections
- [x] 2.4 "Add Plant" quick action opens `PlantCollectionFormPage` on dashboard's navigator stack
- [x] 2.5 "Identify" quick action opens `PlantIdentificationPage.showAsModal(context)` (full-screen modal)
- [x] 2.6 Empty state preserved — shows `_OnboardingEmptyState` with "Add your first plant" button when `data.isEmpty`
- [x] 2.7 Removed `recentPlants`/`PlantSummary` from `DashboardData` entity; simplified datasource
- [x] 2.8 Removed `PlantCollectionPage` widget file (grid extracted to `PlantGridSection`; form/detail pages kept)
- [x] 2.9 Plant card tap navigates to `PlantCollectionDetailPage` on dashboard's own navigator stack
- [x] 2.10 `fvm flutter analyze lib/` — No issues found

## 3. Feature — Identification as modal (remove tab, wrap as dialog)

- [x] 3.1 Added `showAsModal(context)` static method on `PlantIdentificationPage` opening via `showModalBottomSheet` (full-screen, drag-dismissible)
- [x] 3.2 Removed `AnimatedEntry`/`AnimatedExit` wrapping and tab animation parameters
- [x] 3.3 Result actions preserved: species result card opens `SpeciesDetailPage` on root navigator; "Add to collection" navigates to `PlantCollectionFormPage`
- [x] 3.4 `PlantIdentificationPage` retained as the modal widget file (converted to modal entry point — no longer a standalone tab page)
- [x] 3.5 Dashboard "Identify" quick action calls `PlantIdentificationPage.showAsModal(context)`
- [x] 3.6 `fvm flutter analyze lib/` — No issues found

## 4. Feature — Species library page removal

- [x] 4.1 Removed `SpeciesLibraryPage` widget file (`species_library_page.dart` deleted)
- [x] 4.2 `SpeciesDetailPage` remains reachable from identification modal (tapping species result opens detail on root navigator)
- [x] 4.3 `onViewSpeciesLibrary` callback removed from `PlantIdentificationPage` (species detail now pushed directly from modal)
- [x] 4.4 `fvm flutter analyze lib/` — No issues found; no dangling imports

## 5. Settings cleanup

- [x] 5.1 `NavBarItemOrderEditor` removed (was part of `nav_bar_preferences_editor.dart` — deleted)
- [x] 5.2 `NavBarVisibilityEditor` removed (same file)
- [x] 5.3 `navBarItemOrder` and `hiddenNavBarItems` removed from `Settings` entity, JSON serialization, constructor, and `copyWith`; old values silently ignored on load
- [x] 5.4 `fvm flutter analyze lib/` — No issues found

## 6. Localization cleanup

- [x] 6.1 Removed unused l10n keys: `navigationLabel`, `navigationOrderHint`, `navigationVisibilityLabel`, `navigationSettingsAlwaysVisibleHint`, `careScheduleGoToCollection`, `speciesLibraryTitle`; kept `plantCollectionTitle` (grid header) and `plantIdentificationTitle` (modal title)
- [x] 6.2 Same removals applied to `l10n_de.arb`
- [x] 6.3 `fvm flutter gen-l10n` regenerated; no warnings
- [x] 6.4 `fvm flutter analyze lib/` — No issues found

## 7. Tests

- [x] 7.1 No unit tests reference removed `PageItem` enum values
- [x] 7.2 No unit tests reference `PlantCollectionPage` directly
- [x] 7.3 Added `test/plant_grid_section_test.dart` — 7 tests: loading state, empty state, search toggle, filter chips, plant grid rendering, card tap callback
- [x] 7.4 Added `test/identification_modal_test.dart` — 4 tests: modal opens, capture prompt visible, camera/gallery buttons, modal dismissible
- [x] 7.5 Added `test/bottom_nav_bar_test.dart` — 5 tests: renders 3 items, correct labels, active highlighting, tap callback, active icon state
- [x] 7.6 No widget tests depend on the old 6-item navigation structure
- [x] 7.7 `fvm flutter test` — 233 pass, 15 pre-existing failures (light_assessment mockito issue, unrelated)
- [x] 7.8 `fvm flutter analyze lib/` — No issues found
