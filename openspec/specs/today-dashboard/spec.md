# Today Dashboard

## Purpose

Provide a plants-only collection view titled "My Plants". Care tasks live on the Care Schedule page.

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

### Requirement: Dashboard is plants-only and titled My Plants
The system SHALL display only the plant collection (grid, search, filters) on the dashboard, titled "My Plants" via l10n. The system SHALL NOT display care task sections on the dashboard.

#### Scenario: No task sections on dashboard
- **WHEN** the user opens the dashboard with due or overdue tasks present
- **THEN** no Due Today or Overdue section appears

#### Scenario: Header and nav show My Plants
- **WHEN** the user views the dashboard tab or bottom navigation
- **THEN** the label reads the localized "My Plants" string
