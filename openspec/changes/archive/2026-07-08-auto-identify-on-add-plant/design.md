## Context

The add-plant form (`PlantCollectionPage`) and the plant identification feature (`PlantIdentificationPage`) currently exist as separate, disconnected flows. The user must either:

1. Manually search for a species on the add-plant form, or
2. Use the separate identification page, note the result, then go back to add-plant and type it in.

This creates friction in the core "add a plant" workflow. The ONNX classifier pipeline, camera/gallery services, and species library are all fully implemented and tested — what's missing is the integration between them.

The existing codebase already provides:
- `PlantClassifier` + `ImagePreprocessor` + postprocessing — end-to-end ONNX pipeline
- `ImageCaptureService` — camera capture and gallery picker
- `PlantCollectionUsecases` — add/edit/delete plant logic
- `PlantCollectionDatasource` — local storage for plants
- `SpeciesLibraryUsecases` — species lookup by scientific name

## Goals / Non-Goals

**Goals:**
- When the user adds a plant and captures/selects a photo, the identification pipeline runs automatically on that photo
- The identification results are displayed as a tappable picker inline within the add-plant form
- Tapping a result sets the species on the plant being added
- A manual entry option lets the user type a custom species name if the correct one isn't in results
- The user can skip identification entirely and add a plant without species
- Reuse the existing ONNX classifier pipeline without modification

**Non-Goals:**
- Changing the standalone Plant Identification page (its existing capture + results flow is untouched)
- Modifying the ONNX classifier, image preprocessor, or postprocessor
- Adding new external dependencies
- Changing the plant entity data model
- Multi-photo identification or batch operations

## Decisions

### Decision 1: Inline identification picker within add-plant form (not a separate page)
**Rationale**: Keeping the user in the add-plant flow avoids context switching and data loss. A bottom sheet or inline section within the form is more natural than navigating to a separate identification page and back. The existing `PlantIdentificationPage` remains as a standalone feature for users who want to identify a plant without adding it.

**Alternatives considered**:
- *Navigate to identification page, then return with result* — adds navigation complexity, risks losing form state, and takes the user out of context.
- *Separate bottom sheet dialog* — viable but adds a new widget hierarchy; inline section is simpler and keeps all state in one place.

### Decision 2: Reuse `PlantClassifierUsecases` directly
**Rationale**: The identification usecases (`services.plantIdentification`) already provide a clean `identifyPlant(Image)` → `List<ClassificationResult>` contract. No new ONNX session management or preprocessing code is needed. The add-plant form simply calls this method after photo capture.

**Alternatives considered**:
- *Wrap in a new bridge usecase* — unnecessary indirection since the existing API already returns what we need.

### Decision 3: State machine in the add-plant form for photo → identification → selection
**Rationale**: The add-plant form gains additional states (photo captured → identifying → results displayed → species picked). A simple enum-based state machine in the form's `State` keeps the transitions explicit and avoids global state.

States:
```
idle → photo_captured → identifying → results_shown → species_picked
                         → error (retry or ignore)
```

**Alternatives considered**:
- *Bloc/Cubit* — overkill for a single form flow; the existing pattern uses StatefulWidget direct state.
- *Separate controller class* — adds unnecessary abstraction for a linear flow.

### Decision 4: Tappable variant of `SpeciesResultCard` with a "select" action
**Rationale**: The existing `SpeciesResultCard` widget already displays species name and confidence. Adding an `onTap` callback and a visual "select" affordance (e.g., radio indicator or highlight on tap) minimizes new widget code. A manual-entry text field at the bottom of the result list provides the custom-species escape hatch.

**Alternatives considered**:
- *New dedicated picker widget* — duplication of the existing card UI.
- *Dropdown/selector* — doesn't convey confidence scores as well as the card layout.

## Risks / Trade-offs

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| User captures photo but doesn't want identification | Low | Results are suggestions only — user can ignore them and type a custom species, or leave species blank |
| ONNX inference is slow on low-end devices | Medium | The existing green-dot animation provides visual feedback; results appear incrementally (top-5 is fast) |
| User takes a photo of something that isn't a plant | Low | Classifier returns low-confidence results; user can always type their own species or skip |
| Identification runs unnecessarily when user already knows the species | Medium | User can set species manually first; photo is optional in the add-plant flow |
