# Today Dashboard

## Purpose

Provide an at-a-glance view of today's care tasks and quick actions for plant care management.

## Requirements

### Requirement: Dashboard shows quick-action strip
The system SHALL display a persistent row of action buttons at the top of the dashboard: "Add Plant", "Identify", and "Diagnose".

#### Scenario: Quick actions navigate to correct destinations
- **WHEN** user taps "Add Plant"
- **THEN** the system navigates to the plant collection add-flow
- **WHEN** user taps "Identify"
- **THEN** the system navigates to the classifier camera (plant identification)
- **WHEN** user taps "Diagnose"
- **THEN** the system navigates to the plant diagnosis page

### Requirement: Dashboard shows due tasks section
The system SHALL query the care schedule engine and display care tasks that are due today, grouped under a "Due Today" heading.

#### Scenario: Due today section appears when tasks exist
- **WHEN** the care schedule engine reports one or more tasks due today
- **THEN** the dashboard displays a "Due Today" section listing each task with plant name, task type, and due time

#### Scenario: Due today section hidden when no tasks
- **WHEN** the care schedule engine reports zero tasks due today
- **THEN** the dashboard hides the "Due Today" section entirely

### Requirement: Dashboard shows overdue tasks section
The system SHALL query the care schedule engine and display tasks past their due date, grouped under an "Overdue" heading.

#### Scenario: Overdue section appears when tasks overdue
- **WHEN** the care schedule engine reports one or more overdue tasks
- **THEN** the dashboard displays an "Overdue" section with red urgency styling, listing each task with plant name, task type, and days overdue

#### Scenario: Overdue section hidden when none overdue
- **WHEN** the care schedule engine reports zero overdue tasks
- **THEN** the dashboard hides the "Overdue" section
