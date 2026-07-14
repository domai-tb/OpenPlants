## 1. Core Logic — Dependency & Completion Hook

- [x] 1.1 Add `PlantJournalUseCases` parameter to `CareScheduleUsecases` constructor and store as `final PlantJournalUseCases plantJournal;`
- [x] 1.2 Modify `completeTask()` to construct a `JournalEntry(type: JournalEntryType.task, ...)` from the completed `CareTask` and call `plantJournal.addEntry(entry)` after `repository.recordCompletion(completion)`
- [x] 1.3 Wrap the journal creation call in a try-catch that logs via `debugPrint` and does not rethrow (graceful degradation per design Decision 3)
- [x] 1.4 Build the journal entry's `notes` from `task.taskType.label` plus optional user-provided note (e.g., `"Watering completed"` or `"Watering completed — gave extra due to heat wave"`)

## 2. Dependency Injection

- [x] 2.1 In `lib/core/injection.dart`, pass `sl<PlantJournalUseCases>()` as the new `plantJournal` argument to `CareScheduleUsecases`

## 3. Localization

- [x] 3.1 Add ARB template strings to `assets/l10n/l10n_en.arb`:
      - `careTaskCompleted`: `"{taskType} completed"`
      - `careTaskCompletedWithNote`: `"{taskType} completed — {note}"`
- [x] 3.2 Add corresponding translations to `assets/l10n/l10n_de.arb`
- [x] 3.3 Run `fvm flutter gen-l10n` to regenerate `lib/l10n/`

## 4. Testing

- [x] 4.1 Update `CareScheduleUsecases` unit tests: verify `plantJournal.addEntry` is called with correct parameters when `completeTask` is invoked
- [x] 4.2 Verify snooze and skip do NOT call `plantJournal.addEntry`
- [x] 4.3 Verify journal creation failure does not prevent task completion from persisting
- [x] 4.4 Run `fvm flutter test` to confirm all tests pass

## 5. Verification

- [x] 5.1 Run `fvm flutter analyze` — no new lint violations
- [x] 5.2 Run `fvm flutter test` — all tests pass including existing and new
