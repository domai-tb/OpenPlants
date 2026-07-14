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

### Requirement: Persisted collection corruption is preserved and reported
Every SharedPreferences-backed collection SHALL distinguish an absent key from unreadable or invalid stored content. The system MUST preserve the raw stored value and report a classified persistence failure when JSON, top-level collection shape, schema migration, or record decoding fails.

#### Scenario: Missing collection is empty
- **WHEN** a collection key does not exist
- **THEN** the data source returns an empty collection without error

#### Scenario: Malformed JSON is reported
- **WHEN** a collection key contains malformed JSON
- **THEN** the data source reports a classified decode failure identifying the collection
- **AND** leaves the raw stored value unchanged

#### Scenario: Wrong top-level shape is reported
- **WHEN** a collection key contains valid JSON that is not the expected list shape
- **THEN** the data source reports a classified shape failure
- **AND** leaves the raw stored value unchanged

#### Scenario: Invalid record is reported without partial save
- **WHEN** one record in a stored collection cannot be decoded or migrated
- **THEN** the data source reports the failing record index
- **AND** does not return a partial collection as writable state
- **AND** leaves every raw record unchanged

#### Scenario: Mutation after failed load is blocked
- **WHEN** an add, update, or delete operation cannot first load its collection without a persistence failure
- **THEN** the operation fails without writing a replacement collection

#### Scenario: Known older schema is migrated
- **WHEN** a stored record matches a supported older schema
- **THEN** the data source migrates and decodes the record without discarding unrelated records
