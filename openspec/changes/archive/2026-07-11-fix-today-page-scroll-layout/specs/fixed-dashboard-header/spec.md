## ADDED Requirements

### Requirement: Dashboard header and controls remain fixed while plant grid scrolls
The system SHALL render the Today page header, quick-action strip, and plant-collection filter controls (search bar and filter chips) in a fixed non-scrolling area at the top of the viewport. Only the plant grid below these controls SHALL scroll vertically.

#### Scenario: Fixed controls visible during scroll
- **WHEN** the user scrolls through the plant collection grid
- **THEN** the header greeting, quick-action buttons (Identify, Add, Diagnose), search bar, and filter chips remain visible and fixed at the top of the screen

#### Scenario: Pull-to-refresh on scrollable area
- **WHEN** the user performs a pull-to-refresh gesture on the plant grid area
- **THEN** the system refreshes the dashboard data (tasks, plants) and the grid updates

#### Scenario: Scrollable area uses available vertical space
- **WHEN** the page is rendered with the fixed header and controls
- **THEN** the plant grid occupies all remaining vertical space and scrolls independently within that area
