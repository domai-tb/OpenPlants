## MODIFIED Requirements

### Requirement: Identification page layout
The system SHALL display the plant identification flow as a full-screen modal dialog with an inline camera preview as the default initial state. The identification modal SHALL show a live camera viewfinder with a capture button and a gallery fallback option.

#### Scenario: Identification triggered from dashboard
- **WHEN** the user taps "Identify" on the dashboard quick-action strip
- **THEN** the system opens a full-screen modal showing a live inline camera preview with a capture button

#### Scenario: Initial state in modal
- **WHEN** the identification modal opens
- **THEN** the user sees a live camera viewfinder from the back camera with a capture button and a gallery option — no separate "capture prompt" screen

### Requirement: Captured image display
The system SHALL display the captured/selected image prominently in the identification modal while inference is in progress and after results are shown.

#### Scenario: Image shown during inference
- **WHEN** the user captures or selects an image
- **THEN** the image is displayed at a visible size within the modal

#### Scenario: Image shown with results
- **WHEN** classification completes
- **THEN** the captured image remains visible alongside the classification results
