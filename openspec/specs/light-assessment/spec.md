# Light Assessment

Camera-based and manual light level assessment for plants.

## Purpose

Allow users to assess and assign a light level to each plant, either manually or via camera estimation. The assigned light level feeds into the care schedule engine to modulate watering frequency.

## Requirements

### Requirement: User can set a light level for a plant
The system SHALL allow the user to select one of four light levels for any plant: low, medium, bright indirect, or direct. The selection SHALL be persisted as part of the plant's data.

#### Scenario: User selects a light level
- **WHEN** the user opens the light assessment UI for a plant and selects "bright indirect"
- **THEN** the plant's light level is stored as `brightIndirect`

#### Scenario: Light level defaults to unset
- **WHEN** a new plant is created and the user has not set a light level
- **THEN** the plant's light level is `null` (unset)

#### Scenario: User can change light level
- **WHEN** the user changes a plant's light level from "medium" to "direct"
- **THEN** the stored value updates to `direct` and the previous value is overwritten

### Requirement: Camera-based light estimation provides a guidance hint
The system SHALL display an inline camera preview within the light assessment page, allowing the user to capture a photo for brightness estimation without leaving the app. The result SHALL be displayed as a suggestion, not auto-applied.

#### Scenario: Camera estimation suggests a light level
- **WHEN** the user opens the light assessment page and the inline camera preview is active
- **THEN** the system captures a frame, estimates brightness, and displays an estimated light level (e.g., "Looks like bright indirect light") with an option to accept or dismiss

#### Scenario: User accepts camera suggestion
- **WHEN** the camera estimates "medium" and the user taps "Use this"
- **THEN** the plant's light level is set to `medium`

#### Scenario: User dismisses camera suggestion
- **WHEN** the camera estimates "direct" and the user taps "Dismiss"
- **THEN** the plant's light level remains unchanged

#### Scenario: Camera estimation is unavailable
- **WHEN** the device does not support camera access or the user denies permission
- **THEN** the camera estimation option is hidden and only manual selection is available

### Requirement: Light level is displayed in plant details
The system SHALL display the current light level (or "Not set" if unset) in the plant's detail view.

#### Scenario: Light level shown when set
- **WHEN** a plant has light level set to `brightIndirect`
- **THEN** the plant detail page displays "Bright Indirect" (or equivalent label)

#### Scenario: Light level shows unset when null
- **WHEN** a plant has no light level set
- **THEN** the plant detail page displays "Not set" for light level
