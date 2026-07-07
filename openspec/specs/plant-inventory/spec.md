## ADDED Requirements

### Requirement: User can view plant collection as a list
The system SHALL display all plants in the user's collection as a scrollable list showing name, species label (if set), room (if set), and care status indicator.

#### Scenario: Empty collection shows placeholder
- **WHEN** user navigates to the collection page and there are no plants
- **THEN** the system displays an empty-state message "No plants yet" with a button to add the first plant

#### Scenario: Collection shows all plants
- **WHEN** user navigates to the collection page and there are plants saved
- **THEN** the system displays a list with each plant's name, species label, room badge, and care status icon

### Requirement: User can add a plant
The system SHALL allow users to create a new plant entry with name (required), optional photo, optional species, optional room, optional notes, and initial care status (default: happy).

#### Scenario: Add plant with minimal info
- **WHEN** user taps "Add plant" and enters only a name
- **THEN** the system creates a plant with name as entered, default care status "happy", and all other fields empty

#### Scenario: Add plant with photo from gallery
- **WHEN** user taps "Add plant", fills in name, and picks a photo from the gallery
- **THEN** the system saves the photo to local storage and creates the plant with the photo linked

#### Scenario: Add plant with species from classifier
- **WHEN** user taps "Add plant" and selects "Link from species ID" with a species identifier
- **THEN** the system stores the species reference on the plant entity

#### Scenario: Add plant with all optional fields
- **WHEN** user taps "Add plant" and provides name, photo, species, room assignment, and notes
- **THEN** the system creates a plant with all provided fields persisted

### Requirement: User can edit a plant
The system SHALL allow users to modify any field of an existing plant entry.

#### Scenario: Edit plant name
- **WHEN** user opens a plant detail and changes the name
- **THEN** the system updates the plant's name and persists the change

#### Scenario: Replace plant photo
- **WHEN** user opens a plant detail and picks a new photo
- **THEN** the system replaces the photo file on disk and updates the reference

#### Scenario: Remove plant photo
- **WHEN** user opens a plant detail and removes the existing photo
- **THEN** the system deletes the photo file from disk and clears the photo reference

### Requirement: User can delete a plant
The system SHALL allow users to permanently remove a plant from their collection.

#### Scenario: Delete plant with confirmation
- **WHEN** user taps delete on a plant and confirms the dialog
- **THEN** the system removes the plant from the collection and deletes its photo file from disk

#### Scenario: Cancel delete
- **WHEN** user taps delete on a plant and cancels the confirmation dialog
- **THEN** the system does not modify the plant or its photo

### Requirement: User can search plants by name
The system SHALL provide a search bar that filters the plant list by name substring match.

#### Scenario: Search by full name
- **WHEN** user types a plant's full name in the search bar
- **THEN** the system displays only that plant in the filtered list

#### Scenario: Search by partial name
- **WHEN** user types a partial substring of a plant's name
- **THEN** the system displays all plants whose names contain that substring
