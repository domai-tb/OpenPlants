## MODIFIED Requirements

### Requirement: Dashboard shows quick-action strip
The system SHALL display a persistent row of action buttons at the top of the dashboard: "Add Plant", "Identify", and "Diagnose". These buttons SHALL remain fixed at the top of the viewport and SHALL NOT scroll off-screen when the user scrolls through the plant collection.

#### Scenario: Quick actions available
- **WHEN** the user has one or more plants
- **THEN** the quick-action strip is visible at the top of the dashboard content and remains fixed during scroll

#### Scenario: Quick actions in empty state
- **WHEN** the user has no plants
- **THEN** the quick-action strip is still visible so the user can add their first plant or use identify/diagnose

### Requirement: Dashboard shows full plant grid with search
The system SHALL display all the user's plants in a scrollable grid below the task sections. A search bar SHALL filter the grid by plant name. The search bar and filter controls SHALL be fixed at the top and SHALL NOT scroll with the grid.

#### Scenario: Grid shows all plants
- **WHEN** the user has plants in their collection
- **THEN** the dashboard displays all plants in a grid layout with photo and name in the scrollable area

#### Scenario: Search filters the grid
- **WHEN** the user types a plant name in the search bar
- **THEN** the grid filters to show only matching plants

#### Scenario: Search with no matches
- **WHEN** no plants match the search term
- **THEN** the dashboard displays an empty search state message

### Requirement: Dashboard provides filter chips for care status and room
The system SHALL display filter chips above the plant grid to filter by care status (happy, needs attention, critical) and by room. The filter chips SHALL be fixed at the top and SHALL NOT scroll with the grid.

#### Scenario: Filter by care status
- **WHEN** the user taps a care status filter chip
- **THEN** the grid shows only plants with that care status

#### Scenario: Filter by room
- **WHEN** the user taps a room filter chip
- **THEN** the grid shows only plants in that room

#### Scenario: Clear filters
- **WHEN** the user taps the active filter chip again
- **THEN** the filter is cleared and all plants are shown
