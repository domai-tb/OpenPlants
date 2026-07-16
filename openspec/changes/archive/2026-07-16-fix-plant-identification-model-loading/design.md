## Context

The plant identification feature uses an ONNX model for classification. The model loading pipeline copies assets to a cache directory with identity-based invalidation. Currently, the code references `model_identity.json` but the actual metadata file is `onnx_export_info.json`.

Current asset structure:
- `model.onnx` - ONNX model graph
- `model.onnx.data` - External model data
- `onnx_export_info.json` - Model metadata (source model, input/output specs)
- `config.json` - Model architecture config with id2label mapping
- `labels.json` - Class labels
- `preprocessor_config.json` - Image preprocessing config

## Goals / Non-Goals

**Goals:**
- Fix model loading by updating asset references to use correct filenames
- Maintain cache invalidation behavior using `onnx_export_info.json` as identity
- Update all related tests

**Non-Goals:**
- Change model architecture or preprocessing
- Add new features to plant identification
- Refactor the caching mechanism

## Decisions

1. **Use `onnx_export_info.json` as identity file**
   - Rationale: Contains unique model metadata (source model, opset, input/output shapes) suitable for cache invalidation
   - Alternative: Create a new `model_identity.json` file - rejected because user stated no other files are allowed

2. **Update string constants in code**
   - Rationale: Simple, localized change with minimal risk
   - Alternative: Make identity path configurable - overkill for this fix

## Risks / Trade-offs

- **Risk**: Tests may need additional updates if they mock the identity file
  - **Mitigation**: Update all test references to use correct filename

- **Risk**: Cache invalidation may behave differently if `onnx_export_info.json` content changes
  - **Mitigation**: Review `onnx_export_info.json` structure to ensure it contains stable identity info
