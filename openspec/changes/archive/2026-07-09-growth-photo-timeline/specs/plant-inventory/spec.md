## MODIFIED Requirements

### Requirement: User can add a plant
The system SHALL allow users to create a new plant entry with name (required), optional photo, optional species, optional room, optional notes, initial care status (default: happy), and an empty photo timeline.

#### Scenario: Add plant with minimal info
- **WHEN** user taps "Add plant" and enters only a name
- **THEN** the system creates a plant with name as entered, default care status "happy", empty photo timeline, and all other fields empty

#### Scenario: Add plant with photo from gallery
- **WHEN** user taps "Add plant", fills in name, and picks a photo from the gallery
- **THEN** the system saves the photo to local storage and creates the plant with the photo linked as the first entry in its photo timeline

#### Scenario: Add plant with species from classifier
- **WHEN** user taps "Add plant" and selects "Link from species ID" with a species identifier
- **THEN** the system stores the species reference on the plant entity

#### Scenario: Add plant with all optional fields
- **WHEN** user taps "Add plant" and provides name, photo, species, room assignment, and notes
- **THEN** the system creates a plant with all provided fields persisted and the photo added to its timeline

### Requirement: User can delete a plant
The system SHALL allow users to permanently remove a plant from their collection, including all its growth photos.

#### Scenario: Delete plant with confirmation
- **WHEN** user taps delete on a plant and confirms the dialog
- **THEN** the system removes the plant from the collection and deletes all photo files from disk

#### Scenario: Cancel delete
- **WHEN** user taps delete on a plant and cancels the confirmation dialog
- **THEN** the system does not modify the plant, its photos, or any metadata
