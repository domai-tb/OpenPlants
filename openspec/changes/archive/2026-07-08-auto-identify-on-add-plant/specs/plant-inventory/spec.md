## ADDED Requirements

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

## MODIFIED Requirements

### Requirement: User can add a plant
The system SHALL allow users to create a new plant entry with name (required), optional photo, optional species (set via identification picker or manually), optional room, optional notes, and initial care status (default: happy).

#### Scenario: Add plant with minimal info
- **WHEN** user taps "Add plant" and enters only a name
- **THEN** the system creates a plant with name as entered, default care status "happy", and all other fields empty

#### Scenario: Add plant with photo from gallery
- **WHEN** user taps "Add plant", fills in name, and picks a photo from the gallery
- **THEN** the system saves the photo to local storage, runs identification on the photo, displays results as selectable species options, and creates the plant with the photo linked

#### Scenario: Add plant with photo from camera
- **WHEN** user taps "Add plant", fills in name, and captures a photo with the camera
- **THEN** the system saves the photo to local storage, runs identification on the photo, displays results as selectable species options, and creates the plant with the photo linked

#### Scenario: Add plant with species selected from identification results
- **WHEN** identification results are shown and the user taps one of the result cards
- **THEN** the system sets that species on the plant and the species field shows the selected species name

#### Scenario: Add plant with manually entered species after identification
- **WHEN** identification results are shown and the user types a species name manually instead of tapping a result
- **THEN** the system uses the manually entered species instead of the identification result

#### Scenario: Add plant with all optional fields
- **WHEN** user taps "Add plant" and provides name, photo (with auto-identification), selected species, room assignment, and notes
- **THEN** the system creates a plant with all provided fields persisted
