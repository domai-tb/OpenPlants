## ADDED Requirements

### Requirement: Model archive is a separate release artifact
The release workflow SHALL generate the ONNX model ZIP separately from the Android app build. Building the APK, including an F-Droid build, SHALL NOT require model export or bundle ONNX weights.

#### Scenario: Tagged release produces both artifacts
- **WHEN** a tagged release runs model export and app preflight
- **THEN** it uploads the unsigned APK and the model ZIP as separate artifacts
- **AND** the model ZIP records the pinned source revision and has a published checksum

#### Scenario: App is built without model export
- **WHEN** a clean source build creates the Android APK without running the model exporter
- **THEN** the APK build succeeds without model files in Flutter assets

#### Scenario: Maintainer publishes model package
- **WHEN** a maintainer publishes a generated model package to the official Hugging Face repository
- **THEN** its source revision and checksum are recorded with the published package
