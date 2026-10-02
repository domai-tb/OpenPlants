## ADDED Requirements

### Requirement: Plant form shows species picker
The system SHALL display a searchable species picker in add and edit plant forms. The picker SHALL show localized names, scientific names, and bounded results from the bundled catalog.

#### Scenario: Open species picker
- **WHEN** the user taps the species field
- **THEN** the system displays a searchable picker backed by the offline species catalog

#### Scenario: Search species picker
- **WHEN** the user enters a search query
- **THEN** the picker displays matching localized common names, aliases, or scientific names without rendering the full catalog at once

#### Scenario: Identification failure still permits selection
- **WHEN** identification fails
- **THEN** the user can choose a species manually from the picker or leave species unset

## MODIFIED Requirements

### Requirement: User can add a plant
The system SHALL allow users to create a new plant entry with name (required), optional photo, optional species selected from the bundled species catalog, optional room (selected from defined rooms), optional notes, initial care status (default: happy), and an empty photo timeline.

#### Scenario: Add plant with minimal info
- **WHEN** user taps "Add plant" and enters only a name
- **THEN** the system creates a plant with name as entered, default care status "happy", empty photo timeline, and all other fields empty

#### Scenario: Add plant with photo from gallery
- **WHEN** user taps "Add plant", fills in name, and picks a photo from the gallery
- **THEN** the system saves the photo to local storage, runs identification on the photo, displays catalog species results as selectable options, and creates the plant with the photo linked as the first entry in its photo timeline

#### Scenario: Add plant with photo from camera
- **WHEN** user taps "Add plant", fills in name, and captures a photo with the camera
- **THEN** the system saves the photo to local storage, runs identification on the photo, displays catalog species results as selectable options, and creates the plant with the photo linked as the first entry in its photo timeline

#### Scenario: Add plant with species selected from picker
- **WHEN** user selects a catalog species in the species picker
- **THEN** the system persists its stable species ID and displays its localized name

#### Scenario: Add plant with species selected from identification results
- **WHEN** identification results are shown and the user taps one of the result cards
- **THEN** the system resolves the model label to a catalog species ID and sets that ID on the plant

#### Scenario: Add plant with room from picker
- **WHEN** user taps "Add plant", fills in name, and selects a room from the room picker dropdown
- **THEN** the system creates the plant with roomId referencing that room entity

#### Scenario: Add plant with all optional fields
- **WHEN** user taps "Add plant" and provides name, photo, species selection, room selection, and notes
- **THEN** the system creates a plant with all provided fields persisted and the photo added to its timeline
