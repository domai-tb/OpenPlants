## MODIFIED Requirements

### Requirement: ONNX session lifecycle
The system SHALL create a single ONNX Runtime session from the installed model package on first use and reuse it for all subsequent inference calls. The session SHALL be disposed when the plant identification feature is no longer needed and closed before its package is replaced or removed.

#### Scenario: Session initialization on first inference
- **WHEN** the classifier receives its first inference request and a model is installed
- **THEN** it loads the installed `model.onnx` and its adjacent external data into an ONNX Runtime session and stores it for reuse

#### Scenario: Session reuse on subsequent inference
- **WHEN** the classifier receives another inference request after a session already exists
- **THEN** it reuses the existing session without creating a new one

#### Scenario: Session disposal
- **WHEN** the classifier is disposed or the active package is about to change
- **THEN** the ONNX Runtime session and all associated native resources are released

#### Scenario: No model is installed
- **WHEN** the classifier receives an inference request without an installed model
- **THEN** it returns a classified model-not-installed error without attempting to load Flutter assets

### Requirement: Label file loading
The system SHALL load `labels.json` from the same installed model package as the ONNX graph and maintain a map from string indices to Latin species names.

#### Scenario: Labels loaded from installed package
- **WHEN** the classifier initializes with an installed model
- **THEN** the matching `labels.json` is decoded and available for index-to-name lookup

#### Scenario: Labels loaded from asset
- **WHEN** the classifier migrates a compatible legacy cached model
- **THEN** the bundled `labels.json` is copied into the installed package and decoded for index-to-name lookup

#### Scenario: Missing labels file
- **WHEN** `labels.json` cannot be found or parsed in the installed package
- **THEN** the system returns an initialization error with a descriptive message

## REMOVED Requirements

### Requirement: Cached ONNX assets match bundled model identity
**Reason**: There is no longer a bundled model whose identity invalidates an OS cache.
**Migration**: Import and validate a complete package as specified by `plant-model-management`.

## ADDED Requirements

### Requirement: Classifier package files stay paired
The classifier SHALL use the model graph, external data, metadata, and labels from one active installation. It SHALL NOT combine a model graph from one package with labels from another package.

#### Scenario: Package is replaced
- **WHEN** the active package is replaced
- **THEN** the classifier closes the old session and uses the graph and labels from the new package on the next inference

#### Scenario: Package files are incomplete
- **WHEN** a required installed package file is missing or empty
- **THEN** the classifier returns a model-loading error and does not create a session from a partial package
