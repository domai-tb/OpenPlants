## ADDED Requirements

### Requirement: Custom care rules can schedule metric measurements
The system SHALL allow a custom care rule to reference one enabled metric owned by the same plant. A linked rule SHALL retain its existing interval and enabled-state behavior and SHALL identify its generated care task as a measurement reminder for that metric.

#### Scenario: Create linked measurement rule
- **WHEN** user creates a seven-day custom care rule for a plant's "Water level" metric
- **THEN** the rule is persisted for that plant and generates a "Measure Water level" task at its interval

#### Scenario: Reject cross-plant metric reference
- **WHEN** user attempts to link a plant's care rule to a metric owned by another plant
- **THEN** the system rejects the rule without changing persisted rules

#### Scenario: Unlinked custom rule remains unchanged
- **WHEN** an existing custom care rule has no metric reference
- **THEN** it continues to schedule and complete as before

### Requirement: Measurement completion requirement is configurable
A metric-linked custom care rule SHALL let the user choose whether its due task requires recording a valid new measurement before completion. The setting SHALL default to required.

#### Scenario: Required measurement selected
- **WHEN** user saves a metric-linked rule without changing the completion requirement
- **THEN** its generated task requires a valid measurement before completion

#### Scenario: Optional measurement selected
- **WHEN** user configures a linked rule with optional measurement
- **THEN** its generated task can be completed with or without recording a new value
