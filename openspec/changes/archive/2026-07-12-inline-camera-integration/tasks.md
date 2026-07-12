## 1. Shared Inline Camera Widget

- [x] 1.1 Create `lib/shared/widgets/inline_camera_preview.dart` with `CameraController` lifecycle management (init on mount, dispose on unmount), back camera selection, low resolution preset
- [x] 1.2 Add permission handling UI to the widget: in-page permission request screen with rationale, "Grant access" button, and permanent-denial fallback directing to system settings
- [x] 1.3 Add capture button overlay on the camera preview that invokes `onCaptured(Uint8List bytes)` callback
- [x] 1.4 Add gallery button alongside the capture button that opens `ImagePicker` with `ImageSource.gallery` and returns bytes via the same `onCaptured` callback
- [x] 1.5 Add loading state while `CameraController` initializes (shimmer or spinner overlay)

## 2. Plant Identification Page Integration

- [x] 2.1 Replace `CapturePrompt` widget in `PlantIdentificationPage._buildContent()` with `InlineCameraPreview` as the default initial state (`IdentificationIdle` shows camera, not prompt)
- [x] 2.2 Wire `InlineCameraPreview.onCaptured` to `_startIdentification()` — remove `_captureFromCamera()` and `_pickFromGallery()` methods that use `ImageCaptureService`
- [x] 2.3 Update `IdentificationIdle` state to show camera preview instead of `CapturePrompt` with two buttons
- [x] 2.4 Verify retake flow returns to inline camera preview (not the old capture prompt)

## 3. Light Assessment Page Integration

- [x] 3.1 Replace `_takePhotoAndEstimate()` in `LightAssessmentPage` to use inline camera preview instead of `ImagePicker.pickImage(source: camera)`
- [x] 3.2 Add inline camera preview section to the light assessment page layout, showing live viewfinder when camera estimation is active
- [x] 3.3 Wire captured photo from inline camera to `_analyzePhoto()` flow and plant timeline save
- [x] 3.4 Keep gallery picker as secondary option via the `InlineCameraPreview` widget's gallery button

## 4. Symptom Logger Page Integration

- [x] 4.1 Replace `ImageCaptureService` camera call in `SymptomLoggerPage` with `InlineCameraPreview` widget
- [x] 4.2 Wire captured photo to the symptom form's `photoPath` field
- [x] 4.3 Ensure gallery fallback works via the widget's gallery button

## 5. Plant Journal Entry Form Integration

- [x] 5.1 Replace `ImagePicker.pickImage(source: camera)` in `PlantJournalEntryFormPage` with `InlineCameraPreview` widget
- [x] 5.2 Wire captured photo to `_selectedPhoto` state variable
- [x] 5.3 Ensure gallery fallback works via the widget's gallery button

## 6. Cleanup and Validation

- [x] 6.1 Deprecate or remove `ImageCaptureService` class (no longer needed after all pages migrated)
- [x] 6.2 Run `fvm flutter analyze` — fix all lint violations
- [x] 6.3 Run `fvm flutter test` — ensure existing tests pass
- [x] 6.4 Manual verification: confirm camera opens inline on plant identification page, light assessment page, symptom logger, and journal entry form
