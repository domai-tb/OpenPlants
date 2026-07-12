## Context

The care schedule and plant collection are two independent features that share the same underlying data (plants). Currently, completing a care task in the schedule only persists a `TaskCompletion` record and creates a journal entry — it never touches the plant entity. The plant's `effectiveCareStatus` is derived from `lastWateredAt`/`lastFertilizedAt` timestamps, which are only updated by the "Mark as Watered"/"Mark as Fertilized" buttons on the plant detail page.

This means two features disagree about the same plant's state after a task is completed from the schedule view.

## Goals / Non-Goals

**Goals:**
- When a watering task is completed from the care schedule, update the plant's `lastWateredAt` timestamp and reset `careStatus` to `happy` (if it was `needsWater`)
- When a fertilizing task is completed from the care schedule, update the plant's `lastFertilizedAt` timestamp and reset `careStatus` to `happy` (if it was `needsFertilizer`)
- Reuse existing `markAsWatered()` and `markAsFertilized()` methods — no new persistence logic
- Graceful degradation: if the plant status update fails, the task completion still succeeds

**Non-Goals:**
- Changing how `effectiveCareStatus` is computed (no changes to `PlantEntity`)
- Updating plant status on snooze or skip (only direct completion)
- Adding status updates for other task types (misting, pruning, etc.) — these don't have corresponding plant status fields
- Migrating existing data — plants will self-correct on next task completion

## Decisions

### Decision 1: Update plant status inside `completeTask()` after recording completion

**Choice:** Add plant status update logic in `CareScheduleUsecases.completeTask()`, after the `repository.recordCompletion()` call and the journal entry creation.

**Rationale:** This is the single entry point for task completion. The `CareScheduleUsecases` class already has `PlantCollectionUsecases` injected (used in `getSchedule()`), so no new dependencies are needed.

**Alternatives considered:**
- *Event bus / listener pattern:* Over-engineered for this use case. The direct call is simpler and matches the existing pattern in `symptom_logger_usecases.dart`.
- *Update in the UI layer:* Fragile — would require every call site to handle the update, and would miss programmatic completions.

### Decision 2: Load the plant by ID before updating

**Choice:** Call `plantCollection.getPlantById(task.plantId)` to load the plant, then pass it to `markAsWatered()` or `markAsFertilized()`.

**Rationale:** The `markAsWatered`/`markAsFertilized` methods expect a `PlantEntity` instance. Loading by ID is safe (returns `null` if not found) and avoids loading all plants.

### Decision 3: Only update for `watering` and `fertilizing` task types

**Choice:** Check `task.taskType.builtIn` against `BuiltInTaskType.watering` and `BuiltInTaskType.fertilizing` before updating.

**Rationale:** These are the only two task types that map to plant status fields (`lastWateredAt`, `lastFertilizedAt`). Other task types (misting, pruning, etc.) have no corresponding plant status, so updating would be incorrect.

### Decision 4: Wrap in try/catch for graceful degradation

**Choice:** Wrap the plant update in a try/catch block, logging errors but not failing the task completion.

**Rationale:** Matches the existing pattern used for journal entry creation (lines 138-150). A plant status update failure should not prevent the user from completing their task.

## Risks / Trade-offs

**[Risk] Race condition if user completes task and edits plant simultaneously** → Low risk. Both operations use SharedPreferences which serializes writes. The last write wins, and both are updating the same plant entity.

**[Risk] Plant deleted between task completion and status update** → Mitigated by null check on `getPlantById()`. If the plant is gone, we skip the update silently.

**[Trade-off] Snooze/skip don't update plant status** → Intentional. Snooze and skip are deferral actions, not actual care events. The plant hasn't been watered or fertilized, so updating timestamps would be incorrect.

**[Trade-off] Custom task types don't trigger status updates** → Acceptable. Custom types have no predefined status mapping. Users can still mark plants as watered/fertilized from the detail page.
