## MODIFIED Requirements

### Requirement: Plant has a care status
Every plant SHALL have a care status field with three allowed values: `happy`, `needs_water`, `needs_fertilizer`. The default value on creation is `happy`. Symptom entries with severity `severe` SHALL automatically update the care status to `needs_attention` when the plant is currently `happy`.

#### Scenario: New plant defaults to happy
- **WHEN** user creates a new plant
- **THEN** the plant's care status is `happy`

#### Scenario: User changes care status
- **WHEN** user edits a plant and changes the care status
- **THEN** the system persists the new care status

#### Scenario: Care status is displayed on list
- **WHEN** the collection list renders a plant
- **THEN** the list shows a visual indicator of the plant's care status (e.g., colored dot or icon)

#### Scenario: Severe symptom updates care status
- **WHEN** user logs a symptom with severity `severe` for a plant with care status `happy`
- **THEN** the system updates the plant's care status to `needs_attention`
