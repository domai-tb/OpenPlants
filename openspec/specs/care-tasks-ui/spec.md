# Care Tasks UI

User interface for viewing, filtering, and acting on scheduled care tasks.

## Purpose

Present the care schedule to users in a dashboard format with actionable task cards, enabling them to complete, snooze, or skip tasks and filter by plant or task type.

## Requirements

### Requirement: Care schedule page displays a dashboard
The system SHALL display a new page (care_schedule) that shows the user's care tasks grouped into three sections: Overdue, Due Today, and Upcoming. Each section is ordered by due date (closest first).

#### Scenario: Dashboard shows all three sections
- **WHEN** user navigates to the care schedule page and there are overdue, due-today, and upcoming tasks
- **THEN** the page displays all three sections with appropriate section headers

#### Scenario: Empty section is hidden
- **WHEN** there are no overdue tasks
- **THEN** the Overdue section is not displayed

#### Scenario: Empty state when no tasks exist
- **WHEN** user has no plants in their collection
- **THEN** the page displays a message and a "Go to Plant Collection" button
- **AND** tapping the button switches to the Plant Collection tab without crashing

#### Scenario: Empty state uses l10n
- **WHEN** the Care Schedule empty state renders
- **THEN** all user-facing text comes from `AppLocalizations` keys, not string literals

### Requirement: Each task card shows task type, plant name, and due status
Each task SHALL be displayed as a card showing the task type icon and label, the associated plant name, and the due status (overdue badge, "Due today", or "Due in N days").

#### Scenario: Overdue task shows red badge
- **WHEN** a task is overdue
- **THEN** the card displays a red "Overdue by N days" badge

#### Scenario: Due today task shows highlight
- **WHEN** a task is due today
- **THEN** the card displays a "Due today" indicator

#### Scenario: Upcoming task shows countdown
- **WHEN** a task is due in the future
- **THEN** the card displays "Due in N days"

### Requirement: User can filter tasks by plant
The system SHALL provide a plant filter dropdown that limits the displayed tasks to a single plant.

#### Scenario: Filter by plant shows only that plant's tasks
- **WHEN** user selects a specific plant from the filter
- **THEN** only tasks for that plant are displayed

#### Scenario: "All plants" shows everything
- **WHEN** user selects "All plants" in the filter
- **THEN** tasks for all plants are displayed

### Requirement: User can filter by task type
The system SHALL provide a task-type filter (dropdown or chip row) to narrow by a specific care task type.

#### Scenario: Filter by watering shows only watering tasks
- **WHEN** user selects "Watering" in the task-type filter
- **THEN** only watering tasks are displayed

### Requirement: User can complete a task
Each task card SHALL have a "Mark done" button that records the completion and immediately recalculates the schedule.

#### Scenario: Complete task updates schedule
- **WHEN** user taps "Mark done" on a watering task
- **THEN** the task is recorded as completed, the schedule recalculates, and the UI updates to reflect the new next-due date

### Requirement: User can snooze a task
Each task card SHALL support a "Snooze" action that defers the task by a user-chosen duration (1 day, 3 days, 7 days, or custom).

#### Scenario: Snooze moves task to upcoming
- **WHEN** user snoozes a due-today task by 3 days
- **THEN** the task is rescheduled to be due in 3 days and appears in the Upcoming section

### Requirement: User can skip a task occurrence
Each task card SHALL support a "Skip" action that acknowledges the task without recording a completion and recalculates the next-due from today.

#### Scenario: Skip recalculates from today
- **WHEN** user skips a watering task
- **THEN** the next watering due date is calculated as today + effective interval (without recording a "completed" event)
