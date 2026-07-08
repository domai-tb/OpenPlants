## Why

Users interacting with the plant identification feature need transparency about the AI model powering it. Knowing which model is bundled, its capabilities, limitations, and licensing builds trust and supports informed use. This is especially important for a local-first app where the model runs on-device without server-side disclosures.

## What Changes

- Add a new "Model Info" page accessible from settings or the identification flow
- Display model metadata: name, version, license, input dimensions, label count, and confidence behavior
- Show clear limitations (e.g., "14,829 species", "224×224 input", "confidence thresholds are indicative")
- Provide a consistent pattern for future model updates to propagate metadata

## Capabilities

### New Capabilities
- `model-info-display`: Read-only page showing bundled ONNX model metadata, license, limitations, and confidence behavior

### Modified Capabilities
- (none — this is additive; no existing spec requirements change)

## Impact

- New page under `lib/pages/model_info/` following the 5-file feature pattern
- Model metadata sourced from `assets/ml/plant-identification/` (existing `model.onnx` + `labels.json`)
- May add a small metadata JSON (`model_meta.json`) to the asset bundle for version/license/limits
- Navigation entry added to settings or identification flow
- No API changes, no breaking changes
