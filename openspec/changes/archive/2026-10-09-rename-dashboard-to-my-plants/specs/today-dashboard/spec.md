## REMOVED Requirements

### Requirement: Dashboard shows due tasks section
**Reason**: Dashboard becomes plants-only; Due Today lives on Care Schedule page.
**Migration**: View due-today tasks on the Care Schedule tab.

### Requirement: Dashboard shows overdue tasks section
**Reason**: Dashboard becomes plants-only; Overdue lives on Care Schedule page.
**Migration**: View overdue tasks on the Care Schedule tab.

## ADDED Requirements

### Requirement: Dashboard is plants-only and titled My Plants
The system SHALL display only the plant collection (grid, search, filters) on the dashboard, titled "My Plants" via l10n. The system SHALL NOT display care task sections on the dashboard.

#### Scenario: No task sections on dashboard
- **WHEN** the user opens the dashboard with due or overdue tasks present
- **THEN** no Due Today or Overdue section appears

#### Scenario: Header and nav show My Plants
- **WHEN** the user views the dashboard tab or bottom navigation
- **THEN** the label reads the localized "My Plants" string
