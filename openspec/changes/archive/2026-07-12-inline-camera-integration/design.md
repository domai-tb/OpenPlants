## Context

OpenPlant currently uses `image_picker` to launch the system camera app for photo capture. This works but forces the user out of the app context. The `camera` package (`^0.11.2`) is already a dependency and is used in `CameraEstimationService` for light level brightness analysis — proving inline camera access is viable on the target platform.

The app is Android-only (minSdk 26). The `camera` package supports CameraX on Android, which is the modern camera API. No iOS considerations needed.

Four pages currently use camera: plant identification, light assessment, symptom logger, and plant journal entry form. All follow the same pattern: user taps camera button → system camera opens → photo returned → processed.

## Goals / Non-Goals

**Goals:**
- Replace system camera launches with inline camera previews inside the page
- Plant identification defaults to camera mode (live viewfinder visible on page open)
- Light assessment uses inline camera for brightness estimation
- Extract a reusable `InlineCameraPreview` widget shared across all camera-using features
- Maintain gallery fallback for users who prefer existing photos
- Handle camera permissions gracefully with in-page UI (no system dialogs blocking flow)

**Non-Goals:**
- Redesigning the classification or brightness estimation algorithms
- Adding video capture or multi-shot burst modes
- Supporting front-facing camera (back camera only for plant photos)
- Changing the `camera` package version or switching to a different camera plugin
- Modifying the ONNX classifier pipeline or tensor preprocessing

## Decisions

### Decision 1: Shared `InlineCameraPreview` widget

**Choice**: Create a single reusable widget in `lib/shared/widgets/inline_camera_preview.dart` that encapsulates `CameraController` lifecycle, permission handling, and capture UX.

**Alternatives considered**:
- *Per-page camera logic*: Each page manages its own `CameraController`. Rejected — leads to duplicated lifecycle code across 4+ pages.
- *Service-level camera*: A global `CameraService` singleton. Rejected — conflicts with Flutter's widget tree lifecycle model and makes disposal harder.

**Rationale**: A widget naturally owns the `CameraController` lifecycle via `initState`/`dispose`. It composes cleanly into any page's widget tree. The widget exposes an `onCaptured(Uint8List bytes)` callback so pages only handle the result, not camera mechanics.

### Decision 2: Camera as default mode on identification page

**Choice**: When the identification page opens, the inline camera preview is immediately visible. Gallery is accessible via a secondary button/overlay.

**Alternatives considered**:
- *Prompt-first (current)*: Show capture prompt with two equal buttons. Rejected — adds an unnecessary tap before the primary action.
- *Auto-capture on open*: Immediately capture when page opens. Rejected — user needs to aim first.

**Rationale**: The user's intent when opening identification is almost always to photograph their plant now. Showing the viewfinder immediately reduces time-to-action from 2 taps to 1 (just tap capture).

### Decision 3: CameraController lifecycle ownership

**Choice**: The `InlineCameraPreview` widget owns the `CameraController` — it initializes on mount and disposes on unmount. Pages receive captured bytes via callback.

**Alternatives considered**:
- *Page owns controller, widget is pure display*: Page creates `CameraController`, passes to widget. Rejected — pushes lifecycle complexity into every consuming page.
- *Controller cached across page transitions*: Keep camera warm when navigating away briefly. Deferred — adds complexity; can be optimized later if startup latency is a problem.

**Rationale**: Encapsulation. The widget is self-contained — drop it in, get a camera. Pages don't need to know about `ResolutionPreset`, `enableAudio`, or controller initialization order.

### Decision 4: Permission handling via widget overlay

**Choice**: When camera permission is not yet granted, the `InlineCameraPreview` shows an in-page permission request UI (icon + "Grant access" button) instead of relying solely on the system permission dialog.

**Alternatives considered**:
- *System dialog only*: Just call `CameraController` and handle `CameraException`. Rejected — poor UX if denied; user sees a blank/black area with no guidance.
- *Pre-permission screen before page*: Request permission before navigating to the page. Rejected — user hasn't seen the value yet; premature permission requests have lower grant rates.

**Rationale**: In-page permission UI provides context (why camera is needed) and a clear retry path. The system dialog still fires, but if denied, the user sees a helpful fallback instead of a dead state.

### Decision 5: Retain `image_picker` for gallery only

**Choice**: Keep `image_picker` dependency but only use `ImageSource.gallery`. Camera capture moves to the `camera` package via `InlineCameraPreview`.

**Alternatives considered**:
- *Remove `image_picker` entirely*: Use `photo_manager` or custom gallery picker. Rejected — overkill; `image_picker` gallery works fine and is already tested.
- *Use `camera` package for gallery too*: Not supported — `camera` is for live capture only.

**Rationale**: Minimal change. `image_picker` gallery is battle-tested and handles platform gallery UI. No reason to replace it.

## Risks / Trade-offs

- **[Risk] Camera startup latency on low-end devices** → Mitigation: Use `ResolutionPreset.low` for initial preview (same as `CameraEstimationService`). Show a loading shimmer while controller initializes. Can optimize to `medium` later if quality is insufficient.

- **[Risk] Camera resource conflicts if page is navigated away and back** → Mitigation: Controller disposes on widget unmount, re-initializes on mount. This is standard Flutter lifecycle. No singleton caching.

- **[Risk] Android camera permission denials** → Mitigation: In-page permission UI with rationale. If permanently denied, direct user to system settings. Gallery fallback always available.

- **[Trade-off] Slightly larger widget tree per page** → Acceptable. The shared widget encapsulates complexity; consuming pages add ~5 lines of code.

- **[Trade-off] No front-facing camera support** → Acceptable for v1. Plant photos are always taken with the back camera. Can add lens selection later if user demand exists.
