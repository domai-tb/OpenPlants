## Why

Plant identification feature fails at startup because the code references `model_identity.json` which doesn't exist in the assets directory. The actual metadata file is `onnx_export_info.json`. This prevents the ONNX model from being cached and loaded, breaking the entire plant identification feature.

## What Changes

- Update `plant_classifier.dart` to reference `onnx_export_info.json` instead of `model_identity.json`
- Update `model_asset_cache.dart` to use the correct identity file name
- Update test files to use the correct asset path

## Capabilities

### New Capabilities

- `plant-identification-model-loading`: Fix the model loading pipeline to use correct asset filenames

### Modified Capabilities

(none - this is a bug fix, not a requirement change)

## Impact

- **Code**: `lib/pages/plant_identification/classifier/plant_classifier.dart`, `lib/pages/plant_identification/classifier/model_asset_cache.dart`
- **Tests**: `test/plant_classifier_cache_test.dart`
- **Dependencies**: None
- **Breaking Changes**: None
