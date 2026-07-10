## Why

Care tasks completed in the schedule view (watering, fertilizing, etc.) leave no trace in the plant journal. A user looking at a plant's journal timeline sees gaps — no record of when they performed care, even though the care schedule engine tracks completions internally. This disconnects two core features: the journal should be the canonical timeline of everything that happened to a plant, including care events.

## What Changes

- **Auto-journal on task completion**: When a user marks a care task as done via `completeTask`, a `JournalEntry` of type `task` is automatically created in the plant journal for that plant, with a description of what was completed and any user-provided note.
- **Snooze and skip do NOT journal**: Only explicit "Mark done" creates a journal entry. Snoozing (defer) and skipping (reset anchor) are scheduling operations, not care events.
- **Wiring**: `CareScheduleUsecases` gains `PlantJournalUseCases` as a dependency so it can create journal entries at completion time.
- **Graceful degradation**: If journal creation fails, the task completion itself is not rolled back — the primary operation succeeds, and the failure is silently handled.
- No breaking changes. No schema migration. No new external packages.

## Capabilities

### New Capabilities

*(None — this is a cross-feature integration, not a new standalone capability.)*

### Modified Capabilities

- `care-tracking`: The "Mark done" operation on a care task SHALL also create a journal entry of type `task` for the plant, recording what was completed and when.
- `plant-journal`: The system SHALL support auto-created journal entries of type `task` that originate from care task completions, indistinguishable from manually-created task entries in the timeline.

## Impact

- **`lib/pages/care_schedule/care_schedule_usecases.dart`** — `completeTask()` gains a call to `PlantJournalUseCases.addEntry()` after recording the `TaskCompletion`. Constructor gains `PlantJournalUseCases` parameter.
- **`lib/core/injection.dart`** — Wire `PlantJournalUseCases` (already registered) into `CareScheduleUsecases` constructor call.
- **`lib/core/app_services.dart`** — No change needed (both use-cases are already exposed).
- **`lib/pages/care_schedule/care_schedule_repository.dart`** — No change.
- **`lib/pages/plant_journal/plant_journal_item_entity.dart`** — The existing `JournalEntryType.task` variant is already defined; no entity changes needed.
- **Localisation**: `assets/l10n/l10n_en.arb` (and `l10n_de.arb`) — add a template string for the auto-generated entry description, e.g. `careTaskCompleted: "{taskType} completed"`.
- **Tests**: `CareScheduleUsecases` unit tests updated to verify journal entry creation on `completeTask`. New test scenarios for the integration.
