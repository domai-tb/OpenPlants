## MODIFIED Requirements

### Requirement: User can add a plant
The system SHALL allow users to create a new plant entry with name (required), optional photo, optional species, optional room (selected from defined rooms), optional notes, and initial care status (default: happy).

#### Scenario: Add plant with minimal info
- **WHEN** user taps "Add plant" and enters only a name
- **THEN** the system creates a plant with name as entered, default care status "happy", and all other fields empty

#### Scenario: Add plant with photo from gallery
- **WHEN** user taps "Add plant", fills in name, and picks a photo from the gallery
- **THEN** the system saves the photo to local storage and creates the plant with the photo linked

#### Scenario: Add plant with species from classifier
- **WHEN** user taps "Add plant" and selects "Link from species ID" with a species identifier
- **THEN** the system stores the species reference on the plant entity

#### Scenario: Add plant with room from picker
- **WHEN** user taps "Add plant", fills in name, and selects "Living Room" from the room picker dropdown
- **THEN** the system creates the plant with roomId referencing the "Living Room" entity

#### Scenario: Add plant with all optional fields
- **WHEN** user taps "Add plant" and provides name, photo, species, room selection, and notes
- **THEN** the system creates a plant with all provided fields persisted

## ADDED Requirements

### Requirement: User can filter plants by room
The system SHALL provide filter chips on the plant collection page to filter plants by assigned room.

#### Scenario: Filter by room shows only matching plants
- **WHEN** user taps the "Kitchen" filter chip on the collection page
- **THEN** the system displays only plants assigned to the "Kitchen" room

#### Scenario: Clear filter shows all plants
- **WHEN** user taps the "All" filter chip or deselects the active room filter
- **THEN** the system displays all plants in the collection

#### Scenario: Room filter chips reflect defined rooms
- **WHEN** user navigates to the collection page
- **THEN** the system displays filter chips for each defined room plus an "All" chip

### Requirement: Plant form shows room picker
The system SHALL display a dropdown picker in the plant form that lists all defined rooms, with an option to create a new room.

#### Scenario: Room picker shows existing rooms
- **WHEN** user opens the plant add/edit form and rooms exist
- **THEN** the system displays a dropdown with room names and a "+ New Room" trailing option

#### Scenario: Create room from plant form
- **WHEN** user taps "+ New Room" in the plant form's room picker
- **THEN** the system navigates to the room creation form, and upon creation returns to the plant form with the new room pre-selected

#### Scenario: No rooms defined shows empty state
- **WHEN** user opens the plant form and no rooms have been created
- **THEN** the system displays "No rooms defined" with a prompt to create one
