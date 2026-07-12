## Context

The current light assessment feature uses an inline camera preview within a scrollable page. Users must take a photo first, then wait for analysis. This workflow doesn't allow users to explore different locations in real-time to find ideal light levels.

The app follows Clean Architecture with GetIt dependency injection. Camera functionality is provided via the `camera` package with an existing `InlineCameraPreview` widget. Light level estimation uses `CameraEstimationService` for brightness analysis.

## Goals / Non-Goals

**Goals:**
- Provide a full-screen interactive camera view for real-time light level exploration
- Display live light level estimation overlay that updates continuously
- Allow users to capture a photo when they find suitable light (stored for reference)
- Support direct light level selection from live estimation without requiring a photo
- Enable assessment from gallery photos or existing plant photos
- Add standalone entry point from "More" page
- Maintain existing plant-specific entry point

**Non-Goals:**
- Multi-frame or video-based analysis (single frame estimation is sufficient)
- AI-powered scene understanding beyond brightness analysis
- Light level history tracking or trending over time
- Integration with external light sensors or hardware

## Decisions

### 1. Full-screen camera page with overlay UI

**Decision**: Create a dedicated full-screen `InteractiveLightAssessmentPage` with camera viewfinder as background and overlaid controls.

**Rationale**: Full-screen provides immersive exploration experience. Overlay controls keep the camera visible while providing access to actions.

**Alternatives considered**:
- Modal bottom sheet: Rejected because it obscures the camera view
- Dialog-based: Too restrictive for real-time exploration
- Inline widget in existing page: Current approach, doesn't provide immersive experience

### 2. Real-time estimation via frame stream processing

**Decision**: Process camera frames at 1-2 FPS using `CameraController.startImageStream()` to provide live brightness feedback without overwhelming the CPU.

**Rationale**: Low frame rate balances responsiveness with battery/CPU usage. 1-2 FPS is sufficient for light level changes as user moves around.

**Alternatives considered**:
- Event-based (on user gesture): Rejected because users want to see changes as they move
- High FPS (30+): Unnecessary for brightness analysis, wastes battery
- Background isolates: Overkill for simple brightness calculation

### 3. Photo capture as optional reference

**Decision**: When user taps capture, save the current frame as a photo in the plant's timeline and use it for final brightness estimation.

**Rationale**: Photo provides a reference point for future comparison and integrates with existing photo timeline feature.

**Alternatives considered**:
- No photo storage: Loses reference for future comparison
- Auto-capture on level selection: May capture unwanted frames
- Video recording: Out of scope, complex storage requirements

### 4. Multi-source assessment entry

**Decision**: Support three entry paths:
1. From plant detail page (plant-specific, can use existing plant photo)
2. From "More" page (standalone, no plant context, camera-only)
3. From light assessment result card on dashboard (plant-specific)

**Rationale**: Provides flexibility for different use cases while maintaining clear context.

**Alternatives considered**:
- Single entry point: Less flexible
- Deep linking only: Less discoverable

### 5. Light level selection from live estimation

**Decision**: Display current estimated level prominently with a "Set this level" button that applies the level without capturing a photo.

**Rationale**: Users may want to quickly set a level based on visual inspection without creating a photo record.

**Alternatives considered**:
- Require photo for every selection: Unnecessarily restrictive
- Auto-set on stable reading: May set incorrect level if user is still moving

## Risks / Trade-offs

### Risk: Camera performance on low-end devices
**Mitigation**: Use lower resolution for frame processing, implement frame skipping, provide fallback to photo-based estimation if performance is poor.

### Risk: Battery drain from continuous camera use
**Mitigation**: Implement automatic timeout (e.g., 2 minutes), display battery warning, allow manual stop. Camera releases when user navigates away.

### Risk: Brightness estimation accuracy varies by lighting conditions
**Mitigation**: Display confidence level, allow manual override, provide guidance text about optimal assessment conditions.

### Risk: Camera permission handling complexity
**Mitigation**: Reuse existing `InlineCameraPreview` permission patterns, add clear rationale in full-screen view.

## Migration Plan

1. **Phase 1**: Create new `InteractiveLightAssessmentPage` alongside existing page
2. **Phase 2**: Update navigation to use new page from plant detail and "More" page
3. **Phase 3**: Deprecate inline camera approach in existing page (keep as fallback)
4. **Phase 4**: Remove old inline camera code after verification

## Open Questions

- Should the live estimation overlay show raw brightness percentage or just the light level label?
- How should the "More" page entry point handle the case where no plant is selected?
- Should captured photos be automatically added to the plant's timeline or stored separately?
