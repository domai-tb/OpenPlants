## MODIFIED Requirements

### Requirement: User can add a plant
The system SHALL allow users to create a new plant entry with name (required), optional photo, optional species, optional room (selected from defined rooms), optional notes, initial care status (default: happy), and an empty photo timeline. When the initial care status is `happy`, the system SHALL set `lastWateredAt` and `lastFertilizedAt` to the creation timestamp so the effective care status reflects the user's explicit choice.

#### Scenario: Add plant with minimal info
- **WHEN** user taps "Add plant" and enters only a name
- **THEN** the system creates a plant with name as entered, default care status "happy", `lastWateredAt` and `lastFertilizedAt` set to creation time, empty photo timeline, and all other fields empty

#### Scenario: Add plant with photo from gallery
- **WHEN** user taps "Add plant", fills in name, and picks a photo from the gallery
- **THEN** the system saves the photo to local storage, runs identification on the photo, displays results as selectable species options, and creates the plant with the photo linked as the first entry in its photo timeline

#### Scenario: Add plant with photo from camera
- **WHEN** user taps "Add plant", fills in name, and captures a photo with the camera
- **THEN** the system saves the photo to local storage, runs identification on the photo, displays results as selectable species options, and creates the plant with the photo linked as the first entry in its photo timeline

#### Scenario: Add plant with species selected from identification results
- **WHEN** identification results are shown and the user taps one of the result cards
- **THEN** the system sets that species on the plant and the species field shows the selected species name

#### Scenario: Add plant with manually entered species after identification
- **WHEN** identification results are shown and the user types a species name manually instead of tapping a result
- **THEN** the system uses the manually entered species instead of the identification result

#### Scenario: Add plant with room from picker
- **WHEN** user taps "Add plant", fills in name, and selects a room from the room picker dropdown
- **THEN** the system creates the plant with roomId referencing that room entity

#### Scenario: Add plant with all optional fields
- **WHEN** user taps "Add plant" and provides name, photo, species, room selection, and notes
- **THEN** the system creates a plant with all provided fields persisted and the photo added to its timeline

#### Scenario: Add plant with needs-water status
- **WHEN** user taps "Add plant", selects "Needs Water" care status, and saves
- **THEN** the system creates the plant with care status "needsWater" and `lastWateredAt` and `lastFertilizedAt` remain null

#### Scenario: Add plant with needs-fertilizer status
- **WHEN** user taps "Add plant", selects "Needs Fertilizer" care status, and saves
- **THEN** the system creates the plant with care status "needsFertilizer" and `lastWateredAt` and `lastFertilizedAt` remain null
