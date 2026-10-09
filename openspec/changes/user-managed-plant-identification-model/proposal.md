## Why

The ONNX weights currently add roughly 740 MB to the generated model files and are copied into the APK by the release export step. Every install pays that download cost, including users who never use plant identification. Users who do want identification can download the model archive themselves and import it, keeping model transfer outside the app and preserving local, offline inference.

The onboarding flow can offer model setup without making it a requirement. Users who skip it must still be able to reach model setup later from plant identification and the existing Model Information page.

## What Changes

- Stop bundling the ONNX graph and external data in the application package. Keep the model labels small and available for migration of the current bundled-model cache.
- Define a single ZIP package containing `model.onnx`, `model.onnx.data`, `labels.json`, and `onnx_export_info.json`; generate it from the existing pinned Hugging Face export.
- Import the ZIP with Android's document picker into durable app-private storage. Validate its contents and compatibility, and keep any currently installed model intact if import fails.
- Generate the ZIP as a separate release artifact and publish it in the OpenPlants Hugging Face model repository. The app opens that location in the external browser; it does not fetch model bytes or need network access to import or run the model.
- Add an optional model setup step to onboarding, a missing-model action in plant identification, and import/replace/remove controls in Model Information.
- Preserve a compatible model already cached by the current app when upgrading; otherwise show setup instead of failing during identification.

## Capabilities

### New Capabilities

- `plant-model-management`: model package format, offline import, safe installation, lifecycle, and separate model distribution.

### Modified Capabilities

- `plant-identification-model-loading`: replace asset copying and bundle-identity invalidation with user-installed model files.
- `plant-classifier`: create sessions from the installed package and load its matching labels.
- `model-info-display`: show installation state and model actions alongside model details.
- `identification-ui`: provide model setup when identification is unavailable.
- `local-privacy-onboarding`: add a skippable model setup step.
- `fdroid-distribution`: keep app builds independent from ONNX export and include the model ZIP as a separate release artifact.

## Impact

- Classifier loading, label loading, model storage, and the existing model info data source/use case/page.
- Onboarding and plant identification states; localized English and German copy.
- `pubspec.yaml` assets, the model export script, the tagged release workflow, and maintainer instructions for publishing the model ZIP to Hugging Face.
- Model import tests and existing model cache tests. App data such as plant records and settings is not part of model replacement or removal.
