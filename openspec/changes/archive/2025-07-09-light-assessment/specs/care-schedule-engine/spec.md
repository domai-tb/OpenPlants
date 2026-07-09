## MODIFIED Requirements

### Requirement: Engine applies room-context modifiers
The engine SHALL modulate watering and misting intervals based on room attributes (sunlight level, humidity, temperature) if room config exists for the plant's assigned room. When a plant has a user-set light level, the plant-level light assessment SHALL take precedence over the room's sunlight attribute for watering and misting modifiers.

#### Scenario: High light increases watering frequency
- **WHEN** a plant is in a room configured with "full sun" and the species has a high-light modifier
- **THEN** the effective watering interval is shorter than the base

#### Scenario: High humidity reduces watering frequency
- **WHEN** a plant is in a room configured with "high humidity"
- **THEN** the effective watering interval is longer than the base

#### Scenario: Missing room config uses baseline
- **WHEN** a plant has no room assigned or the room has no attributes configured
- **THEN** the engine uses 1.0× (no modifier) for all room-based factors

#### Scenario: Plant light level overrides room sunlight
- **WHEN** a plant has a user-set light level of `low` and is in a room configured with "full sun"
- **THEN** the engine uses the `low` light-level modifier for watering and misting, ignoring the room's sunlight attribute

#### Scenario: Null plant light level falls back to room sunlight
- **WHEN** a plant has no light level set (`null`) and is in a room with sunlight configured
- **THEN** the engine uses the room's sunlight attribute as the light modifier (existing behavior)
