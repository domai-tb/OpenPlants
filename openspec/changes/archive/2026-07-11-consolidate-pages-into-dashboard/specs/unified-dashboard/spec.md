## ADDED Requirements

### Requirement: Unified dashboard replaces today dashboard and plant collection pages
The system SHALL display a single "My Plants" dashboard as the home page that combines the quick-action strip, care task sections, and the full plant grid with search and filters. The dashboard SHALL replace both the previous TodayDashboardPage and PlantCollectionPage as the primary landing page.

### Requirement: Dashboard shows quick-action strip
The system SHALL display a persistent row of three action buttons at the top of the dashboard: "Add Plant", "Identify", and "Diagnose". Tapping "Identify" SHALL open the identification modal. Tapping "Add Plant" SHALL navigate to the add-plant form. Tapping "Diagnose" SHALL navigate to the diagnosis page.

#### Scenario: Quick actions available
- **WHEN** the dashboard has plants
- **THEN** the quick-action strip is visible with Add Plant, Identify, and Diagnose buttons

#### Scenario: Quick actions in empty state
- **WHEN** the dashboard has no plants
- **THEN** a prominent "Add your first plant" button is shown instead of the quick-action strip

### Requirement: Dashboard shows due and overdue care tasks
The system SHALL query the care schedule engine and display care tasks due today and overdue, matching the existing behavior of the today dashboard due/overdue sections.

#### Scenario: Due today section
- **WHEN** the care schedule engine reports tasks due today
- **THEN** the dashboard displays a "Due Today" section listing each task

#### Scenario: Overdue section
- **WHEN** the care schedule engine reports overdue tasks
- **THEN** the dashboard displays an "Overdue" section with red urgency styling

#### Scenario: No tasks hides sections
- **WHEN** zero tasks are due or overdue
- **THEN** the corresponding sections are hidden

### Requirement: Dashboard shows full plant grid with search
The system SHALL display all plants from the user's collection in a scrollable grid below the task sections. A search bar SHALL filter the grid by plant name substring match.

#### Scenario: Grid shows all plants
- **WHEN** the user has plants in their collection
- **THEN** the dashboard displays all plants in a grid layout with name, photo (if available), care status indicator, and room badge

#### Scenario: Search filters the grid
- **WHEN** the user types in the search bar
- **THEN** the grid filters to show only plants whose name contains the search text

#### Scenario: Search with no matches
- **WHEN** the search text matches no plants
- **THEN** the dashboard shows "No plants match your search" with a clear-search option

### Requirement: Dashboard provides filter chips for care status and room
The system SHALL display filter chips above the plant grid to filter by care status (All, Needs Water, Needs Fertilizer, Needs Attention) and by room assignment.

#### Scenario: Filter by care status
- **WHEN** the user taps a care status filter chip
- **THEN** the grid shows only plants with that care status

#### Scenario: Filter by room
- **WHEN** the user taps a room filter chip
- **THEN** the grid shows only plants assigned to that room

#### Scenario: Clear filters
- **WHEN** the user taps the active filter chip again or taps "All"
- **THEN** the grid shows all plants

### Requirement: Dashboard shows onboarding empty state
The system SHALL detect when the user has no plants and display a full-section onboarding prompt instead of the task sections and plant grid.

#### Scenario: First-time empty state
- **WHEN** the user opens the app and the plant collection is empty
- **THEN** the dashboard displays a friendly illustration, encouragement message, and prominent "Add your first plant" button

#### Scenario: Onboarding navigates to add plant form
- **WHEN** user taps "Add your first plant" in the onboarding empty state
- **THEN** the system navigates to the add-plant form

### Requirement: Tapping a plant navigates to its detail page
The system SHALL push the plant detail page onto the dashboard's navigator stack when a plant card is tapped.

#### Scenario: Plant card navigates to detail
- **WHEN** the user taps a plant card on the dashboard
- **THEN** the system pushes PlantCollectionDetailPage onto the dashboard's Navigator

### Requirement: Dashboard refreshes data on tab focus
The system SHALL re-query the care schedule engine and plant collection each time the dashboard tab becomes visible.

#### Scenario: Data refreshes on return
- **WHEN** the user navigates away from the dashboard and back
- **THEN** the dashboard re-loads care tasks and plant data and updates the display
