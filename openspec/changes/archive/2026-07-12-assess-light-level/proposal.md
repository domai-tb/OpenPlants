## Why

The current light assessment feature uses an inline camera preview that provides a one-time brightness estimation. Users need a more interactive experience where they can explore different locations in real-time to find the ideal light level for their plants. A full-screen camera view with live light level estimation allows users to physically move around and see how light levels change, making the assessment more intuitive and accurate.

## What Changes

- Replace inline camera preview with a full-screen interactive camera view
- Add real-time light level estimation that updates continuously from the live camera feed
- Allow users to capture a photo when they find a suitable light level (photo stored for reference)
- Enable direct selection of light level from the live estimation without requiring a photo
- Support using existing photos from gallery or plant photo timeline for light assessment
- Add entry point from the "More" page for standalone light assessment (not plant-specific)
- Maintain existing plant detail page entry point for plant-specific assessment

## Capabilities

### Modified Capabilities

- `light-assessment`: Enhance with full-screen interactive camera view, real-time light estimation, photo capture, and multi-source assessment (camera, gallery, existing photos)

### New Capabilities

None - this change modifies existing capabilities only.

## Impact

- **Code**: `lib/pages/light_assessment/` (existing feature module) will be significantly refactored
- **Dependencies**: Reuses existing `camera` package and `InlineCameraPreview` patterns, may need `image_picker` for gallery access
- **UI**: New full-screen camera page with overlay controls, light level indicator, and capture button
- **Data**: Light assessment results continue to be stored in plant entity; new photo capture for light reference
- **Navigation**: New route for full-screen camera view, new entry point from "More" page
