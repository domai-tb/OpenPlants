## 1. Domain Model — `CareTaskStatus` and `CareTask`

- [x] 1.1 Add `CareTaskStatus.justCompleted` enum value in `care_task.dart`
- [x] 1.2 Add `DateTime? completedAt` field to `CareTask` constructor and update existing call sites

## 2. Grace Window Detection — `GraceWindowDetector`

- [x] 2.1 Add `GraceWindowDetector` class in `overdue_detector.dart` with static `isWithinGraceWindow(DateTime? completedAt, DateTime today) → bool` method
- [x] 2.2 Verify edge cases: null completedAt, yesterday completion, same-day completion, completion with next-due still today

## 3. Schedule Engine — Expose `completedAt` on computed tasks

- [x] 3.1 Update `schedule_engine.dart` to populate `CareTask.completedAt` from the most recent `TaskCompletion` for each task type per plant
- [x] 3.2 Verify that `completedAt` is null for never-completed tasks and populated for completed ones

## 4. Use Case Layer — Annotate tasks with grace-window status

- [x] 4.1 In `care_schedule_usecases.dart` `getSchedule()`: after computing tasks, iterate and apply `GraceWindowDetector.isWithinGraceWindow` to update any `upcoming` status to `justCompleted` when the grace window applies
- [x] 4.2 Ensure `completeTask()`, `snoozeTask()`, and `skipTask()` return annotated tasks with `justCompleted` status applied (not just raw upcoming)
- [x] 4.3 Add `recentlyCompletedCount` or `completedEarly` list to the schedule result for UI consumption

## 5. UI — Split upcoming section and render Completed Early section

- [x] 5.1 In `care_schedule_page.dart` `_buildContent()`: split upcoming tasks into `upcoming` (status == upcoming) and `completedEarly` (status == justCompleted) lists
- [x] 5.2 Render a new collapsible "Completed Early" section below the upcoming section for `justCompleted` tasks, following the same pattern as existing sections but with subdued styling
- [x] 5.3 Hide the Completed Early section when there are no `justCompleted` tasks

## 6. UI — CareTaskCard visual treatment for `justCompleted` state

- [x] 6.1 In `care_task_card.dart`: handle `CareTaskStatus.justCompleted` with reduced opacity (0.6) and a checkmark icon
- [x] 6.2 Update the due label for `justCompleted` tasks to show "Completed early — next due in N days" instead of the default upcoming label
- [x] 6.3 Handle the edge case where a `justCompleted` task's next due is still today (show "Completed — due again today")

## 7. UI — Completion SnackBar feedback

- [x] 7.1 After `_completeTask()` succeeds in `care_schedule_page.dart`, show a SnackBar with the confirmation message (e.g., "Watering marked done — next due in 7 days")
- [x] 7.2 Ensure snackbar text comes from `AppLocalizations` keys

## 8. Localization — ARB entries for new strings

- [x] 8.1 Add ARB keys to `assets/l10n/l10n_en.arb`:
  - `careScheduleCompletedEarly` — "Completed early"
  - `careScheduleCompletedEarlyNextDue` — "Completed early — next due in {days} days"
  - `careScheduleCompletedSection` — "Completed Early"
  - `careScheduleCompletedDueAgainToday` — "Completed — due again today"
  - `careScheduleCompletionSnackbar` — "{taskType} marked done — next due in {days} days"
- [x] 8.2 Run `fvm flutter gen-l10n` to regenerate localizations
- [x] 8.3 Update Dart call sites to use `context.l10n` keys

## 9. Validation

- [x] 9.1 Run `fvm flutter analyze` and fix any lint violations
- [x] 9.2 Run `fvm flutter test` to confirm no regressions
- [x] 9.3 Manually verify the grace-window behavior on a device/emulator
