## Context

The care schedule engine computes a deterministic list of tasks per plant, sorted by urgency (overdue → due today → upcoming). When a user completes a task early (before its due date), the engine resets the next-due anchor to the completion time and recomputes the schedule. Since the new due date is `completionTime + effectiveInterval`, it frequently falls within the "upcoming" window — causing the same task to reappear immediately.

The current `CareTaskStatus` enum has three values: `overdue`, `dueToday`, `upcoming`. There is no way to distinguish a genuinely upcoming task from one that was just completed early. The UI renders all three sections unconditionally, with no grace period or suppression for recently-completed tasks.

The `OverdueDetector.detect()` function computes status purely from `(lastCompletedAt, today, interval)` — it has no concept of "when was the last completion event recorded" vs "when was the task originally due." Completing early simply shifts the anchor forward.

## Goals / Non-Goals

**Goals:**
- Distinguish tasks completed early from genuinely upcoming tasks in the UI
- Provide a visual indicator ("completed early — next due in N days") so users see their action registered
- Suppress early-completed tasks from the main upcoming section to avoid the "I just did this" confusion
- Keep the change in the computation and UI layers only — no persistence changes
- Localize all new user-facing strings

**Non-Goals:**
- No changes to `TaskCompletion` entity, persistence (SharedPreferences), or data model
- No user-configurable grace window (hardcoded constant is fine for this iteration)
- No changes to the core scheduling algorithm or interval computation
- No changes to overdue/due-today behavior (those are unaffected)
- No undo/redo for completions

## Decisions

### Decision 1: Grace window = remainder of the same calendar day

**Chosen:** A task completed early is suppressed from the main upcoming section for the remainder of the calendar day (until 23:59:59.999 of the day it was completed).

**Rationale:**
- Simple to implement: compare `completedAt.day` with `today.day`
- Intuitive: "I already did this today" is the natural mental model
- Resets at midnight → fresh start each day is predictable
- No clock-skew sensitivity (day comparison, not duration)

**Alternatives considered:**
- *Fixed duration (e.g., 1 hour)*: Doesn't align with user's natural cadence (they think in days, not hours)
- *Until original due date passes*: Too complex; requires tracking the original due date which we don't persist
- *No suppression, just visual indicator*: Doesn't fully address the "why is it back" confusion

### Decision 2: Separate "Completed Early" section instead of removal

**Chosen:** Tasks completed within the grace window are moved to a subdued, collapsible "Completed Early" section rendered below the regular upcoming section, with a visual label like "Completed early — next due in N days".

**Rationale:**
- Tasks are not hidden — the user can still see them if they expand the section
- Declutters the primary upcoming section (the user doesn't see the same task twice in the critical path)
- Provides positive feedback that their action was recorded
- Aligns with the existing section pattern (overdue, due-today, upcoming, completed-early)

**Alternatives considered:**
- *Full removal*: User can't verify their completion took effect; may cause confusion
- *Filter toggle*: Extra UI surface area for a niche case; adds complexity
- *Inline demotion with opacity*: Can look broken at scale

### Decision 3: Detection lives in OverdueDetector (not a new class)

**Chosen:** Add a `GraceWindowDetector` static method alongside the existing `OverdueDetector` in `overdue_detector.dart`, keeping the detection logic co-located.

**Rationale:**
- Single file to find when reasoning about status detection
- `OverdueDetector` already encapsulates the `lastCompletedAt` → status logic
- A new class keeps separation of concerns (overdue logic vs grace logic)

### Decision 4: `CareTask.completedAt` is optional, set from last completion timestamp

**Chosen:** `CareTask` gains a `DateTime? completedAt` field populated from the most recent `TaskCompletion.completedAt` for that task type and plant. The value `null` means "never completed".

**Rationale:**
- The schedule engine already has access to completion history to compute next-due
- Surfacing `completedAt` on `CareTask` lets the UI and GraceWindowDetector read it without another datasource query
- Optional/nullable — backward compatible with existing entities

## Risks / Trade-offs

| Risk | Mitigation |
|------|------------|
| User completes a task late at night, then sees it reappear the next morning — "but I just did this!" | The grace window ends at midnight, so early-morning recurrence is the correct behavior (the interval has advanced). The "next due in N days" label helps here. |
| User completes a task 1 hour before midnight, suppression kicks in, then it reappears 1 hour later | Same as above — the schedule is correct; the label explains the gap. |
| Grace window detection could be confused by snooze/skip completions | Snooze and skip also record `TaskCompletion` with today's timestamp. They will also get the `justCompleted` status, which is acceptable: if the user snoozed a task, they don't need to see it again today. |
| Performance: every task card now checks grace window | Negligible — one `day` comparison per task, no I/O. |

## Implementation Outline

### Layer 1: Status detection (`overdue_detector.dart`)
- Add `GraceWindowDetector` class with a single static method `isWithinGraceWindow(DateTime? completedAt, DateTime today)` → `bool`
- Grace window constant: `_graceDuration = Duration(days: 1)` but compared by calendar day (`completedAt.day == today.day`)

### Layer 2: Domain model (`care_task.dart`)
- Add `CareTaskStatus.justCompleted`
- Add `DateTime? completedAt` to `CareTask` constructor

### Layer 3: Use case layer (`care_schedule_usecases.dart`)
- In `getSchedule()`, after computing tasks, apply grace-window detection to annotate the status
- After `completeTask()`, `snoozeTask()`, `skipTask()` — return the annotated task list with `justCompleted` status applied
- Expose a `recentlyCompletedCount` in the schedule result for UI use

### Layer 4: UI (`care_schedule_page.dart`, `care_task_card.dart`)
- Split upcoming tasks into two groups: `upcoming` (genuine) and `justCompleted` (grace window)
- Render `justCompleted` tasks in a collapsible "Completed Early" section below upcoming, with subdued styling
- `CareTaskCard` handles `justCompleted` state: muted colors, "Completed early — next due in N days" label
- Show a SnackBar after completion: "Watering marked done — next due [date]"

### Layer 5: Localization (`lib/l10n/`)
- Add ARB entries for: `careScheduleCompletedEarly`, `careScheduleNextDue`, `careScheduleCompletedSection`, `careScheduleCompletedEarlyLabel`
