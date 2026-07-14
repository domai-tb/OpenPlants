## Context

OpenPlant is a Flutter plant companion app (Android-only, minSdk 26) using Clean Architecture with layered design: Page → UseCase → Repository → DataSource. The app has a bundled ONNX ViT model (`assets/ml/plant-identification/`) capable of identifying 14,829 plant species, but no Dart code currently uses it.

The existing Page3 is a generic placeholder with hardcoded items. This design replaces it with a full plant identification feature: camera capture → ONNX inference → species result display.

Key model contract (from `onnx_export_info.json` and `preprocessor_config.json`):
- Input: `pixel_values` → `[1, 3, 224, 224]` float32, NCHW layout
- Output: `logits` → `[1, 14829]` float32
- Preprocessing: resize 224×224, rescale ×(1/255), normalize `(x - 0.5) / 0.5`
- Labels: `labels.json` maps 0–14828 to Latin species names

## Goals / Non-Goals

**Goals:**
- Wire the existing ONNX model into a working end-to-end identification flow
- Camera capture from device camera or photo gallery
- Green dot lattice animation overlay during inference
- Display top-5 species predictions with confidence scores
- Reuse the existing Clean Architecture layering (DataSource → Repository → UseCase → Page)
- Keep ONNX session long-lived (created once, reused per inference)
- All inference runs on-device (privacy-first, offline-capable)

**Non-Goals:**
- Live camera stream classification (still-image only for now)
- Plant care reminders or scheduling tied to identified plants
- Saving identified plants to a collection (future feature)
- iOS support (Android-only per current scope)
- Hardware acceleration beyond CPU (NNAPI/CoreML can come later)
- Batch classification or multi-image input

## Decisions

### D1: Replace Page3 rather than adding a new page

**Choice**: Rewrite Page3 as the plant identification page.

**Rationale**: Page3 is a placeholder with no real functionality. Adding a 7th page would require reworking the nav system (max tabs, layout constraints). Replacing an existing placeholder is cleaner and keeps the nav bar at 6 items.

**Alternatives considered**:
- Add as Page7 → breaks the existing 6-page nav structure, requires nav rework
- Replace Page1 (home) → risky, Page1 has the most complex UI patterns to preserve

### D2: Use `image_picker` for image acquisition

**Choice**: Use the `image_picker` package for both camera and gallery.

**Rationale**: Mature, well-maintained package. Handles camera permissions, gallery access, and image resolution. Returns `XFile` with path for efficient file-based loading. Avoids building custom camera UI.

**Alternatives considered**:
- `camera` package → overkill for single-shot capture; requires building preview UI, managing camera lifecycle, frame processing. Better for live inference which is out of scope.
- Platform channels directly → reinvents what image_picker does

### D3: ONNX Runtime via `onnxruntime` Flutter plugin

**Choice**: Use the `onnxruntime` package for Flutter.

**Rationale**: Official ONNX Runtime Flutter plugin. Supports Android CPU execution. Handles native session lifecycle. Well-documented tensor API.

**Alternatives considered**:
- `tflite_flutter` → would require converting the ONNX model to TFLite format, adding conversion step and potential accuracy loss
- `ort_mobile` via FFI → more control but much more integration work

### D4: Long-lived ONNX session, single-threaded inference

**Choice**: Create the ONNX session once (lazily on first inference), reuse for all subsequent calls. Run inference synchronously within an async context (not in an isolate for v1).

**Rationale**: Session creation is expensive (~100ms+). For still-image classification, the latency is dominated by preprocessing + inference (~200-500ms on mid-range devices), which is acceptable on the main isolate for v1. Isolates add complexity (message passing, memory copying) that isn't justified yet.

**Alternatives considered**:
- Create session per inference → wasteful, measurable startup cost each time
- Use isolates from the start → premature optimization; can be added later if profiling shows jank

### D5: Preprocessing in pure Dart (no native code)

**Choice**: Implement image preprocessing (decode → resize → normalize → NCHW tensor) in Dart using existing Flutter image libraries.

**Rationale**: The preprocessing pipeline is straightforward (resize + normalize). Flutter's `image` package or similar can handle decode/resize. Normalization loops in Dart are fast enough for single images.

**Alternatives considered**:
- Native preprocessing via platform channels → unnecessary complexity for simple operations
- GPU preprocessing → out of scope for v1

### D6: Green dot lattice as a CustomPainter overlay

**Choice**: Implement the "green dot lattice" animation as a `CustomPainter` with `AnimationController` overlay on the captured image.

**Rationale**: Lightweight, no external dependencies. A grid of dots with staggered opacity animation creates the lattice effect. CustomPainter gives full control over positioning and animation timing.

**Alternatives considered**:
- Lottie animation → requires external asset, less control over dot positioning relative to image
- Rive → heavier dependency, overkill for a simple dot grid
- Static overlay → no animation, doesn't match the "while running" feel

## Risks / Trade-offs

- **[ONNX model size]** The `model.onnx` + `model.onnx.data` files are large (likely 300MB+). This increases APK size significantly. → **Mitigation**: Accept for v1. Future: use Android App Bundles with dynamic delivery, or offer model download post-install.

- **[14,829 species]** The label set is massive. Some species are extremely obscure. Users may see low-confidence results for common garden plants. → **Mitigation**: Show top-5 with confidence. Users can scroll the full list. Future: add a "common plants" curated subset.

- **[No persistence]** Identified plants are not saved. Users lose results on page exit. → **Mitigation**: Accept for v1. Future: add a "My Plants" collection feature.

- **[Single-threaded inference]** On very low-end devices, inference may block the UI thread for 500ms+. → **Mitigation**: Show the green dot lattice animation to provide visual feedback. Move to isolate in v2 if needed.

- **[Camera permission]** Users must grant camera permission. Denial means no identification. → **Mitigation**: Clear permission rationale UI. Graceful fallback to gallery-only if camera denied.

- **[Image orientation]** Camera images may have EXIF orientation metadata. Incorrect handling produces rotated/wrong predictions. → **Mitigation**: Apply EXIF orientation correction during preprocessing before tensor creation.
