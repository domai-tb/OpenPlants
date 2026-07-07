## ADDED Requirements

### Requirement: Plant data persists locally via SharedPreferences
The system SHALL store all plant metadata (name, species, room, notes, care status, timestamps, photo path, UUID) as a JSON-serialized list under a dedicated `shared_preferences` key (`plant_collection_v1`), separate from the app settings key.

#### Scenario: Save on add or edit
- **WHEN** user adds or edits a plant
- **THEN** the system serializes the full plant list to JSON and writes it to `shared_preferences` within 500 ms

#### Scenario: Load on startup
- **WHEN** the app starts and the collection page initializes
- **THEN** the system reads the JSON blob from `shared_preferences`, deserializes it, and provides it as the current plant list

#### Scenario: Empty prefs key returns empty list
- **WHEN** no `plant_collection_v1` key exists in shared_preferences
- **THEN** the system returns an empty plant list without error

### Requirement: Plant photos persist on local filesystem
The system SHALL store plant photos as individual files in the app's documents directory under a `plant_photos/` subdirectory. The entity stores only the absolute file path.

#### Scenario: Photo saved on add
- **WHEN** user picks a photo for a new plant
- **THEN** the system copies the image file to `{documentsDir}/plant_photos/{uuid}.jpg` and stores the path on the entity

#### Scenario: Photo replaced on edit
- **WHEN** user replaces a plant's photo
- **THEN** the system deletes the old photo file, copies the new one, and updates the path on the entity

#### Scenario: Photo deleted on plant removal
- **WHEN** user deletes a plant that has a photo
- **THEN** the system deletes the photo file from the filesystem before removing the entity from the list
