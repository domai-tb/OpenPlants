## 1. Interactive Camera View

- [x] 1.1 Create new `InteractiveLightAssessmentPage` widget with full-screen camera view
- [x] 1.2 Implement live camera preview using `CameraController` with `startImageStream()`
- [x] 1.3 Add real-time light level indicator overlay that updates at 1-2 FPS
- [x] 1.4 Implement capture button that saves current frame to plant photo timeline
- [x] 1.5 Add "Set this level" button for direct light level selection without photo
- [x] 1.6 Implement camera timeout (2 minutes) with warning dialog
- [x] 1.7 Add battery usage warning and manual stop button

## 2. Multi-Source Assessment

- [x] 2.1 Refactor `CameraEstimationService` to support both frame stream and file-based estimation
- [x] 2.2 Add gallery photo picker integration to light assessment page
- [x] 2.3 Implement assessment from existing plant photos (most recent photo)
- [x] 2.4 Create unified assessment result display for all sources

## 3. Navigation and Entry Points

- [x] 3.1 Add full-screen camera route to app router
- [x] 3.2 Update plant detail page to include "Assess Light Level" button
- [x] 3.3 Add "Light Assessment" entry point to More page
- [x] 3.4 Implement standalone mode for More page entry (no plant context)
- [x] 3.5 Add plant selection dialog for standalone mode photo saving

## 4. UI Enhancements

- [x] 4.1 Design and implement light level indicator overlay (semi-transparent, positioned at top)
- [x] 4.2 Add capture animation and feedback when taking photo
- [x] 4.3 Implement smooth transitions between full-screen camera and assessment page
- [x] 4.4 Add guidance text for optimal light assessment conditions
- [x] 4.5 Display confidence level for brightness estimation

## 5. Integration and Testing

- [x] 5.1 Integrate with existing `LightAssessmentUseCases` for data persistence
- [x] 5.2 Add unit tests for `CameraEstimationService` frame processing
- [x] 5.3 Add widget tests for `InteractiveLightAssessmentPage`
- [x] 5.4 Test camera permission handling in full-screen mode
- [x] 5.5 Test battery and performance on low-end devices
