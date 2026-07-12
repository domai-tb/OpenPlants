## ADDED Requirements

### Requirement: Schedule result includes completion timestamps

The schedule computation result SHALL include, for each task, the timestamp of the most recent `TaskCompletion` for that task type and plant (if any). This allows downstream consumers to apply grace-window detection without a separate query.

#### Scenario: Completed task includes timestamp
- **WHEN** the engine computes a schedule for a plant that has a watering completion from 2 hours ago
- **THEN** the returned `CareTask` for watering includes `completedAt` set to that timestamp

#### Scenario: Never-completed task has null timestamp
- **WHEN** the engine computes a schedule for a newly added plant with no completions
- **THEN** the returned tasks have `completedAt` set to null

### Requirement: Engine separates just-completed tasks in its output

The engine SHALL expose a method or output that groups tasks into three buckets for the caller: `overdue`, `dueNow` (due today or overdue within grace), `upcoming` (future due dates outside grace), and `completedEarly` (completed today with future next-due).

#### Scenario: Completed-early bucket contains only tasks in grace window
- **WHEN** the engine runs and one task has `completedAt` today with next-due tomorrow
- **THEN** the task appears in `completedEarly`, not in `upcoming`

#### Scenario: Empty completed-early bucket when no tasks completed today
- **WHEN** the engine runs and no tasks were completed today
- **THEN** the `completedEarly` list is empty
