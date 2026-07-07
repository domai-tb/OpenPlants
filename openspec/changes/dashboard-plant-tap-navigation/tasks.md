## 1. Add onNavigateToPlantDetail callback plumbing

- [ ] 1.1 Add `onNavigateToPlantDetail` optional callback parameter to `TodayDashboardPage` (matching the `onNavigateToAddPlant` pattern)
- [ ] 1.2 Pass `onNavigateToPlantDetail` through `NavBarNavigator` in `page_navigator.dart` to `TodayDashboardPage`
- [ ] 1.3 Implement the callback in `home_page.dart`: switch to Plant Collection tab, look up `PlantEntity` by ID, push `PlantCollectionDetailPage`

## 2. Wire carousel tap to callback

- [ ] 2.1 Update `_RecentPlantsCarousel` to accept and call `onNavigateToPlantDetail` instead of using `pushNamed`
- [ ] 2.2 Remove the broken `mainNavigatorKey.currentState?.pushNamed(...)` call from the carousel tap handler

## 3. Add plant lookup to plant collection

- [ ] 3.1 Add `getPlantById(String id)` method to `PlantCollectionUsecases`
- [ ] 3.2 Implement the lookup in `PlantCollectionRepository` (search in-memory list or local data source)
- [ ] 3.3 Handle the "plant not found" case: return null, let `home_page.dart` show a snackbar

## 4. Wire care-task cards (optional follow-up)

- [ ] 4.1 Add `plantId` field to `CareTask` entity
- [ ] 4.2 Update today dashboard datasource to populate `plantId` when building care tasks
- [ ] 4.3 Add tap handler to `_CareTaskCard` that calls `onNavigateToPlantDetail` when `plantId` is non-null

## 5. Verify

- [ ] 5.1 Run `fvm flutter analyze` — no lint errors
- [ ] 5.2 Run `fvm flutter test` — existing tests pass
- [ ] 5.3 Manual verification: tap plant in carousel → detail page opens in plant collection tab
