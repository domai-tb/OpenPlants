## MODIFIED Requirements

### Requirement: Camera capture
The system SHALL display an inline camera preview within the plant identification page, allowing the user to take a photo without leaving the app.

#### Scenario: User opens identification page
- **WHEN** the user taps the camera capture button on the identification page
- **THEN** an inline camera preview opens within the page showing a live viewfinder from the back camera

#### Scenario: User captures photo from inline preview
- **WHEN** the user taps the capture button on the inline camera preview
- **THEN** a single frame is captured and the image bytes are returned to the identification pipeline

#### Scenario: Camera permission denied
- **WHEN** the user denies camera permission
- **THEN** the system shows an in-page rationale explaining why camera access is needed and offers gallery-only fallback

### Requirement: Gallery selection
The system SHALL allow the user to pick an existing photo from the device gallery via a gallery button accessible from the inline camera preview.

#### Scenario: User opens gallery from camera preview
- **WHEN** the user taps the gallery button on the inline camera preview
- **THEN** the device photo picker opens

#### Scenario: User selects photo
- **WHEN** the user selects a photo from the gallery
- **THEN** the image bytes are returned to the identification pipeline

### Requirement: Image handoff to classifier
The system SHALL pass the captured/selected image from the inline camera preview to the plant classifier preprocessing pipeline without requiring the UI to know about tensor shapes or ONNX details.

#### Scenario: Successful handoff
- **WHEN** an image is acquired from inline camera capture or gallery
- **THEN** the system passes image bytes to the classifier usecase and transitions the UI to the "identifying" state

#### Scenario: Invalid image handling
- **WHEN** the acquired image cannot be decoded or is corrupted
- **THEN** the system displays an error message and allows the user to retry
