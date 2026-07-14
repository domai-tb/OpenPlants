## 1. Entity — Add effectiveCareStatus getter

- [x] 1.1 Add `effectiveCareStatus` getter to `PlantEntity` in `plant_collection_item_entity.dart` with priority logic: explicit override > lastWateredAt == null > lastFertilizedAt == null > stored careStatus
- [x] 1.2 Add inline doc comment explaining the priority ordering

## 2. Use-Case — Update filter to use effective status

- [x] 2.1 Modify `filterByCareStatus` in `plant_collection_usecases.dart` to filter by `p.effectiveCareStatus` instead of `p.careStatus`

## 3. UI — Update display indicators

- [x] 3.1 Update `_getCareStatusColor()` in `plant_collection_page.dart` to use `plant.effectiveCareStatus`
- [x] 3.2 Update `_getCareStatusColor()` and `_getCareStatusText()` in `plant_collection_detail_page.dart` to use `plant.effectiveCareStatus`

## 4. Tests — Add unit tests for effective status

- [x] 4.1 Create `test/plant_collection_usecases_test.dart` with tests for `effectiveCareStatus` — never-watered, never-fertilized, explicit override, both timestamps null, happy plant
- [x] 4.2 Add tests for `filterByCareStatus` with effective status — never-watered plant matches needsWater filter, never-fertilized plant matches needsFertilizer filter, happy plant matches neither

## 5. Verify

- [x] 5.1 Run `fvm flutter analyze` — zero new lint warnings
- [x] 5.2 Run `fvm flutter test` — all tests pass
