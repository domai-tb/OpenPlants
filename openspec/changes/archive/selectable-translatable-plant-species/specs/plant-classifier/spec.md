## MODIFIED Requirements

### Requirement: Top-k label mapping
The system SHALL map the top-k highest-probability model indices to stable species IDs through the shared species catalog, then expose localized display names at presentation time.

#### Scenario: Top-5 results returned
- **WHEN** classification completes successfully
- **THEN** the system returns the 5 highest-confidence catalog species IDs with probabilities and display metadata

#### Scenario: Label lookup correctness
- **WHEN** the model output has highest logit at index 42
- **THEN** the top-1 result species ID SHALL match the catalog record mapped to model label index 42

#### Scenario: Unknown label index
- **WHEN** a model output index has no catalog mapping
- **THEN** the classifier returns a classified mapping error for that result rather than persisting an arbitrary text name

### Requirement: Label file loading
The system SHALL load the model label file and validate its indices against the shared species catalog at initialization. It SHALL return a descriptive initialization error when labels or catalog mapping cannot be parsed or aligned.

#### Scenario: Labels and catalog load successfully
- **WHEN** the classifier initializes
- **THEN** label indices SHALL resolve through the catalog mapping

#### Scenario: Missing labels file
- **WHEN** the model labels file cannot be found or parsed
- **THEN** the system returns an initialization error with a descriptive message

#### Scenario: Label/catalog mismatch
- **WHEN** labels contain an index absent from the catalog
- **THEN** the system returns a model-metadata mismatch error before presenting identification results
