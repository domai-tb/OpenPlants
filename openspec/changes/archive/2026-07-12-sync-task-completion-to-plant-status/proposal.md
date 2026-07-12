## Why

When a care task (watering, fertilizing) is marked as done in the care schedule, the plant's care status is not updated. The task disappears from the "due today" list, but the plant detail page, plant grid, and dashboard still show the plant as "Needs Water" or "Needs Fertilizer." This creates a confusing inconsistency where two parts of the app disagree about the same plant's state.

## What Changes

- Completing a watering task in the care schedule will now update the plant's `lastWateredAt` timestamp and set `careStatus` to `happy` (if it was `needsWater`), matching the behavior of the "Mark as Watered" button on the plant detail page.
- Completing a fertilizing task in the care schedule will similarly update `lastFertilizedAt` and reset `careStatus` to `happy` (if it was `needsFertilizer`).
- Snoozing or skipping a task will NOT update plant status (only direct completion does).
- The existing `markAsWatered()` and `markAsFertilized()` methods on `PlantCollectionUsecases` will be reused — no new persistence logic.

## Capabilities

### New Capabilities

_None._

### Modified Capabilities

- `care-tracking`: The requirement "Task completions auto-create journal entries" will be extended. In addition to creating journal entries, completing a watering or fertilizing task SHALL also update the plant's care status timestamps and effective care status. New scenarios will be added for this behavior.

## Impact

**Affected code:**
- `lib/pages/care_schedule/care_schedule_usecases.dart` — `completeTask()` method needs to call `plantCollection.markAsWatered()` or `markAsFertilized()` after recording completion
- `lib/pages/plant_collection/plant_collection_usecases.dart` — no changes needed (existing methods are reused)
- `lib/pages/care_schedule/schedule_engine.dart` — no changes needed (already recomputes from timestamps)

**No new dependencies.** The `CareScheduleUsecases` class already has `PlantCollectionUsecases` injected.

**No API changes.** This is purely internal behavior — the task completion flow now triggers a side effect on plant status.

**Data migration:** None. Existing plants with null `lastWateredAt` will start showing correct status once their next watering task is completed.
