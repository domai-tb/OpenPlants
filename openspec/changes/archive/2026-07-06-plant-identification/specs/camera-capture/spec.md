## ADDED Requirements

### Requirement: Camera capture
The system SHALL allow the user to take a photo using the device camera for plant identification.

#### Scenario: User opens camera
- **WHEN** the user taps the camera capture button on the identification page
- **THEN** the device camera interface opens

#### Scenario: User captures photo
- **WHEN** the user confirms a captured photo
- **THEN** the image bytes are returned to the identification pipeline

#### Scenario: Camera permission denied
- **WHEN** the user denies camera permission
- **THEN** the system shows a rationale explaining why camera access is needed and offers gallery-only fallback

### Requirement: Gallery selection
The system SHALL allow the user to pick an existing photo from the device gallery for plant identification.

#### Scenario: User opens gallery
- **WHEN** the user taps the gallery button on the identification page
- **THEN** the device photo picker opens

#### Scenario: User selects photo
- **WHEN** the user selects a photo from the gallery
- **THEN** the image bytes are returned to the identification pipeline

### Requirement: Image handoff to classifier
The system SHALL pass the captured/selected image to the plant classifier preprocessing pipeline without requiring the UI to know about tensor shapes or ONNX details.

#### Scenario: Successful handoff
- **WHEN** an image is acquired from camera or gallery
- **THEN** the system passes image bytes to the classifier usecase and transitions the UI to the "identifying" state

#### Scenario: Invalid image handling
- **WHEN** the acquired image cannot be decoded or is corrupted
- **THEN** the system displays an error message and allows the user to retry
