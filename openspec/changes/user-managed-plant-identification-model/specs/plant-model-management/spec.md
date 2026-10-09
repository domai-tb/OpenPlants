## ADDED Requirements

### Requirement: Model package is distributed separately from the app
The system SHALL define one flat ZIP package containing `model.onnx`, `model.onnx.data`, `labels.json`, and `onnx_export_info.json`. The release process SHALL generate the package from the pinned model export and publish it separately from the Android app package. The Android app SHALL NOT bundle the ONNX graph or external model data.

#### Scenario: Release package is generated
- **WHEN** maintainers prepare a model package release
- **THEN** the exporter creates a ZIP with the four required root-level files and records the source model revision
- **AND** the ZIP is available as a separate release artifact for publication to the official Hugging Face model repository

#### Scenario: App package is built without model weights
- **WHEN** the Android app is built from a clean checkout
- **THEN** the app build does not need to run the ONNX export
- **AND** the APK does not contain `model.onnx` or `model.onnx.data`

### Requirement: Model archive is imported locally
The system SHALL let the user select a local model ZIP through the Android system document picker. Import and inference SHALL work without network access in the app process.

#### Scenario: User imports a downloaded archive
- **WHEN** the user selects a supported model ZIP from device storage
- **THEN** the app imports it into app-private persistent storage
- **AND** the user can use identification without the app downloading model files

#### Scenario: User cancels archive selection
- **WHEN** the system document picker is cancelled
- **THEN** the current model state remains unchanged
- **AND** onboarding and plant-care features remain usable

#### Scenario: User opens the model download action
- **WHEN** the user chooses to download the model from the app
- **THEN** the app opens the official Hugging Face archive location in the external browser
- **AND** the app itself does not request or transfer model bytes

### Requirement: Imported archives are validated before activation
The system SHALL stream only the required flat archive entries into a staging directory and reject unsafe, corrupt, incomplete, oversized, or incompatible packages before changing the installed model.

#### Scenario: Package has a missing or unexpected entry
- **WHEN** a selected ZIP omits a required file or contains a duplicate, nested, encrypted, path-traversal, or unexpected entry
- **THEN** the import fails with a user-visible error
- **AND** the existing installed model remains available

#### Scenario: Package has incompatible metadata or labels
- **WHEN** `onnx_export_info.json` does not identify a supported model and input/output contract, or the label count does not match the output shape
- **THEN** the package is rejected before activation
- **AND** the existing installed model remains unchanged

#### Scenario: Package is corrupt or cannot be written
- **WHEN** archive integrity, ONNX session creation, disk capacity, or final activation fails
- **THEN** the app reports the import failure and cleans up temporary state
- **AND** the existing installed model remains unchanged

### Requirement: Model installation is durable and manageable
The system SHALL store the active model package in app-private persistent storage and expose its installed state, source revision, replacement, and removal through Model Information. Removing a model SHALL delete only its dedicated model files.

#### Scenario: Model is installed
- **WHEN** all required files are valid and the staged model session can be created
- **THEN** the app activates the package as one installation
- **AND** subsequent classifier sessions use its graph, external data, and matching labels

#### Scenario: Model is replaced or removed
- **WHEN** the user replaces or removes an installed model
- **THEN** the current ONNX session is closed before its files change
- **AND** a later inference either uses the replacement package or reports that no model is installed
- **AND** plant records and app settings are unchanged

#### Scenario: App is upgraded with a compatible legacy cache
- **WHEN** the app finds a complete legacy cache matching the supported bundled model identity
- **THEN** it migrates the cache and matching labels to persistent model storage

#### Scenario: No compatible model exists
- **WHEN** no installed package or migratable legacy cache is available
- **THEN** the app reports the model as absent without blocking other app features
