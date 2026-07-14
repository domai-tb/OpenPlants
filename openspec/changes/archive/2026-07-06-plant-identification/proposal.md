## Why

OpenPlant ships with a bundled ONNX model (`assets/ml/plant-identification/model.onnx`) that can identify 14,829 plant species from a photo — but no Dart code uses it. The model, labels, and preprocessing config are ready; the app has no camera integration, no inference pipeline, and no UI to trigger identification. This change wires the existing model into a working "snap a plant, learn what it is" experience.

## What Changes

- Add a new **Plant Identification page** (replacing the placeholder Page3) with camera capture and classification results display.
- Add a **green dot lattice animation** that overlays the captured image while inference is running.
- Add an **ONNX inference pipeline** in the domain/infrastructure layers: image preprocessing, model session lifecycle, softmax postprocessing, and top-k label mapping.
- Add **camera access** via the `image_picker` package for gallery and camera capture.
- Add **ONNX Runtime** dependency (`onnxruntime` Flutter plugin) for native model execution.
- Register the new feature in DI (`injection.dart`) and `AppServices`.

## Capabilities

### New Capabilities

- `plant-classifier`: ONNX model loading, image preprocessing (resize 224×224, normalize mean=[0.5,0.5,0.5] std=[0.5,0.5,0.5], rescale, NCHW layout), inference execution, softmax postprocessing, top-k label mapping from `labels.json`. Session lifecycle management.
- `camera-capture`: Camera and gallery image acquisition via `image_picker`. Image bytes → preprocessing pipeline handoff.
- `identification-ui`: The plant identification page with camera button, captured image display, green dot lattice animation overlay during inference, and classification result cards (top-k species with confidence scores).

### Modified Capabilities

_(none — this is additive; Page3 placeholder content is replaced but no existing spec-level behavior changes)_

## Impact

- **New dependencies**: `onnxruntime` (Flutter ONNX Runtime plugin), `image_picker` (camera/gallery access), `camera` (if direct camera stream is needed — evaluate during implementation).
- **Asset bundle**: `assets/ml/plant-identification/` must be declared in `pubspec.yaml` under `flutter.assets` so the ONNX model, labels, and config are loadable at runtime.
- **Code changes**:
  - `lib/pages/page3/` — full rewrite of datasource, repository, usecases, entity, and page.
  - `lib/core/injection.dart` — register new classifier-related singletons.
  - `lib/core/app_services.dart` — expose the new page's usecases.
  - `lib/pages/home/page_navigator.dart` — update Page3 routing and icon (camera/identify icon instead of map).
  - `assets/l10n/l10n_en.arb` + `l10n_de.arb` — new localization strings for the identification UI.
  - `pubspec.yaml` — add dependencies and asset declarations.
- **Platform considerations**: Android-only target (minSdk 26). ONNX Runtime supports Android CPU execution. No iOS testing required per current project scope.
- **Model contract** (from `onnx_export_info.json` and `preprocessor_config.json`):
  - Input: `pixel_values` → `[1, 3, 224, 224]` float32, NCHW
  - Output: `logits` → `[1, 14829]` float32
  - Preprocessing: resize 224×224, rescale ×0.00392156862745098, normalize (x - 0.5) / 0.5
  - Postprocessing: softmax over 14,829 logits → top-k species with confidence
