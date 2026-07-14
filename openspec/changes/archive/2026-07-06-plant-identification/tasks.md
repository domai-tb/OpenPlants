## 1. Setup & Dependencies

- [x] 1.1 Add `onnxruntime` and `image_picker` packages to `pubspec.yaml` dependencies
- [x] 1.2 Declare `assets/ml/plant-identification/` in `pubspec.yaml` under `flutter.assets`
- [x] 1.3 Run `fvm flutter pub get` to install new dependencies

## 2. ONNX Classifier Infrastructure

- [x] 2.1 Create `lib/pages/page3/classifier/plant_classifier.dart` — ONNX session lifecycle: load model from asset, create session, dispose
- [x] 2.2 Create `lib/pages/page3/classifier/image_preprocessor.dart` — decode image bytes, apply EXIF orientation, resize to 224×224, rescale/normalize, build NCHW float32 tensor
- [x] 2.3 Create `lib/pages/page3/classifier/softmax_postprocessor.dart` — numerically stable softmax over logits, top-k selection with label mapping
- [x] 2.4 Create `lib/pages/page3/classifier/classification_result.dart` — domain entity: `ClassificationResult` with list of `SpeciesPrediction` (name, confidence, index)
- [x] 2.5 Create `lib/pages/page3/classifier/labels_loader.dart` — load and parse `labels.json` from assets into `Map<int, String>`
- [x] 2.6 Create `lib/pages/page3/classifier/plant_classifier_datasource.dart` — orchestrates preprocess → infer → postprocess, returns `ClassificationResult`
- [x] 2.7 Create `lib/pages/page3/classifier/plant_classifier_repository.dart` — wraps datasource, maps to domain entities
- [x] 2.8 Create `lib/pages/page3/classifier/plant_classifier_usecases.dart` — exposes `classifyImage(Uint8List imageBytes)` to the UI layer

## 3. Camera & Image Capture

- [x] 3.1 Create `lib/pages/page3/camera/image_capture_service.dart` — wraps `image_picker`: `captureFromCamera()` and `pickFromGallery()` returning `Uint8List`
- [x] 3.2 Handle camera permission request flow with rationale dialog on denial
- [x] 3.3 Handle gallery permission (if needed for Android version differences)

## 4. Identification Page UI

- [x] 4.1 Rewrite `lib/pages/page3/page3_item_entity.dart` — replace placeholder entity with `IdentificationState` (idle, capturing, identifying, result, error)
- [x] 4.2 Create `lib/pages/page3/widgets/green_dot_lattice_painter.dart` — CustomPainter that draws a grid of green dots with staggered pulse animation
- [x] 4.3 Create `lib/pages/page3/widgets/green_dot_lattice_overlay.dart` — wraps the painter in an AnimatedBuilder, positioned over the captured image
- [x] 4.4 Create `lib/pages/page3/widgets/species_result_card.dart` — displays a single species prediction (name + confidence %), with highlighted variant for top-1
- [x] 4.5 Create `lib/pages/page3/widgets/capture_prompt.dart` — initial state UI with camera and gallery buttons
- [x] 4.6 Rewrite `lib/pages/page3/page3_page.dart` — full page: state machine (idle → identifying → result/error), image display, lattice overlay, results list, retake button
- [x] 4.7 Add loading indicator (circular progress) during inference alongside lattice animation

## 5. DI & Wiring

- [x] 5.1 Register `PlantClassifierDatasource`, `PlantClassifierRepository`, `PlantClassifierUsecases` as lazy singletons in `lib/core/injection.dart`
- [x] 5.2 Update `lib/core/app_services.dart` to expose `PlantClassifierUsecases` (renamed from `Page3Usecases`)
- [x] 5.3 Update `lib/pages/home/page_navigator.dart` — change Page3 icon from `Icons.map` to `Icons.camera_alt` (or `Icons.eco`), update title to "Plant ID"
- [x] 5.4 Update `lib/pages/home/page_navigator.dart` Page3 case to use the rewritten page

## 6. Localization

- [x] 6.1 Add new strings to `assets/l10n/l10n_en.arb`: page title, capture prompt, retake button, error messages, result labels
- [x] 6.2 Add corresponding German translations to `assets/l10n/l10n_de.arb`
- [x] 6.3 Run `fvm flutter gen-l10n` to regenerate localization code

## 7. Rename & Cleanup (Generic Page References)

- [x] 7.1 Rename directory `lib/pages/page3/` → `lib/pages/plant_identification/`
- [x] 7.2 Rename files within the new directory: `page3_page.dart` → `plant_identification_page.dart`, `page3_datasource.dart` → `plant_identification_datasource.dart`, `page3_repository.dart` → `plant_identification_repository.dart`, `page3_usecases.dart` → `plant_identification_usecases.dart`, `page3_item_entity.dart` → `identification_state.dart`
- [x] 7.3 Rename `PageItem.page3` enum value → `PageItem.plantIdentification` in `lib/pages/home/page_navigator.dart` and update all references
- [x] 7.4 Rename `AppServices.page3` field → `AppServices.plantIdentification` in `lib/core/app_services.dart` and update all references
- [x] 7.5 Update GetIt registration names in `lib/core/injection.dart`: `Page3DataSource` → `PlantIdentificationDataSource`, `Page3Repository` → `PlantIdentificationRepository`, `Page3Usecases` → `PlantIdentificationUsecases`
- [x] 7.6 Update localization strings: remove `page3Title`, add `plantIdentificationTitle` with "Plant ID" in both `l10n_en.arb` and `l10n_de.arb`
- [x] 7.7 Remove hardcoded placeholder data from old Page3
- [x] 7.8 Run `fvm flutter gen-l10n` to regenerate localization code
- [x] 7.9 Search codebase for remaining "page3", "Page3", "Page 3" references and remove/update them all

## 8. Validation

- [x] 8.1 Run `fvm flutter analyze` — fix all lint errors
- [x] 8.2 Run `fvm flutter test` — ensure existing tests pass
- [x] 8.3 Manual test: capture a photo of a plant and verify identification results appear with lattice animation
- [x] 8.4 Manual test: pick from gallery and verify identification works
- [x] 8.5 Manual test: verify error handling when camera permission is denied
