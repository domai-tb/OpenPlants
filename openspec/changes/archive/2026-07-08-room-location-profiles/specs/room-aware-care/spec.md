## ADDED Requirements

### Requirement: Care recommendations factor in room environment
The system SHALL adjust care task intervals based on the assigned room's light level and humidity attributes.

#### Scenario: High-light room increases watering frequency
- **WHEN** a plant is assigned to a room with light level "Direct Sun" and base watering interval is 7 days
- **THEN** the recommended watering interval is approximately 5 days (0.7× multiplier)

#### Scenario: Low-light room decreases watering frequency
- **WHEN** a plant is assigned to a room with light level "Low" and base watering interval is 7 days
- **THEN** the recommended watering interval is approximately 9 days (1.3× multiplier)

#### Scenario: High-humidity room reduces misting frequency
- **WHEN** a plant is assigned to a room with humidity "High" and base misting interval is 3 days
- **THEN** the recommended misting interval is approximately 5 days (1.5× multiplier)

#### Scenario: Low-humidity room increases misting frequency
- **WHEN** a plant is assigned to a room with humidity "Low" and base misting interval is 3 days
- **THEN** the recommended misting interval is approximately 2 days (0.7× multiplier)

### Requirement: Unassigned plants use baseline care
The system SHALL use standard care intervals (no room modifier) for plants without a room assignment.

#### Scenario: No room assigned uses 1.0× multiplier
- **WHEN** a plant has no roomId assigned
- **THEN** the care schedule engine applies 1.0× for all room-based factors

### Requirement: Room environment displayed on care cards
The system SHALL display the room name and its environment summary on care task cards when a room is assigned.

#### Scenario: Care card shows room context
- **WHEN** a plant has a room assigned and care tasks are displayed
- **THEN** each care card shows the room name and a brief environment summary (e.g., "Living Room — Bright, Medium humidity")

#### Scenario: Care card omits room when unassigned
- **WHEN** a plant has no room assigned
- **THEN** care cards do not display any room information
