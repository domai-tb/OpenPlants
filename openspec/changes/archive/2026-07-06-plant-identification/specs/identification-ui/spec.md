## ADDED Requirements

### Requirement: Identification page layout
The system SHALL display a plant identification page replacing the placeholder Page3, with a camera/gallery capture area and a results area.

#### Scenario: Initial state
- **WHEN** the user navigates to the identification page
- **THEN** they see a capture prompt with camera and gallery buttons, and no results are shown

#### Scenario: Page title and navigation
- **WHEN** the identification page is displayed
- **THEN** the page title reads "Plant ID" (localized) and the nav bar shows a camera/identification icon instead of the map icon

### Requirement: Captured image display
The system SHALL display the captured/selected image prominently on the page while identification is in progress and after results are shown.

#### Scenario: Image shown during inference
- **WHEN** the user captures or selects an image
- **THEN** the image is displayed on the page at a visible size

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

#### Scenario: Animation visual properties
- **WHEN** the animation is active
- **THEN** the dots are green, arranged in a regular grid pattern, and animate with opacity or scale pulsing to convey processing activity

### Requirement: Classification results display
The system SHALL display the top-5 classification results as a list of species cards below the captured image.

#### Scenario: Results shown after inference
- **WHEN** inference completes successfully
- **THEN** up to 5 species cards are displayed, each showing the Latin species name and confidence percentage

#### Scenario: Top-1 result highlighted
- **WHEN** results are displayed
- **THEN** the highest-confidence result is visually distinguished (e.g., larger text, accent color, or "Best match" label)

#### Scenario: Empty results
- **WHEN** inference returns no valid results (e.g., all probabilities near zero)
- **THEN** the system displays a "Could not identify plant" message

### Requirement: Loading state
The system SHALL show a loading indicator while image preprocessing and inference are running.

#### Scenario: Loading shown during processing
- **WHEN** the user captures/selects an image and inference begins
- **THEN** a loading indicator is visible (alongside the green dot lattice animation)

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
- **THEN** a "Retake" or camera button is visible to start a new identification

#### Scenario: Retake clears previous results
- **WHEN** the user taps retake
- **THEN** previous results are cleared and the page returns to the capture state
