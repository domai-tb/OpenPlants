## Why

When a user creates a new plant and explicitly selects "Happy" care status, the plant immediately shows as "need water" and "need fertilizer" in the UI. This happens because `effectiveCareStatus` overrides the stored `happy` status whenever `lastWateredAt` or `lastFertilizedAt` are null — which they always are for newly created plants. The user's explicit status choice is silently ignored.

## What Changes

- Set `lastWateredAt` and `lastFertilizedAt` to creation time when a new plant is created with `CareStatus.happy`
- This ensures the `effectiveCareStatus` getter respects the user's explicit status choice

## Capabilities

### New Capabilities

(none)

### Modified Capabilities

- `plant-inventory`: Care status initialization at plant creation time must respect the user-selected status

## Impact

- `lib/pages/plant_collection/plant_collection_form_page.dart` — plant creation form (add timestamps)
- `lib/pages/plant_collection/plant_collection_item_entity.dart` — no change needed, logic already correct when timestamps are set
- Existing plants with null timestamps will continue to show `needsWater`/`needsFertilizer` until watered/fertilized (existing behavior preserved)
