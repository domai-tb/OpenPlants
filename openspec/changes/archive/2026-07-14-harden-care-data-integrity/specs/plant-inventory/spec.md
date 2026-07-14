## MODIFIED Requirements

### Requirement: User can edit a plant
The system SHALL allow users to modify any field of an existing plant entry and SHALL reconcile main-photo files against the previously persisted plant state.

#### Scenario: Edit plant name
- **WHEN** user opens a plant detail and changes the name
- **THEN** the system updates the plant's name and persists the change

#### Scenario: Replace plant photo
- **WHEN** user opens a plant detail and picks a new photo
- **THEN** the system saves the replacement and persists its reference before deleting the previously persisted photo file

#### Scenario: Remove plant photo
- **WHEN** user opens a plant detail and removes the existing photo
- **THEN** the system clears the photo reference and deletes the previously persisted photo file from disk

#### Scenario: Plant update persistence fails
- **WHEN** persistence fails while replacing or clearing a main photo
- **THEN** the system retains the old referenced photo file
- **AND** removes any unreferenced staged replacement
- **AND** reports a classified failure

### Requirement: User can delete a plant
The system SHALL allow users to permanently remove a plant from their collection. Confirmed deletion SHALL remove all records and files owned by that plant, including its main photo, growth photos, journal entries and attachments, symptoms, diagnoses, care completions, schedule actions and configuration, custom care rules, and drafts.

#### Scenario: Delete plant with confirmation
- **WHEN** user taps delete on a plant and confirms the dialog
- **THEN** the system removes every plant-owned record and file
- **AND** removes the plant record only after child cleanup completes
- **AND** deleted-plant records no longer appear in collection, timeline, history, symptom, diagnosis, or care queries

#### Scenario: Cancel delete
- **WHEN** user taps delete on a plant and cancels the confirmation dialog
- **THEN** the system does not modify the plant, its photos, or any metadata

#### Scenario: Retry interrupted deletion
- **WHEN** a deletion attempt stops after some child data is already absent
- **THEN** retrying the deletion treats missing child records and files as already removed
- **AND** completes removal of the remaining owned data

#### Scenario: Child cleanup fails
- **WHEN** an unexpected persistence or file error prevents child cleanup
- **THEN** the system reports the failure
- **AND** retains the plant record so deletion can be retried
