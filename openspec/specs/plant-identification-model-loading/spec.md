## Purpose

Fix the model loading pipeline to use correct asset filenames for plant identification.

## Requirements

### Requirement: Model assets use correct filenames
The system SHALL load plant identification model assets using the filenames that exist in the assets directory.

#### Scenario: Model loads successfully
- **WHEN** the plant identification feature is invoked
- **THEN** the system loads `model.onnx`, `model.onnx.data`, and `onnx_export_info.json` from `assets/ml/plant-identification/`

### Requirement: Identity-based cache invalidation
The system SHALL use `onnx_export_info.json` for cache invalidation checks.

#### Scenario: Cache valid when identity matches
- **WHEN** the cached identity file content matches the asset identity file content
- **THEN** the system uses the cached model files

#### Scenario: Cache invalidated when identity changes
- **WHEN** the cached identity file content differs from the asset identity file content
- **THEN** the system recopies all model assets to the cache directory

### Requirement: Tests use correct asset paths
The system tests SHALL reference the correct asset filenames.

#### Scenario: Test mocking succeeds
- **WHEN** tests mock the asset loader
- **THEN** tests use `onnx_export_info.json` as the identity asset path
