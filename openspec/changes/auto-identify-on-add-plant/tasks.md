## 1. Identification Picker Widget

- [ ] 1.1 Add `onTap` callback and selected state to `SpeciesResultCard` — make the card respond to taps with a visual selection indicator (radio button or highlight border), defaulting to current non-interactive behavior
- [ ] 1.2 Create `IdentificationPicker` widget that accepts `List<SpeciesPrediction>`, displays them as tappable `SpeciesResultCard`s with radio-button selection, includes a "Enter manually" text field at the bottom, and exposes `onSelected(String speciesName)` callback

## 2. Add-Plant Form State Management

- [ ] 2.1 Add identification state enum (`Idle`, `PhotoCaptured`, `Identifying`, `ResultsShown`, `Error`) and fields (`_photoIdentificationState`, `_identificationResults`, `_identificationError`) to `_PlantCollectionFormPageState`
- [ ] 2.2 Add `_cameraOrGalleryPicker()` method that shows a bottom sheet with camera and gallery options (replacing the current gallery-only `_pickPhoto`)

## 3. Photo → Identification Pipeline

- [ ] 3.1 Add `_runIdentification()` async method to `_PlantCollectionFormPageState` that reads photo bytes, calls `services.plantIdentification.classifyImage()`, converts `ClassificationResult.topK(5)` to state, and handles errors
- [ ] 3.2 Wire `_runIdentification()` into the photo selection flow — after user picks/captures a photo, transition to `Identifying` state, run classification, display `IdentificationPicker` in `ResultsShown` state below the photo

## 4. Species Selection → Form Integration

- [ ] 4.1 Wire the `IdentificationPicker.onSelected` callback to set `_speciesController.text` and collapse the picker to a "Species: X" summary label with a "Change" option
- [ ] 4.2 Add a "Skip identification / enter manually" option that clears the picker and lets the user type directly in the species field

## 5. Tests

- [ ] 5.1 Write unit test for `IdentificationPicker` widget: verify results render, tap triggers callback, manual entry works, empty results show manual-only mode
- [ ] 5.2 Write widget test for add-plant form: verify photo selection triggers identification state, results display replaces species field, species selected from picker fills the species field, save creates plant with selected species
