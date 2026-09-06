## MODIFIED Requirements

### Requirement: Custom care rules are stored per plant
The system SHALL maintain a list of custom care rules for each plant, where each rule defines a task type, interval in days, and optional reminder configuration. When a plant is created with a known species, the system SHALL auto-populate this list with species-derived preset rules. When a plant is created without a known species, the list SHALL start empty.

#### Scenario: New plant starts with no custom rules
- **WHEN** a new plant is created without a species name
- **THEN** the system assigns an empty list of custom care rules for that plant

#### Scenario: New plant with known species starts with preset rules
- **WHEN** a new plant is created with a species name matching a known species
- **THEN** the system assigns a list of preset care rules derived from that species' characteristics

#### Scenario: Rule is created for a plant
- **WHEN** user creates a custom care rule for plant "Monstera" with task type "Check for flowers" and interval 7 days
- **THEN** the rule is persisted and associated with that plant
