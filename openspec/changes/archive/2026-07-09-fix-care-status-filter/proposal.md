## Why

The collection page's "Needs Water" and "Needs Fertilizer" filters rely on a manually-set `careStatus` field that defaults to `happy`. A plant that has never been watered (`lastWateredAt == null`) or never been fertilized (`lastFertilizedAt == null`) never appears in the corresponding filter because nothing ever sets its `careStatus` to `needsWater` or `needsFertilizer`. This makes the filter functionally broken for plants that have never received care — exactly the plants the filter should surface.

## What Changes

- **`filterByCareStatus` becomes smarter**: When filtering for `needsWater`, return plants whose effective care status is `needsWater` — this includes plants with `careStatus == needsWater` OR `lastWateredAt == null` (never watered). Same logic for `needsFertilizer` / `lastFertilizedAt == null`.
- **Add `effectiveCareStatus` to the entity**: A computed getter on `PlantEntity` that returns the effective care status, giving priority to the manually-set flag but falling back to inferring from `lastWateredAt` / `lastFertilizedAt`.
- **Care status display respects effective status**: The colored dot on tiles and the detail page use the effective status so the UI is consistent with the filter.

No breaking changes. No schema migration needed — the stored `careStatus` field is unchanged; only the runtime interpretation broadens.

## Capabilities

### New Capabilities

*(none — this is a bug fix on existing capabilities)*

### Modified Capabilities

- `care-tracking`: The "Filter by needs-water" and "Filter by needs-fertilizer" scenarios gain the rule that plants with `lastWateredAt == null` or `lastFertilizedAt == null` (respectively) are included in the filter results, even when `careStatus` is `happy`. The "Care status is displayed on list" scenario reflects the effective/computed status.

## Impact

- **`lib/pages/plant_collection/plant_collection_item_entity.dart`** — Add `effectiveCareStatus` getter.
- **`lib/pages/plant_collection/plant_collection_usecases.dart`** — `filterByCareStatus` uses effective status.
- **`lib/pages/plant_collection/plant_collection_page.dart`** — Tile status indicator uses effective status.
- **`lib/pages/plant_collection/plant_collection_detail_page.dart`** — Detail page status indicator uses effective status.
- **`openspec/specs/care-tracking/spec.md`** — Delta spec updates the filtering and display scenarios.
- Tests: existing use-case tests will need updates for the broader filter semantics.
