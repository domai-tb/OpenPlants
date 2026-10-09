## Context

`PlantClassifier` currently gets three files from Flutter assets and `ModelAssetCache` copies them to the OS cache directory. `LabelsLoader` separately reads `labels.json` from the asset bundle. The release preflight runs `scripts/run_export.sh`, which writes all export output into the asset directory before building the APK. The current Hugging Face repository contains the source Safetensors checkpoint; it does not yet contain the app-ready ONNX ZIP.

The model graph and external data are about 742 MB uncompressed in the current export. The model remains optional: collection, care, and other app features must work without it.

## Goals

- Keep ONNX weights out of the APK and out of the app's network code.
- Let a user obtain one archive in a browser and import it later, including while offline.
- Install model files durably and safely, with a useful missing-model state and a way to replace or remove the package.
- Keep the ONNX files and their label map from the same export together.
- Preserve compatible existing cached installations where possible.

## Non-Goals

- No in-app HTTP download, background update check, automatic model update, or account/authentication flow.
- No alternate model formats or arbitrary ONNX model support.
- No change to plant-care functionality when the identification model is absent.

## Decisions

### 1. Use one flat, app-specific ZIP package

The ZIP contains exactly these root entries:

- `model.onnx`
- `model.onnx.data`
- `labels.json`
- `onnx_export_info.json`

The existing exporter already creates these runtime files from a pinned Hugging Face source revision. Package them together so model outputs cannot be separated from their matching labels. `config.json` and `preprocessor_config.json` are not runtime inputs in the current classifier and are not included. The small tracked `labels.json` remains in the APK only to support migration of the current bundled model cache; normal inference reads the installed package's copy.

### 2. Generate and publish the model archive separately from the APK

Change `scripts/run_export.sh` to write into a build/output directory outside Flutter assets and create the ZIP there. The tagged release workflow uploads it as a distinct artifact with the source revision and checksum. The maintainer publishes that versioned archive to the Hugging Face model repository at a stable download location. The APK build no longer runs the exporter or requires generated model files. This keeps F-Droid and other app builds independent of model export and avoids model weights in the APK.

### 3. Keep model transfer outside the app process

Download actions open the published Hugging Face archive in the system browser. Import uses Android's system document picker and accepts a locally available ZIP. The app does not make HTTP requests for model files, and cancellation or lack of connectivity never blocks onboarding or plant-care features.

### 4. Validate before replacing the installed model

Read the archive incrementally into a temporary directory under application support; do not buffer a 700+ MB archive or extract arbitrary paths. Accept only the required flat entries, reject duplicates, directories, unexpected entries, encrypted entries, path traversal, empty files, invalid JSON, and packages beyond the supported uncompressed-size limit. Validate the supported source model and inference contract in `onnx_export_info.json`, and require the label count to match the exported output shape. Open and close an ONNX Runtime session against the staged graph before activation so corrupt or incompatible packages do not replace a working installation.

Activate the fully written staging directory only after validation. If reading, validation, disk writing, or activation fails, remove temporary files, report the failure, and retain the previously installed model. Model removal deletes only the dedicated model directory. App records and settings are never touched. Surface storage failures without claiming that the import succeeded.

### 5. Store the active package in app-private persistent storage

Use application support storage rather than the OS cache, which can be purged. The classifier and Model Information use case read installation state and files from the same store. Replacing or removing a package closes the current ONNX session first; the next inference creates a session from the new installed path.

On upgrade, migrate the complete legacy cache only when its identity matches the supported bundled model and the matching labels are available. If no compatible complete cache exists, report the model as absent and show the import/download actions. Do not attempt to infer or delete user data during this migration.

### 6. Reuse Model Information for ongoing management

Add model status and import/replace/remove actions to the existing Model Information page under More > About. Plant identification links to that page when the model is absent. Onboarding gets a separate optional setup step with the same import action, a browser link, and an explicit skip path. This avoids a second model settings screen and makes the controls discoverable after onboarding.

### 7. Show an accurate state when the model is absent

Check installation before starting camera inference. When absent, show that local plant identification needs an imported model, with actions to open the external Hugging Face download page or pick an archive. After returning from the browser or picker, refresh status. When installed, show its source revision and keep replace/remove actions in Model Information.

## Risks and Trade-offs

- **Large archive and storage use:** the current unpacked export is about 742 MB, and safe replacement needs temporary space while the old model remains usable. Stream extraction, display the selected archive's expanded size before import where available, and preserve the old installation on insufficient storage.
- **Hugging Face package availability:** the source repository currently has Safetensors but not the app-ready ZIP. The model archive must be generated and published before the in-app link is useful.
- **Package authenticity:** structural checks detect corruption and incompatible exports but do not cryptographically prove who created a ZIP. The UI must point to the official OpenPlants Hugging Face repository and the manifest must show the source revision; do not describe this as signed verification.
- **Skipped onboarding:** users may enter the app without identification enabled. The Identify missing-model state and About > Model Information remain available as recovery paths.
- **Legacy installs:** users without a complete compatible cache need to import the model once after updating. No plant records or settings are affected.

## Migration Plan

1. Track the small labels asset and update the Flutter asset declaration so generated ONNX files cannot enter the APK.
2. Generate and publish a model ZIP from the current pinned source revision; retain the existing model archive in a compatible temporary migration path.
3. Ship the app with optional onboarding and persistent model management. Users with a compatible legacy cache keep identification; others can download/import later.
4. After the transition release, remove only migration code when no supported app version depends on it. Rollback restores bundled-model loading by reverting the app change; imported model files can remain app-private and unused.

## Open Questions

- None. The proposal assumes the app-specific ZIP will be published in the existing OpenPlants Hugging Face model repository and that the app will hand off downloads to the system browser.
