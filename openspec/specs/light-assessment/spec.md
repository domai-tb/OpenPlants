# Light Assessment

Camera-based and manual light level assessment for plants.

## Purpose

Allow users to assess and assign a light level to each plant, either manually or via camera estimation. The assigned light level feeds into the care schedule engine to modulate watering frequency.

## Requirements

### Requirement: Camera-based light estimation provides a guidance hint
The system SHALL provide an interactive full-screen camera view for real-time light level estimation. The camera view SHALL display a live viewfinder with overlaid light level indicator that updates continuously. The user SHALL be able to capture a photo when they find a suitable light level, which SHALL be stored in the plant's photo timeline. The user SHALL also be able to set the light level directly from the live estimation without capturing a photo.

#### Scenario: Interactive camera view opens full-screen
- **WHEN** the user opens the light assessment page and taps "Assess with camera"
- **THEN** the system opens a full-screen camera view with live viewfinder and overlaid light level indicator

#### Scenario: Live light level indicator updates continuously
- **WHEN** the full-screen camera view is active and the user moves the device
- **THEN** the system displays the current estimated light level (e.g., "Low", "Medium", "Bright Indirect", "Direct") that updates in real-time as lighting conditions change

#### Scenario: User captures photo from interactive view
- **WHEN** the user taps the capture button in the full-screen camera view
- **THEN** the system captures the current frame, saves it to the plant's photo timeline, and displays the estimated light level with options to accept or dismiss

#### Scenario: User accepts live estimation without photo
- **WHEN** the user taps "Set this level" in the full-screen camera view
- **THEN** the system sets the plant's light level to the currently estimated level without capturing a photo

#### Scenario: User exits interactive camera view
- **WHEN** the user taps the back button or close button in the full-screen camera view
- **THEN** the system returns to the light assessment page without changing the light level (unless explicitly set)

### Requirement: Assessment from multiple photo sources
The system SHALL allow users to assess light level from three sources: live camera, gallery photos, or existing plant photos. Each source SHALL use the same brightness estimation algorithm.

#### Scenario: Assess from gallery photo
- **WHEN** the user taps "Choose from gallery" on the light assessment page
- **THEN** the system opens the device photo picker and estimates light level from the selected photo

#### Scenario: Assess from existing plant photo
- **WHEN** the user opens light assessment from a plant detail page that has photos
- **THEN** the system displays the most recent plant photo with an option to estimate light level from it

#### Scenario: Assess from camera capture
- **WHEN** the user taps "Take new photo" on the light assessment page
- **THEN** the system opens the inline camera preview and estimates light level from the captured photo

### Requirement: Standalone light assessment entry point
The system SHALL provide a standalone light assessment entry point from the "More" page that allows users to assess light levels without selecting a specific plant first.

#### Scenario: Access light assessment from More page
- **WHEN** the user taps "Light Assessment" on the More page
- **THEN** the system opens the light assessment page in standalone mode (no plant context)

#### Scenario: Standalone mode shows camera-only options
- **WHEN** the light assessment page is opened in standalone mode
- **THEN** the system displays only camera-based assessment options (no plant-specific photo options)

#### Scenario: Standalone mode allows saving to plant
- **WHEN** the user assesses light level in standalone mode and taps "Save to plant"
- **THEN** the system prompts the user to select a plant and saves the light level to that plant

### Requirement: Light level assessment from plant detail page
The system SHALL allow users to access light assessment directly from the plant detail page with the plant context pre-filled.

#### Scenario: Access from plant detail page
- **WHEN** the user taps "Assess Light Level" on the plant detail page
- **THEN** the system opens the light assessment page with the plant context pre-filled

#### Scenario: Plant detail shows assessment result
- **WHEN** the user completes a light assessment from the plant detail page
- **THEN** the system returns to the plant detail page and displays the updated light level
