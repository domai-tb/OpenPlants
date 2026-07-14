## ADDED Requirements

### Requirement: Close button on identification page
The plant identification page SHALL display a close (X) button that dismisses the modal and returns the user to the dashboard. The button SHALL be visible in all states: idle, identifying, result, and error.

#### Scenario: Close button visible in idle state
- **WHEN** the plant identification page opens (idle state with camera/gallery prompt)
- **THEN** a close (X) icon button SHALL be visible in the top-right area of the page
- **AND** tapping it SHALL dismiss the modal and return to the dashboard

#### Scenario: Close button visible in identifying state
- **WHEN** identification is in progress (blur overlay + lattice animation)
- **THEN** the close (X) icon button SHALL remain visible

#### Scenario: Close button visible in result state
- **WHEN** identification results are displayed
- **THEN** the close (X) icon button SHALL remain visible
- **AND** tapping it SHALL dismiss the modal without affecting the result data

#### Scenario: Close button visible in error state
- **WHEN** an error message is displayed
- **THEN** the close (X) icon button SHALL remain visible

### Requirement: Close button dismisses modal
The close button SHALL call `Navigator.of(context).pop()` to dismiss the modal bottom sheet. No confirmation dialog SHALL be shown.

#### Scenario: Close returns to dashboard
- **WHEN** the user taps the close button
- **THEN** the modal bottom sheet SHALL be dismissed
- **AND** the dashboard SHALL be visible underneath
