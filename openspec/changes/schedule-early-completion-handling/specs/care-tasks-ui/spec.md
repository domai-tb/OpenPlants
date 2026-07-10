## MODIFIED Requirements

### Requirement: Care schedule page displays a dashboard

**Modified:** The care schedule page SHALL display the user's care tasks grouped into four sections: Overdue, Due Today, Upcoming, and Completed Early. The Completed Early section SHALL be collapsible and rendered below the Upcoming section with subdued styling. Each section is ordered by due date (closest first).

#### Scenario: Dashboard shows four sections
- **WHEN** user navigates to the care schedule page and there are overdue, due-today, upcoming, and completed-early tasks
- **THEN** the page displays all four sections with appropriate section headers

#### Scenario: Empty section is hidden
- **WHEN** there are no completed-early tasks
- **THEN** the Completed Early section is not displayed

#### Scenario: Completed Early section is collapsible
- **WHEN** user taps the Completed Early section header
- **THEN** the section expands or collapses, toggling visibility of its task cards

### MODIFIED Requirements

### Requirement: User can complete a task

**Modified:** Each task card SHALL have a "Mark done" button that records the completion, immediately recalculates the schedule, and displays a SnackBar confirming the action with the next due date.

#### Scenario: Complete task shows confirmation SnackBar
- **WHEN** user taps "Mark done" on a watering task that is due today
- **THEN** a SnackBar displays "Watering marked done — next due [date]" and the task moves to Completed Early or disappears from main sections

#### Scenario: Complete overdue task shows confirmation
- **WHEN** user taps "Mark done" on an overdue task
- **THEN** a SnackBar displays "Task completed — next due [date]" and the task moves to Completed Early

## ADDED Requirements

### Requirement: Completed-early tasks have distinct visual treatment

Task cards in the Completed Early section SHALL have a distinct visual appearance: reduced opacity (0.6), a checkmark icon, and a label "Completed early — next due in N days" instead of the standard upcoming label.

#### Scenario: Completed-early card shows subdued styling
- **WHEN** a task is in the Completed Early section
- **THEN** the card is rendered at 60% opacity with a checkmark icon and the label "Completed early — next due in 7 days"

#### Scenario: Completed-early card shows "Due today" if next occurrence is today
- **WHEN** a task completed early has its next due date falling on the same day (edge case with very short intervals)
- **THEN** the card shows "Completed — due again today" label (not suppressed as early)

### Requirement: SnackBar confirms completion with next-due info

After a task is completed, a SnackBar SHALL appear at the bottom of the screen for 4 seconds, confirming the action and stating when the next occurrence is due.

#### Scenario: SnackBar shows for completed task
- **WHEN** user completes a watering task
- **THEN** a SnackBar displays "Watering marked done — next due in 7 days"

#### Scenario: SnackBar uses correct l10n key
- **WHEN** a completion SnackBar renders
- **THEN** all text comes from `AppLocalizations` keys, not string literals
