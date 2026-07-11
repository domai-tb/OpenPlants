# Unified Dashboard

## Purpose

Serves as the primary navigation hub, replacing the standalone today dashboard and plant collection pages. Provides a single scrollable view with quick actions, care tasks, a full plant grid with search and filters, and an onboarding empty state.

## Requirements

### Requirement: Unified dashboard replaces today dashboard and plant collection pages
The system SHALL consolidate the today dashboard and plant collection into a single unified dashboard page accessible from the bottom nav bar. The standalone plant collection page SHALL be removed from the nav bar.

### Requirement: Dashboard shows quick-action strip
The system SHALL display a persistent row of action buttons at the top of the dashboard: "Add Plant", "Identify", and "Diagnose".

#### Scenario: Quick actions available
- **WHEN** the user has one or more plants
- **THEN** the quick-action strip is visible at the top of the dashboard content

#### Scenario: Quick actions in empty state
- **WHEN** the user has no plants
- **THEN** the quick-action strip is still visible so the user can add their first plant or use identify/diagnose

### Requirement: Dashboard shows due and overdue care tasks
The system SHALL query the care schedule engine and display care tasks that are due today or overdue, grouped under headings.

#### Scenario: Due today section
- **WHEN** the care schedule engine reports tasks due today
- **THEN** the dashboard displays a "Due Today" section listing each task with plant name, task type, and due time

#### Scenario: Overdue section
- **WHEN** the care schedule engine reports overdue tasks
- **THEN** the dashboard displays an "Overdue" section with red urgency styling, listing each task with plant name, task type, and days overdue

#### Scenario: No tasks hides sections
- **WHEN** there are no due or overdue tasks
- **THEN** the dashboard hides both task sections

### Requirement: Dashboard shows full plant grid with search
The system SHALL display all the user's plants in a scrollable grid below the task sections. A search bar SHALL filter the grid by plant name.

#### Scenario: Grid shows all plants
- **WHEN** the user has plants in their collection
- **THEN** the dashboard displays all plants in a grid layout with photo and name

#### Scenario: Search filters the grid
- **WHEN** the user types a plant name in the search bar
- **THEN** the grid filters to show only matching plants

#### Scenario: Search with no matches
- **WHEN** no plants match the search term
- **THEN** the dashboard displays an empty search state message

### Requirement: Dashboard provides filter chips for care status and room
The system SHALL display filter chips above the plant grid to filter by care status (happy, needs attention, critical) and by room.

#### Scenario: Filter by care status
- **WHEN** the user taps a care status filter chip
- **THEN** the grid shows only plants with that care status

#### Scenario: Filter by room
- **WHEN** the user taps a room filter chip
- **THEN** the grid shows only plants in that room

#### Scenario: Clear filters
- **WHEN** the user taps the active filter chip again
- **THEN** the filter is cleared and all plants are shown

### Requirement: Dashboard shows onboarding empty state
The system SHALL detect when the user has no plants and display a full-section onboarding prompt instead of the task and grid sections.

#### Scenario: First-time empty state
- **WHEN** the user opens the app and the plant collection is empty
- **THEN** the dashboard displays an illustration, encouraging message, and "Add your first plant" button

#### Scenario: Onboarding navigates to add plant form
- **WHEN** user taps "Add your first plant" in the onboarding empty state
- **THEN** the system navigates to the add-plant form

### Requirement: Tapping a plant navigates to its detail page
Each plant card in the grid SHALL be tappable and navigate to the plant detail page.

#### Scenario: Plant card navigates to detail
- **WHEN** the user taps a plant card in the grid
- **THEN** the system navigates to the plant detail page for that plant

### Requirement: Dashboard refreshes data on tab focus
The system SHALL fetch fresh dashboard data (tasks, plants) each time the home tab becomes visible.

#### Scenario: Data refreshes on return
- **WHEN** the user navigates away from the dashboard and back
- **THEN** the dashboard re-queries care schedule and plant collection and updates the display
