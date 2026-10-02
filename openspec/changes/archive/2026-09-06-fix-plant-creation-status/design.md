## Context

The plant collection form creates new plants with a `CareStatus` enum value but no `lastWateredAt`/`lastFertilizedAt` timestamps. The `effectiveCareStatus` getter in `PlantEntity` overrides the stored status when these timestamps are null, causing newly created "happy" plants to show as needing care.

Current flow:
1. User selects "Happy" in the form
2. Form creates `PlantEntity(careStatus: CareStatus.happy)` — timestamps are null
3. `effectiveCareStatus` sees null `lastWateredAt` → returns `needsWater`
4. UI displays "need water" and "need fertilizer" despite user's explicit choice

## Goals / Non-Goals

**Goals:**
- Respect the user's explicit care status selection at plant creation time
- Initialize `lastWateredAt` and `lastFertilizedAt` when creating a plant with `CareStatus.happy`
- Preserve existing behavior for plants created before this fix

**Non-Goals:**
- Changing the `effectiveCareStatus` logic itself (it's correct for the general case)
- Modifying how existing plants with null timestamps behave
- Adding UI to manually set timestamps during creation

## Decisions

**Set timestamps at creation time when status is happy.**
When the user creates a plant with `CareStatus.happy`, set both `lastWateredAt` and `lastFertilizedAt` to the creation timestamp. This makes the `effectiveCareStatus` getter return `happy` as expected.

Alternative considered: Modify `effectiveCareStatus` to not override `happy` when timestamps are null. Rejected because it would break the existing behavior where old plants with null timestamps correctly show as needing care.

**Only apply to happy status.**
If the user explicitly selects `needsWater` or `needsFertilizer`, we should NOT set timestamps — the plant should show that status. Only `CareStatus.happy` gets timestamp initialization.

## Risks / Trade-offs

- **Risk**: Plants created with this fix will appear as "recently watered" even if the user hasn't watered them. **Mitigation**: This is the correct semantic — a happy plant implies care is up to date.
- **Risk**: Existing plants with null timestamps continue to show needs-care. **Mitigation**: This is existing behavior and is correct — those plants genuinely haven't been watered/fertilized yet.
