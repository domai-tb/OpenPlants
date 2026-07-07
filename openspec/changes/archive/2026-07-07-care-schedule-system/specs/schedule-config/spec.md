## ADDED Requirements

### Requirement: Each plant has a schedule configuration
The plant entity SHALL include a schedule configuration object that stores per-task-type interval overrides (in days, null = use species default), pot type, and an assigned species profile ID.

#### Scenario: New plant gets default schedule config
- **WHEN** a new plant is created
- **THEN** the system assigns a default schedule config with all interval overrides set to null and pot type set to "plastic"

#### Scenario: User overrides watering interval for one plant
- **WHEN** user edits a plant's schedule config and sets watering interval to 10 days
- **THEN** the engine uses 10 days as the user override for that plant's watering interval instead of the species default

#### Scenario: User clears override reverts to species default
- **WHEN** user clears a previously-set interval override
- **THEN** the engine falls back to the species default for that task type

### Requirement: Species defaults are configurable per species profile
The system SHALL maintain a set of species-care profiles, each defining default intervals (in days) for all 8 built-in task types plus optional monthly seasonal modifier tables.

#### Scenario: Species profile defines watering interval
- **WHEN** a plant is linked to a species profile with watering interval 7 days
- **THEN** the baseline watering interval for that plant is 7 days (before modifiers)

#### Scenario: Unknown species uses general default profile
- **WHEN** a plant has no species link or the species has no defined profile
- **THEN** the system uses a "general" profile with conservative baselines for all task types

### Requirement: Room attributes are stored and editable
The system SHALL allow users to define room-level attributes (sunlight, humidity, temperature) for rooms they assign to plants.

#### Scenario: User sets room with full sun
- **WHEN** user configures a room named "Living Room" with sunlight level "full sun"
- **THEN** the system persists the room config and the engine applies the high-light modifier

#### Scenario: Room without config uses neutral modifiers
- **WHEN** a plant references a room that has no room config
- **THEN** the engine uses neutral (1.0×) room modifiers

#### Scenario: User edits room attributes
- **WHEN** user changes a room's humidity from "high" to "medium"
- **THEN** the engine uses the updated value on the next schedule computation

### Requirement: Pot type is stored per plant
The system SHALL support three pot types: `terracotta`, `plastic`, and `self-watering`.

#### Scenario: Default pot type is plastic
- **WHEN** a new plant is created without specifying a pot type
- **THEN** the pot type defaults to `plastic`

#### Scenario: User changes pot type
- **WHEN** user edits a plant and changes its pot type to `terracotta`
- **THEN** the engine applies the terracotta modifier to the watering interval

### Requirement: Custom task types can be defined
The system SHALL allow users to define custom task types (name + interval in days) that are included in schedule computation for all plants or per-plant.

#### Scenario: Global custom task type applies to all plants
- **WHEN** user creates a custom task type "Check for flowers" with interval 7 days
- **THEN** the engine includes this task for every plant in the collection
