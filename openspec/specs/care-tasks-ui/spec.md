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

### Requirement: Plant detail page shows custom care rules section
The system SHALL display a "Care Rules" section on the plant detail page showing a summary of custom care rules for that plant (count of active rules and a tap target to manage them).

#### Scenario: Plant with no rules shows empty state
- **WHEN** user views plant detail for a plant with no custom care rules
- **THEN** the Care Rules section shows "No custom rules" with an "Add rule" button

#### Scenario: Plant with rules shows count
- **WHEN** user views plant detail for a plant with 3 active custom care rules
- **THEN** the Care Rules section shows "3 active rules" with a tap target to open the rule list

### Requirement: Rule list page displays all rules for a plant
The system SHALL provide a page or sheet that lists all custom care rules for a selected plant, showing task type, interval, and enabled status for each rule.

#### Scenario: Rule list shows all rules
- **WHEN** user opens the care rules list for a plant with 2 rules
- **THEN** the list displays both rules with task type, interval, and toggle switch

#### Scenario: Empty rule list shows call-to-action
- **WHEN** user opens the care rules list for a plant with no rules
- **THEN** the list shows an empty state with an "Add your first rule" prompt

### Requirement: User can add a new custom care rule from the UI
The system SHALL provide an "Add rule" action that opens a form where the user can select or type a task type, set an interval in days, and optionally configure reminder settings.

#### Scenario: Add rule with built-in task type
- **WHEN** user taps "Add rule" and selects "watering" from the dropdown with interval 10 days
- **THEN** a new rule is created for the plant with task type "watering" and interval 10 days

#### Scenario: Add rule with custom task type
- **WHEN** user taps "Add rule", types "Check for flowers" in the task type field, and sets interval 7 days
- **THEN** a new rule is created with task type "Check for flowers" and interval 7 days

#### Scenario: Add rule with reminder
- **WHEN** user enables reminder, sets time to 09:00, and selects monday/wednesday/friday
- **THEN** the new rule is created with reminder config as specified

### Requirement: User can edit an existing custom care rule
The system SHALL allow users to tap on a rule in the list to open an edit form pre-populated with the rule's current values.

#### Scenario: Edit rule interval
- **WHEN** user opens a rule for editing and changes interval from 7 to 14 days
- **THEN** the rule is updated to 14 days and the list reflects the change

#### Scenario: Edit rule reminder
- **WHEN** user opens a rule, enables reminder, and sets time to 08:00
- **THEN** the rule's reminder config is updated

### Requirement: User can disable or delete a rule from the list
Each rule in the list SHALL have a toggle switch to enable/disable and a delete action (swipe-to-delete or menu option).

#### Scenario: Toggle rule off
- **WHEN** user taps the toggle switch on an enabled rule
- **THEN** the rule is disabled (isEnabled=false) and visually dimmed in the list

#### Scenario: Delete rule
- **WHEN** user swipes to delete a rule and confirms
- **THEN** the rule is removed from the list and from storage

### Requirement: Custom task types appear in task-type filter
The system SHALL include user-defined task types (from custom care rules) in the task-type filter on the care schedule page, so users can filter by their custom task types.

#### Scenario: Custom task type in filter
- **WHEN** a user has a custom care rule with task type "Check for flowers"
- **THEN** "Check for flowers" appears as an option in the task-type filter dropdown
