## ADDED Requirements

### Requirement: Plant has a care status
Every plant SHALL have a care status field with four allowed values: `happy`, `needs_water`, `needs_fertilizer`, `needs_attention`. The default value on creation is `happy`. Symptom entries with severity `severe` SHALL automatically update the care status to `needs_attention` when the plant's current status is not already `needs_attention`.

#### Scenario: New plant defaults to happy
- **WHEN** user creates a new plant
- **THEN** the plant's care status is `happy`

#### Scenario: User changes care status
- **WHEN** user edits a plant and changes the care status
- **THEN** the system persists the new care status

#### Scenario: Care status is displayed on list
- **WHEN** the collection list renders a plant
- **THEN** the list shows a visual indicator matching the plant's effective care status

#### Scenario: Severe symptom updates care status
- **WHEN** user logs a symptom with severity `severe` for a plant whose care status is not already `needs_attention`
- **THEN** the system updates the plant's care status to `needs_attention`

### Requirement: Plant has an effective care status
The system SHALL compute an effective care status for each plant that considers both the stored `careStatus` field and the `lastWateredAt` / `lastFertilizedAt` timestamps. The effective status is used for filtering and display. The stored `careStatus` field remains unchanged and serves as an explicit override.

The effective status SHALL be computed with this priority (first match wins):
1. If stored `careStatus` is `needsWater` or `needsFertilizer`, use that (explicit user override)
2. If `lastWateredAt` is `null`, effective status is `needsWater`
3. If `lastFertilizedAt` is `null`, effective status is `needsFertilizer`
4. Otherwise, effective status is the stored `careStatus`

#### Scenario: Effective status shows needs-water for never-watered plant
- **WHEN** a plant has stored `careStatus = happy` and `lastWateredAt = null`
- **THEN** the effective care status is `needsWater`

#### Scenario: Effective status shows needs-fertilizer for never-fertilized plant
- **WHEN** a plant has stored `careStatus = happy` and `lastFertilizedAt = null`
- **THEN** the effective care status is `needsFertilizer`

#### Scenario: Explicit care status overrides inferred status
- **WHEN** a plant has stored `careStatus = happy`, `lastWateredAt = null`, AND the user has also set `lastFertilizedAt = null`
- **THEN** the effective care status is `needsWater` (watering takes priority over fertilizing)

#### Scenario: Happy plant with both care events
- **WHEN** a plant has stored `careStatus = happy` and both `lastWateredAt` and `lastFertilizedAt` are non-null
- **THEN** the effective care status is `happy`

### Requirement: Plant tracks last-watered and last-fertilized dates
Each plant SHALL store optional `lastWateredAt` and `lastFertilizedAt` timestamps. Both default to null.

#### Scenario: Log watering
- **WHEN** user marks a plant as "just watered"
- **THEN** the system sets `lastWateredAt` to the current timestamp

#### Scenario: Log fertilizing
- **WHEN** user marks a plant as "just fertilized"
- **THEN** the system sets `lastFertilizedAt` to the current timestamp

#### Scenario: Watering resets care status
- **WHEN** user marks a plant as "just watered" and the plant's care status was `needs_water`
- **THEN** the system sets care status to `happy` and updates `lastWateredAt`

### Requirement: Collection page surfaces plants needing attention
The system SHALL indicate which plants need attention in the collection list view. A plant needs attention when its effective care status is `needsWater` or `needsFertilizer`.

#### Scenario: Filter by needs-water
- **WHEN** user taps a filter control for "Needs water"
- **THEN** the system displays only plants whose effective care status is `needsWater`

#### Scenario: Filter by needs-fertilizer
- **WHEN** user taps a filter control for "Needs fertilizer"
- **THEN** the system displays only plants whose effective care status is `needsFertilizer`
