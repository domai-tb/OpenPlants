## ADDED Requirements

### Requirement: Engine exposes grace-window detection for early completions

The care schedule engine SHALL expose a pure function that determines whether a task was completed within the current calendar day's grace window. A task is considered "just completed" when its most recent completion timestamp falls on the same calendar day as the reference "today" date, AND the task's next-due date (completion + effective interval) is in the future (i.e., the task was completed early).

#### Scenario: Task completed today with future next-due is "just completed"
- **WHEN** a task was completed earlier today (e.g., 3 hours ago) and the next due date is tomorrow or later
- **THEN** the engine flags the task as `justCompleted`

#### Scenario: Task completed yesterday is not "just completed"
- **WHEN** a task was completed yesterday and the next due date is in the future
- **THEN** the engine does NOT flag the task as `justCompleted`

#### Scenario: Task never completed is not "just completed"
- **WHEN** a task has no completion history (`lastCompletedAt` is null)
- **THEN** the engine does NOT flag the task as `justCompleted`

#### Scenario: Overdue task completed today is "just completed"
- **WHEN** an overdue task is completed today and the next due date is in the future
- **THEN** the engine flags the task as `justCompleted`

#### Scenario: Task completed today that is still due today is NOT "just completed"
- **WHEN** a task was completed earlier today but the interval is so short the next due date is still today
- **THEN** the engine does NOT flag the task as `justCompleted` (the user did it but needs to do it again — extremely short intervals)
