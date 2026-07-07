## ADDED Requirements

### Requirement: Plant has a care status
Every plant SHALL have a care status field with three allowed values: `happy`, `needs_water`, `needs_fertilizer`. The default value on creation is `happy`.

#### Scenario: New plant defaults to happy
- **WHEN** user creates a new plant
- **THEN** the plant's care status is `happy`

#### Scenario: User changes care status
- **WHEN** user edits a plant and changes the care status
- **THEN** the system persists the new care status

#### Scenario: Care status is displayed on list
- **WHEN** the collection list renders a plant
- **THEN** the list shows a visual indicator of the plant's care status (e.g., colored dot or icon)

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
The system SHALL indicate which plants have care status set to `needs_water` or `needs_fertilizer` in the collection list view.

#### Scenario: Filter by needs-water
- **WHEN** user taps a filter control for "Needs water"
- **THEN** the system displays only plants with care status `needs_water`

#### Scenario: Filter by needs-fertilizer
- **WHEN** user taps a filter control for "Needs fertilizer"
- **THEN** the system displays only plants with care status `needs_fertilizer`
