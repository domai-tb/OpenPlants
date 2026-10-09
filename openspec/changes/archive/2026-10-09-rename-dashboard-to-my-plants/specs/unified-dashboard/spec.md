## REMOVED Requirements

### Requirement: Dashboard shows due and overdue care tasks
**Reason**: Dashboard becomes plants-only; tasks live only on Care Schedule page.
**Migration**: View Due Today / Overdue tasks on the Care Schedule tab.

## MODIFIED Requirements

### Requirement: Dashboard shows full plant grid with search
The system SHALL display all the user's plants in a scrollable grid as the primary dashboard content. A search bar SHALL filter the grid by plant name. The search bar and filter controls SHALL be fixed at the top and SHALL NOT scroll with the grid.

#### Scenario: Grid shows all plants
- **WHEN** the user has plants in their collection
- **THEN** the dashboard displays all plants in a grid layout with photo and name in the scrollable area

#### Scenario: Search filters the grid
- **WHEN** the user types a plant name in the search bar
- **THEN** the grid filters to show only matching plants

#### Scenario: Search with no matches
- **WHEN** no plants match the search term
- **THEN** the dashboard displays an empty search state message

### Requirement: Dashboard shows onboarding empty state
The system SHALL detect when the user has no plants and display a full-section onboarding prompt instead of the grid section.

#### Scenario: First-time empty state
- **WHEN** the user opens the app and the plant collection is empty
- **THEN** the dashboard displays an illustration, encouraging message, and "Add your first plant" button

#### Scenario: Onboarding navigates to add plant form
- **WHEN** user taps "Add your first plant" in the onboarding empty state
- **THEN** the system navigates to the add-plant form

### Requirement: Dashboard refreshes data on tab focus
The system SHALL fetch fresh plant collection data each time the home tab becomes visible.

#### Scenario: Data refreshes on return
- **WHEN** the user navigates away from the dashboard and back
- **THEN** the dashboard re-queries the plant collection and updates the display

## ADDED Requirements

### Requirement: Dashboard title is My Plants
The system SHALL label the dashboard page and bottom-nav entry "My Plants" via l10n in all locales.

#### Scenario: Header shows My Plants
- **WHEN** the user opens the dashboard tab
- **THEN** the page header displays the localized "My Plants" string

#### Scenario: Bottom nav shows My Plants
- **WHEN** the user views the bottom navigation bar
- **THEN** the dashboard tab label displays the localized "My Plants" string

### Requirement: Dashboard shows no care task sections
The system SHALL NOT display Due Today or Overdue sections on the dashboard, even when tasks exist.

#### Scenario: Tasks exist but dashboard hides them
- **WHEN** the care schedule engine reports due or overdue tasks
- **THEN** the dashboard shows only the plant grid with no task sections
