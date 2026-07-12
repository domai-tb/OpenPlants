## Why

The current camera flow in OpenPlant opens the system camera app, which takes the user out of the app context. This creates friction: the user loses sight of their plant data, the UI state resets, and the experience feels disjointed. For a plant companion app where quick identification and light assessment are core workflows, the camera should feel like a native part of the page — not a detour.

## What Changes

- **Plant identification page**: Replace the system camera picker with an inline camera preview that opens directly within the page. Camera becomes the default mode (not gallery). The user sees a live viewfinder, taps to capture, and the image flows into the classifier without leaving the page.
- **Light assessment page**: Replace `ImagePicker.pickImage(source: camera)` with an inline camera preview. The user can take a photo directly in the page to estimate light levels, keeping context intact.
- **Shared camera widget**: Extract a reusable `InlineCameraPreview` widget that wraps the `camera` package's `CameraController` and provides a standardized capture UX (viewfinder, capture button, permission handling). This widget will be used by both features and any future camera-using components.
- **Symptom logger & plant journal**: These pages also use `image_picker` for camera. They will adopt the same inline camera pattern for consistency.

## Capabilities

### New Capabilities
- `inline-camera`: Reusable inline camera preview widget with capture, permission handling, and gallery fallback. Used across all camera-using features.

### Modified Capabilities
- `camera-capture`: Requirement changes from "device camera interface opens" to "inline camera preview opens within the page". Gallery fallback remains.
- `identification-ui`: Initial state changes from capture prompt to live camera preview. Gallery becomes a secondary option.
- `light-assessment`: Camera estimation uses inline preview instead of system camera picker.

## Impact

- **Code**: New shared widget in `lib/core/widgets/` or `lib/shared/`. Changes to `plant_identification_page.dart`, `light_assessment_page.dart`, `symptom_logger_page.dart`, `plant_journal_entry_form_page.dart`. Deprecation of `ImageCaptureService` wrapper (replaced by shared widget).
- **Dependencies**: `camera: ^0.11.2` already in pubspec — no new deps needed. `image_picker` retained for gallery-only fallback.
- **Permissions**: Android `CAMERA` permission already declared. No new permissions needed.
- **State management**: Pages must manage `CameraController` lifecycle (init/dispose). The shared widget handles this internally.
