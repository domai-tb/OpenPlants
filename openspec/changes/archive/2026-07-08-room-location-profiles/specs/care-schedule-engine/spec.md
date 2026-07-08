## MODIFIED Requirements

### Requirement: Engine applies room-context modifiers
The system SHALL modulate watering and misting intervals based on the assigned room's structured attributes (LightLevel enum, HumidityLevel enum) from the RoomEntity, if a room is assigned to the plant.

#### Scenario: High light increases watering frequency
- **WHEN** a plant is assigned to a room with light level `LightLevel.directSun` and the species has a high-light modifier
- **THEN** the effective watering interval is shorter than the base (0.7× multiplier)

#### Scenario: High humidity reduces watering frequency
- **WHEN** a plant is assigned to a room with humidity `HumidityLevel.high`
- **THEN** the effective watering interval is longer than the base (1.3× multiplier)

#### Scenario: Low humidity increases misting frequency
- **WHEN** a plant is assigned to a room with humidity `HumidityLevel.low`
- **THEN** the effective misting interval is shorter than the base (0.7× multiplier)

#### Scenario: Missing room config uses baseline
- **WHEN** a plant has no roomId assigned or the referenced room does not exist
- **THEN** the engine uses 1.0× (no modifier) for all room-based factors

#### Scenario: Room environment multiplied with seasonal modifier
- **WHEN** a plant is in a room with `LightLevel.bright` and the current month has a seasonal multiplier of 0.8×
- **THEN** the effective interval applies both multipliers (room × season) sequentially
