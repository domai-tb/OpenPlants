# Identification UI

## Purpose

Provides the user-facing interface for plant identification, including image display, inference animation, results, and error handling.

## Requirements

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

### Requirement: Green dot lattice animation
The system SHALL overlay a green dot lattice animation on the captured image while the ONNX inference is running.

#### Scenario: Animation starts on inference begin
- **WHEN** inference starts after image capture
- **THEN** a grid of green dots appears over the captured image with staggered fade-in/pulse animation

#### Scenario: Animation stops on inference complete
- **WHEN** inference completes (success or error)
- **THEN** the green dot lattice animation fades out and disappears

### Requirement: Classification results display
The system SHALL display the top-5 classification results as a list of species cards below the captured image in the identification modal.

#### Scenario: Results shown after inference
- **WHEN** inference completes successfully
- **THEN** up to 5 species cards are displayed, each showing the Latin species name and confidence percentage

#### Scenario: Top-1 result highlighted
- **WHEN** results are displayed
- **THEN** the highest-confidence result is visually distinguished

#### Scenario: Empty results
- **WHEN** inference returns no valid results
- **THEN** the system displays a "Could not identify plant" message

### Requirement: Loading state
The system SHALL show a loading indicator while image preprocessing and inference are running.

#### Scenario: Loading shown during processing
- **WHEN** the user captures/selects an image and inference begins
- **THEN** a loading indicator is visible alongside the green dot lattice animation

#### Scenario: Loading hidden after completion
- **WHEN** inference completes
- **THEN** the loading indicator is removed and results (or error) are displayed

### Requirement: Error display
The system SHALL display user-friendly error messages when identification fails.

#### Scenario: Model loading error
- **WHEN** the ONNX model fails to load
- **THEN** the system displays "Could not load plant identification model" with a retry option

#### Scenario: Inference error
- **WHEN** the ONNX session fails during inference
- **THEN** the system displays "Identification failed" with a retry option

#### Scenario: Retry from error
- **WHEN** the user taps retry after an error
- **THEN** the system returns to the initial capture state

### Requirement: Retake flow
The system SHALL allow the user to capture a new photo after viewing results.

#### Scenario: Retake button visible after results
- **WHEN** classification results are displayed
- **THEN** a retake button is visible to start a new identification

#### Scenario: Retake clears previous results
- **WHEN** the user taps retake
- **THEN** previous results are cleared and the modal returns to the capture state

### Requirement: Add to collection from identification results
The system SHALL provide an "Add to collection" button in the identification modal that navigates to the add-plant form with the identified species pre-selected.

#### Scenario: Add to collection with species pre-filled
- **WHEN** classification results are displayed and the user taps "Add to collection"
- **THEN** the system opens the add-plant form with the top-matched species pre-selected

#### Scenario: No results — manual entry
- **WHEN** classification returns no valid results and the user taps "Add to collection"
- **THEN** the system opens the add-plant form with no species pre-selected

### Requirement: View species detail from results
The identification modal SHALL allow users to tap a species result to view its full species detail page.

#### Scenario: Tap species opens detail
- **WHEN** the user taps a species result card
- **THEN** the system pushes SpeciesDetailPage on the root navigator for that species

### Requirement: Identification picker mode on add-plant form
The system SHALL provide an "identification picker" mode on the add-plant form. In picker mode, each species result card SHALL be tappable, and tapping it SHALL select that species. A manual entry option SHALL be available to type a custom species name.

#### Scenario: Results are tappable in picker mode
- **WHEN** identification results are displayed in picker mode on the add-plant form
- **THEN** each species card SHALL be tappable with a visual indication

#### Scenario: Tap result selects species
- **WHEN** the user taps a species result card in picker mode
- **THEN** the system SHALL register that species as selected and provide a callback

#### Scenario: Manual entry option visible
- **WHEN** identification results are displayed in picker mode
- **THEN** a "Enter manually" field SHALL be visible below the results list
