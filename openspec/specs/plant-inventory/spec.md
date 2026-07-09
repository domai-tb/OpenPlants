## ADDED Requirements

### Requirement: User can view plant collection as a list
The system SHALL display all plants in the user's collection as a scrollable list showing name, species label (if set), room (if set), and care status indicator.

#### Scenario: Empty collection shows placeholder
- **WHEN** user navigates to the collection page and there are no plants
- **THEN** the system displays an empty-state message "No plants yet" with a button to add the first plant

#### Scenario: Collection shows all plants
- **WHEN** user navigates to the collection page and there are plants saved
- **THEN** the system displays a list with each plant's name, species label, room badge, and care status icon

### Requirement: Photo capture triggers auto-identification on add-plant form
When the user captures or selects a photo on the add-plant form, the system SHALL automatically run the plant identification pipeline on that photo. While identification runs, the system SHALL display a loading indicator on the photo. After identification completes, the results SHALL be shown as selectable options below the photo.

#### Scenario: Photo triggers identification
- **WHEN** the user captures a photo via camera on the add-plant form
- **THEN** the system SHALL display the captured photo and begin identification automatically

#### Scenario: Gallery photo triggers identification
- **WHEN** the user selects a photo from the gallery on the add-plant form
- **THEN** the system SHALL display the selected photo and begin identification automatically

#### Scenario: Loading state during identification
- **WHEN** identification is in progress on the add-plant form
- **THEN** the system SHALL show a loading indicator on or beside the photo

#### Scenario: Error during identification
- **WHEN** identification fails (model error, inference error)
- **THEN** the system SHALL display an error message and the user can still set species manually or leave it blank

### Requirement: User can add a plant
The system SHALL allow users to create a new plant entry with name (required), optional photo, optional species, optional room (selected from defined rooms), optional notes, initial care status (default: happy), and an empty photo timeline.

#### Scenario: Add plant with minimal info
- **WHEN** user taps "Add plant" and enters only a name
- **THEN** the system creates a plant with name as entered, default care status "happy", empty photo timeline, and all other fields empty

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
- **WHEN** user taps "Add plant", fills in name, and selects "Living Room" from the room picker dropdown
- **THEN** the system creates the plant with roomId referencing the "Living Room" entity

#### Scenario: Add plant with all optional fields
- **WHEN** user taps "Add plant" and provides name, photo, species, room selection, and notes
- **THEN** the system creates a plant with all provided fields persisted and the photo added to its timeline

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
The system SHALL allow users to permanently remove a plant from their collection, including all its growth photos.

#### Scenario: Delete plant with confirmation
- **WHEN** user taps delete on a plant and confirms the dialog
- **THEN** the system removes the plant from the collection and deletes all photo files from disk

#### Scenario: Cancel delete
- **WHEN** user taps delete on a plant and cancels the confirmation dialog
- **THEN** the system does not modify the plant, its photos, or any metadata

### Requirement: User can search plants by name
The system SHALL provide a search bar that filters the plant list by name substring match.

#### Scenario: Search by full name
- **WHEN** user types a plant's full name in the search bar
- **THEN** the system displays only that plant in the filtered list

#### Scenario: Search by partial name
- **WHEN** user types a partial substring of a plant's name
- **THEN** the system displays all plants whose names contain that substring

### Requirement: Plant entity references journal entries
The system SHALL associate each plant with its journal entries via a plant identifier reference.

#### Scenario: Journal entries linked to plant
- **WHEN** user creates a journal entry for a specific plant
- **THEN** the entry is stored with the plant's identifier and appears only in that plant's journal

#### Scenario: Delete plant removes journal entries
- **WHEN** user deletes a plant that has journal entries
- **THEN** the system removes all associated journal entries and their photo files from disk
