## Why

OpenPlants currently has 6 top-level pages (Dashboard, Care Schedule, Plant Identification, Plant Collection, Species Library, More), but several of them overlap in purpose or are better suited as modal actions rather than persistent destinations. The dashboard shows only a 3-plant carousel while the full plant collection lives on a separate page. Identification is a camera action, not a browsing destination. The species library is an encyclopedia that duplicates data already consumed invisibly by care schedules and plant details. This fragmentation forces users to navigate between tabs for tasks that should feel like one context.

Consolidating reduces cognitive overhead, removes redundant navigation, and makes the dashboard — the first thing users see — the actual hub for managing plants.

## What Changes

- **Dashboard becomes the plant hub**: The current `TodayDashboardPage` and `PlantCollectionPage` merge into one unified dashboard page that shows quick actions, care tasks, and the full plant grid (with search, filter by status, filter by room). The dashboard is no longer an empty canvas for new users — it becomes the plant management surface. **BREAKING** — `PlantCollectionPage` is removed as a top-level tab; its navigation entry and `PageItem.plantCollection` enum value are deleted.

- **Identification becomes a modal action**: The `PlantIdentificationPage` is removed as a top-level tab. The camera → classify → results flow is triggered via a quick-action button or FAB from the dashboard, presented as a full-screen modal or bottom sheet. After identification, users can add the plant directly to their collection without tab-switching. **BREAKING** — `PageItem.plantIdentification` enum value is deleted.

- **Species library page removed from navigation**: The `SpeciesLibraryPage` is no longer reachable via bottom nav. Its underlying data (`SpeciesEntity`, `SpeciesLibraryUsecases`) remains fully intact — it powers care plans, identification matching, and plant detail care info. Direct species browsing is removed; the species detail page is still reachable from identification results (when a match is found) and from plant detail pages (showing care info for an identified species). **BREAKING** — `PageItem.speciesLibrary` enum value is deleted.

- **Bottom navigation reduced to 3 tabs**: Dashboard (unified hub), Care Schedule, and More. This replaces the current 6-tab layout. The `More` page absorbs any entry points that don't fit the other two tabs (Rooms, Settings, About, Log Symptom, Diagnosis).

- **Page detail navigation simplified**: Since there's no separate plant collection tab, tapping a plant card on the dashboard pushes the detail page onto the dashboard's own navigator stack (same pattern as current dashboard → plant detail, but now the dashboard is always the root).

## Capabilities

### New Capabilities
- `unified-dashboard`: Combined plant hub showing quick actions, care tasks (due/overdue), full searchable/filterable plant grid, and room/status filters. Replaces both `today-dashboard` and `plant-inventory` as top-level pages.

### Modified Capabilities
- `today-dashboard`: Complete rewrite — no longer a standalone page. Merged into `unified-dashboard`. Dashboard now owns the full plant grid, search, and filters previously in `plant-inventory`.
- `plant-inventory`: Removed as a standalone page. Plant grid, search, and filter capabilities merge into `unified-dashboard`.
- `identification-ui`: No longer a top-level page. Camera capture, classification, and results flow move to a modal/sheet triggered from the dashboard quick actions or FAB.
- `species-browse`: Removed as a navigable page. Species browsing capability is eliminated; species data becomes invisible backend infrastructure consumed by identification, care schedule, and plant detail.
- `navbar-layout-spacing`: Navigation bar reduced from 6 items to 3 (Dashboard, Care, More). Layout, animation, and item configuration updated.
- `scrollable-nav-bar`: Updated for 3-item navigation.

## Impact

- **Files modified**: `home_page.dart` (remove 3 PageItems, update nav building), `page_navigator.dart` (remove 3 enum values, update route builders), `bottom_nav_bar.dart` / `side_nav_bar.dart` (fewer items), `settings.dart` (remove hidden nav items for deleted pages), `today_dashboard_page.dart` (major expansion — add plant grid, search, filters), `more_page.dart` (may absorb some entry points), `injection.dart` (no change unless new UseCases needed)
- **Files removed**: `plant_collection_page.dart` (entire file), `plant_collection_detail_page.dart` (no — this stays, reached from dashboard navigator stack), `species_library_page.dart`, `species_detail_page.dart` (no — species detail stays reachable from identification results and plant detail), `plant_identification_page.dart` (as a page — camera capture/inference logic moves into a reusable widget/sheet)
- **Files created**: None expected if identification becomes a modal sheet within the existing page; possibly a `dashboard_plant_grid.dart` widget extracted from the old `PlantCollectionPage`
- **Tests**: Navigation tests updated; plant collection page tests removed or migrated; identification page tests re-targeted to modal flow
- **Localization**: No new strings beyond what the dashboard already has; some page title strings may become unused (plant collection title, species library title)
- **Data**: No schema changes — `PlantEntity`, `SpeciesEntity`, settings, and persistence remain untouched
