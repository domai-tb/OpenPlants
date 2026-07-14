## MODIFIED Requirements

### Requirement: Dashboard shows quick-action strip
The system SHALL display a persistent row of action buttons at the top of the dashboard: "Add Plant", "Identify", and "Diagnose".

#### Scenario: Quick actions navigate to correct destinations
- **WHEN** user taps "Add Plant"
- **THEN** the system navigates to the add-plant form (dashboard's navigator)
- **WHEN** user taps "Identify"
- **THEN** the system opens the identification modal (full-screen dialog, no tab switch)
- **WHEN** user taps "Diagnose"
- **THEN** the system navigates to the diagnosis page

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

## REMOVED Requirements

### Requirement: Dashboard shows recent plants section
**Reason**: The recent plants carousel is replaced by the full plant grid below the task sections. A carousel of 3 plants is no longer useful when all plants are visible in the grid.

**Migration**: The `DashboardData.recentPlants` field and associated `_RecentPlantsCarousel` widget are removed. The plant grid below the task sections replaces this functionality.

### Requirement: Dashboard shows onboarding empty state
**Reason**: This requirement moves to the unified-dashboard spec, which owns the complete dashboard experience. The behavior is preserved but the requirement now lives under the consolidated capability.

**Migration**: Reference `unified-dashboard` spec for the updated onboarding requirement.

### Requirement: Dashboard refreshes data on tab focus
**Reason**: This requirement moves to the unified-dashboard spec. The behavior is preserved.

**Migration**: Reference `unified-dashboard` spec for the updated refresh requirement.
