# Inline Camera

## Purpose

Provides a reusable inline camera preview widget for capturing photos within page layouts, replacing system camera launches.

## Requirements

### Requirement: Inline camera preview widget
The system SHALL provide a reusable `InlineCameraPreview` widget that displays a live camera viewfinder within the page widget tree.

#### Scenario: Camera preview renders in page
- **WHEN** a page includes the `InlineCameraPreview` widget and camera permission is granted
- **THEN** a live camera preview from the back camera is displayed within the page layout

#### Scenario: Camera initializes on mount
- **WHEN** the `InlineCameraPreview` widget is inserted into the widget tree
- **THEN** the widget initializes a `CameraController` with the back camera at low resolution and displays the preview once ready

#### Scenario: Camera disposes on unmount
- **WHEN** the `InlineCameraPreview` widget is removed from the widget tree
- **THEN** the `CameraController` is disposed and camera resources are released

### Requirement: Capture from inline preview
The system SHALL allow the user to capture a photo by tapping a capture button overlaid on the inline camera preview.

#### Scenario: User taps capture button
- **WHEN** the user taps the capture button on the inline camera preview
- **THEN** the system captures a single frame from the camera and invokes the `onCaptured` callback with the image bytes

#### Scenario: Capture button disabled during initialization
- **WHEN** the camera controller is still initializing
- **THEN** the capture button is visually disabled and tapping it has no effect

### Requirement: Camera permission handling in-page
The system SHALL request camera permission and display an in-page fallback UI if permission is denied, rather than relying solely on the system permission dialog.

#### Scenario: Permission not yet requested
- **WHEN** the `InlineCameraPreview` widget mounts and camera permission has not been granted
- **THEN** the widget displays an in-page permission request screen with a rationale and a "Grant access" button

#### Scenario: User grants permission via in-page button
- **WHEN** the user taps "Grant access" on the in-page permission screen
- **THEN** the system triggers the platform permission request dialog

#### Scenario: Permission granted after dialog
- **WHEN** the user grants permission in the system dialog
- **THEN** the in-page permission screen is replaced by the live camera preview

#### Scenario: Permission permanently denied
- **WHEN** the user denies camera permission and selects "Don't ask again" (Android)
- **THEN** the in-page screen shows a message directing the user to system settings to enable camera access, with a gallery-only fallback option

### Requirement: Gallery fallback from inline camera
The system SHALL provide a gallery picker option accessible from the inline camera preview, allowing the user to select an existing photo instead of capturing a new one.

#### Scenario: Gallery button visible on camera preview
- **WHEN** the inline camera preview is displayed
- **THEN** a gallery button is visible alongside or near the capture button

#### Scenario: User taps gallery button
- **WHEN** the user taps the gallery button on the inline camera preview
- **THEN** the system opens the device photo picker and returns the selected image bytes via the `onCaptured` callback
