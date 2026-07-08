## ADDED Requirements

### Requirement: User can create a room
The system SHALL allow users to create a room with a name (required), light level (required), humidity level (required), and optional notes.

#### Scenario: Create room with all fields
- **WHEN** user taps "Add room" and provides name "Living Room", light level "Bright", humidity "Medium", and notes "South-facing window"
- **THEN** the system creates a room entity with all provided fields and persists it

#### Scenario: Create room with minimal fields
- **WHEN** user taps "Add room" and provides only a name "Kitchen"
- **THEN** the system creates a room with default light level "Medium", default humidity "Medium", and empty notes

### Requirement: User can edit a room
The system SHALL allow users to modify any field of an existing room.

#### Scenario: Edit room light level
- **WHEN** user opens room detail and changes light level from "Medium" to "Bright"
- **THEN** the system updates the room's light level and persists the change

#### Scenario: Edit room notes
- **WHEN** user opens room detail and adds notes "Added grow light in Jan 2026"
- **THEN** the system updates the room's notes and persists the change

### Requirement: User can delete a room
The system SHALL allow users to permanently remove a room from their collection.

#### Scenario: Delete room with no plants assigned
- **WHEN** user taps delete on a room with no plants assigned and confirms
- **THEN** the system removes the room from the collection

#### Scenario: Delete room with plants assigned
- **WHEN** user taps delete on a room that has plants assigned and confirms
- **THEN** the system removes the room, clears the roomId on all assigned plants, and shows a summary of affected plants

#### Scenario: Cancel delete
- **WHEN** user taps delete on a room and cancels the confirmation dialog
- **THEN** the system does not modify the room

### Requirement: System provides predefined room presets
The system SHALL offer common room presets (Bedroom, Kitchen, Bathroom, Living Room, Balcony, Office) with pre-filled environment attributes.

#### Scenario: Preset available during room creation
- **WHEN** user opens the room creation form
- **THEN** the system displays a list of presets that can be tapped to pre-fill the form fields

#### Scenario: Custom room ignores presets
- **WHEN** user fills in the room form manually without selecting a preset
- **THEN** the system creates the room with the manually entered values

### Requirement: Room names are unique
The system SHALL enforce unique room names and prevent duplicate entries.

#### Scenario: Duplicate name rejected
- **WHEN** user tries to create a room with name "Kitchen" and a room named "Kitchen" already exists
- **THEN** the system displays an error message "A room with this name already exists" and does not create the room

#### Scenario: Edit preserves own name
- **WHEN** user edits the "Kitchen" room and saves without changing the name
- **THEN** the system allows the save (no false duplicate detection)

### Requirement: User can view list of rooms
The system SHALL display all rooms as a list showing name, light level badge, and humidity badge.

#### Scenario: Empty rooms list shows placeholder
- **WHEN** user navigates to rooms page and there are no rooms
- **THEN** the system displays an empty-state message "No rooms yet" with a button to add the first room

#### Scenario: Rooms list shows all rooms
- **WHEN** user navigates to rooms page and rooms exist
- **THEN** the system displays a list with each room's name, light level badge, and humidity badge
