## ADDED Requirements

### Requirement: Dashboard shows quick-action strip
The system SHALL display a persistent row of action buttons at the top of the dashboard: "Add Plant", "Identify", and "Diagnose".

#### Scenario: Quick actions navigate to correct pages
- **WHEN** user taps "Add Plant"
- **THEN** the system navigates to the plant collection add-flow (page7)
- **WHEN** user taps "Identify"
- **THEN** the system navigates to the classifier camera (page3)
- **WHEN** user taps "Diagnose"
- **THEN** the system navigates to the care schedule page (page8)

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

### Requirement: Dashboard shows recent plants section
The system SHALL display the 10 most recently updated plants from the plant collection in a horizontal carousel.

#### Scenario: Recent plants carousel appears
- **WHEN** the plant collection has one or more plants
- **THEN** the dashboard displays a horizontal scrollable row of plant cards showing the plant's photo (if available) and name

#### Scenario: Recent plants hidden when collection empty
- **WHEN** the plant collection has zero plants
- **THEN** the dashboard hides the recent plants section

### Requirement: Dashboard shows onboarding empty state
The system SHALL detect when the user has no plants and display a full-section onboarding prompt instead of empty sections.

#### Scenario: First-time empty state
- **WHEN** the user opens the app and the plant collection is empty
- **THEN** the dashboard displays a friendly illustration, a message encouraging the user to add their first plant, and a prominent "Add your first plant" button

#### Scenario: Onboarding CTA navigates to add plant
- **WHEN** user taps "Add your first plant" in the onboarding empty state
- **THEN** the system navigates to the plant collection add-flow (page7)

### Requirement: Dashboard refreshes data on tab focus
The system SHALL fetch fresh dashboard data (tasks, plants) each time the home tab becomes visible.

#### Scenario: Data refreshes on return to dashboard
- **WHEN** the user navigates away from the dashboard and back
- **THEN** the dashboard re-queries both the care schedule engine and plant collection and updates the display
