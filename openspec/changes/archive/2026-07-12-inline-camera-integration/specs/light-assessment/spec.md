## MODIFIED Requirements

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
