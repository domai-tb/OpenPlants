## Why

When a user completes a care task (e.g., waters a plant) before its scheduled due date, the schedule engine correctly resets the next-due anchor to the completion time. However, the newly computed next-due date often falls within the same "upcoming" window, causing the task to reappear in the UI immediately. Users experience this as "I just did this — why is it already back?" — the schedule feels too aggressive and undermines trust.

This change addresses the core UX friction: early completions should not immediately re-queue the same task in the upcoming section without some visual or logical distinction that the user just addressed it.

## What Changes

- **Task status model**: Add a `justCompleted` state that tracks tasks completed within a configurable "grace window" so they can be visually distinguished or suppressed from the upcoming view.
- **Upcoming section filtering**: The upcoming section will suppress or visually demote tasks that were completed within the grace window (e.g., "completed early — next due in N days").
- **Grace window configuration**: The grace window duration (default: same day) is a constant in the schedule engine, not a user-facing setting in this change.
- **Completion feedback in UI**: After completing a task, the UI will show inline feedback (snackbar or toaster) confirming the action and hinting at when the next occurrence is due.
- **No changes to persistence or data model**: The `TaskCompletion` and `CareTask` entities remain unchanged; the new behavior is a computation and UI-layer concern only.

## Capabilities

### New Capabilities
- `early-completion-grace`: Logic that determines whether a recently-completed task should be shown, suppressed, or visually demoted in the upcoming section, based on a grace window relative to the completion time.

### Modified Capabilities
- `care-tasks-ui`: The upcoming task section will suppress or visually flag tasks completed within the grace window. Task cards for "just completed" tasks will show a subdued appearance and an updated label ("Completed early — next due in N days") instead of the default "Due in N days" label.
- `care-schedule-engine`: The engine will expose a new method or parameter that lets callers distinguish between a task that is genuinely upcoming and one that was recently completed (early). No changes to the core scheduling computation.

## Impact

- **`lib/pages/care_schedule/care_task.dart`**: `CareTaskStatus` enum gains a `justCompleted` member. `CareTask` gains an optional `completedAt` field.
- **`lib/pages/care_schedule/overdue_detector.dart`**: Gets a new `GraceWindowDetector` to determine if a task was completed within the grace window.
- **`lib/pages/care_schedule/care_schedule_usecases.dart`**: `getSchedule` will annotate tasks with the new status. Post-completion schedule refresh will apply grace-window logic.
- **`lib/pages/care_schedule/care_schedule_page.dart`**: Upcoming section rendering will handle `justCompleted` tasks (suppress or demote). Snackbar feedback on completion.
- **`lib/pages/care_schedule/widgets/care_task_card.dart`**: Visual treatment for `justCompleted` state.
- **`lib/l10n/`**: New localizations for "Completed early — next due in N days" and related labels.
