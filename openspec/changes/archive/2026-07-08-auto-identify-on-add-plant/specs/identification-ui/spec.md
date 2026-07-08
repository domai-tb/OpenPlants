## ADDED Requirements

### Requirement: Identification picker mode
The system SHALL provide an "identification picker" mode of the identification results display, distinct from the standalone identification page. In picker mode, each species result card SHALL be tappable, and tapping it SHALL select that species and notify the calling form. A manual entry option SHALL be available to type a custom species name.

#### Scenario: Results are tappable in picker mode
- **WHEN** identification results are displayed in picker mode on the add-plant form
- **THEN** each species card SHALL be tappable with a visual indication (e.g., radio button, highlight)

#### Scenario: Tap result selects species
- **WHEN** the user taps a species result card in picker mode
- **THEN** the system SHALL register that species as selected and provide a callback to the calling form with the selected species name

#### Scenario: Manual entry option visible
- **WHEN** identification results are displayed in picker mode
- **THEN** a "Enter manually" text field or button SHALL be visible below the results list

#### Scenario: Manual entry overrides results
- **WHEN** the user types in the manual entry field in picker mode
- **THEN** the typed text SHALL be used as the species name, regardless of which result is highlighted

#### Scenario: No results — manual entry only
- **WHEN** identification returns zero valid results in picker mode
- **THEN** only the manual entry option SHALL be shown, with a "Could not identify" message

### Requirement: Pickable state management
The system SHALL expose a callback-based interface for the identification picker, so the calling component receives the selected species name when the user makes a choice.

#### Scenario: Callback on species selection
- **WHEN** the user taps a result in picker mode
- **THEN** the picker SHALL invoke a callback with the selected species scientific name

#### Scenario: Callback on manual entry
- **WHEN** the user confirms a manual species entry
- **THEN** the picker SHALL invoke a callback with the manually entered text
