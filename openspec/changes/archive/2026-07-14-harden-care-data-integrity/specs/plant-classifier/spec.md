## ADDED Requirements

### Requirement: Cached ONNX assets match bundled model identity
The classifier SHALL treat `model.onnx`, `model.onnx.data`, and a bundled model identity as one cache unit. It SHALL create a session from cached files only when both files are non-empty and the installed identity equals the bundled identity.

#### Scenario: Matching cache is reused
- **WHEN** both cached model files are non-empty and the cached identity matches the bundled identity
- **THEN** the classifier reuses the cached files without copying bundled assets

#### Scenario: Legacy cache without identity is refreshed
- **WHEN** cached model files exist but no cached identity marker exists
- **THEN** the classifier refreshes both files from bundled assets before creating the session

#### Scenario: Updated bundled model invalidates cache
- **WHEN** the bundled identity differs from the cached identity
- **THEN** the classifier replaces both cached model files with the bundled pair
- **AND** writes the new identity only after both replacement files are valid

#### Scenario: Incomplete cache is refreshed
- **WHEN** either cached model file is missing or empty
- **THEN** the classifier refreshes both files before creating the session

#### Scenario: Interrupted refresh is recovered
- **WHEN** temporary files or model files exist without a matching identity after an interrupted refresh
- **THEN** the next initialization discards stale temporary state and refreshes the complete cache unit
