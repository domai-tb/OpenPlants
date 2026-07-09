## Why

Tapping a plant on the Today Dashboard's recent-plants carousel currently does nothing useful. The tap handler exists (line 605 of `today_dashboard_page.dart`) but calls `pushNamed('/plant_collection/detail/${plant.id}')` on a route that was never registered — the `onGenerateRoute` in `page_navigator.dart` only handles the root `/` route. Users expect tapping a plant to open its detail page, just as they can from the Plant Collection tab.

## What Changes

- Wire the today dashboard plant-tap gesture to navigate to the existing `PlantCollectionDetailPage`
- Add a callback-based cross-tab navigation path (following the `onNavigateToAddPlant` pattern) so the today dashboard can hand off a plant ID to the plant collection tab
- Extend the today dashboard usecases to fetch a full `PlantEntity` by ID, since the carousel only holds `PlantSummary` objects (id, name, photo, updatedAt) but the detail page requires a full `PlantEntity`
- Optionally: also wire care-task cards to navigate to their plant's detail page

## Capabilities

### New Capabilities

- `dashboard-plant-detail-navigation`: Tapping a plant or care task on the Today Dashboard navigates to that plant's detail page in the Plant Collection tab

### Modified Capabilities

- `navigation-fixes`: Add a requirement for Today Dashboard plant-tap navigating to plant detail (mirrors the existing "Add Plant navigates to add form" pattern)

## Impact

- `lib/pages/today_dashboard/today_dashboard_page.dart` — tap handler and new callback parameter
- `lib/pages/today_dashboard/today_dashboard_usecases.dart` — new `getPlantById` method
- `lib/pages/today_dashboard/today_dashboard_repository.dart` — fetch full plant entity
- `lib/pages/today_dashboard/today_dashboard_datasource.dart` — data access for single plant
- `lib/pages/home/page_navigator.dart` — pass new callback through to today dashboard
- `lib/pages/home/home_page.dart` — implement the callback (switch tab + push detail)
- No new dependencies required
