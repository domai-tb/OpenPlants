## ADDED Requirements

### Requirement: Plant detail submenu provides metric navigation
The plant detail page SHALL include a localized "Metrics" destination in its action submenu. Selecting it SHALL open the Metrics page scoped to the displayed plant without adding a global navigation destination.

#### Scenario: Open metrics from plant detail
- **WHEN** user selects "Metrics" from a plant's detail submenu
- **THEN** the app opens that plant's metric summaries and no other plant's data

#### Scenario: Return from metrics
- **WHEN** user navigates back from the Metrics page
- **THEN** the app returns to the same plant detail page

### Requirement: Plant deletion removes metric-owned data
Confirmed plant deletion SHALL remove all metric definitions, measurements, linked measurement rules, and active metric alert state owned by that plant before removing the plant record. Cleanup SHALL be retry-safe when some metric-owned records are already absent.

#### Scenario: Delete plant with metric history
- **WHEN** user confirms deletion of a plant that has metric definitions and measurements
- **THEN** all metric-owned records are removed and no metric query or care schedule output references the deleted plant

#### Scenario: Retry partial metric cleanup
- **WHEN** plant deletion is retried after some metric-owned records were already removed
- **THEN** missing records are treated as already removed and remaining cleanup completes
