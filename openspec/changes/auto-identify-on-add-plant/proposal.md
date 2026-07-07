## Why

When a user adds a new plant to their collection and uploads a photo, the identification process should run automatically — using the existing ONNX classifier — so the user can pick a species from the results instead of manually searching for it. Today the add-plant form and the identification feature are disconnected: the user must identify separately, then manually enter or search for the species on the add form. This creates a friction point in the core "add a plant" flow.

## What Changes

- **Add-plant form triggers camera capture → identification pipeline** — when the user taps the photo button on the add-plant form, they enter the existing camera/gallery capture flow, and the classifier auto-runs on the captured image.
- **Interactive species selection from identification results** — after classification, the user sees the top-5 results in a picker UI and can tap one to set the species, or type a custom species name if the correct one isn't in the results.
- **Identification results are shown inline** in the add-plant form (not as a separate page), so the user stays in context.
- **No changes to the ONNX classifier pipeline** — the existing `PlantClassifier`, `ImagePreprocessor`, and postprocessing remain untouched.
- **Delta specs** for `plant-inventory` (add-plant flow changes) and `identification-ui` (inline picker mode, species-selection interaction).

## Capabilities

### New Capabilities

*(None — all capabilities already exist as specs.)*

### Modified Capabilities

- `plant-inventory`: The "Add plant" flow gains a photo-driven species identification step. When the user selects a photo (camera or gallery), the identification pipeline runs automatically on that photo. Results are shown as a picker where the user taps a species to assign it, or types a custom label. The existing minimal add, gallery-only add, and manual-species scenarios still work — this adds a new path where a photo triggers auto-identification.
- `identification-ui`: The identification results display gains an interactive "species picker" mode. In this mode, each result card is tappable and tapping it selects that species and returns to the calling form. A "manual entry" option lets the user type their own species name. The existing standalone identification page mode remains unchanged.

## Impact

- **Files modified**: `lib/pages/plant_collection/` — the add-plant form (likely the page and usecases), plus possibly a new widget or state to embed the identification results inline.
- **Files created**: Possibly a shared identification picker widget or a bridge usecase that connects the add-plant form to the identification pipeline.
- **No new dependencies** — the ONNX pipeline, camera/gallery services, and species library are all already in place.
- **No breaking changes** — existing identification page and standalone classifier remain functional.
