## ADDED Requirements

### Requirement: User can create a journal entry
The system SHALL allow users to create timestamped journal entries for a specific plant. Each entry has a type, optional photo, and optional notes.

#### Scenario: Create text entry
- **WHEN** user taps "Add journal entry" on a plant and selects "Text note"
- **THEN** the system creates a journal entry with type "text", current timestamp, and the entered notes

#### Scenario: Create photo entry
- **WHEN** user taps "Add journal entry" on a plant and selects "Photo"
- **THEN** the system opens camera/gallery, saves the photo, and creates a journal entry with type "photo" and the photo path

#### Scenario: Create task completion entry
- **WHEN** user taps "Add journal entry" and selects "Completed task"
- **THEN** the system creates a journal entry with type "task" and the task description

#### Scenario: Create growth update entry
- **WHEN** user taps "Add journal entry" and selects "Growth update"
- **THEN** the system creates a journal entry with type "growth" and the growth notes

#### Scenario: Create repotting entry
- **WHEN** user taps "Add journal entry" and selects "Repotting"
- **THEN** the system creates a journal entry with type "repotting" and the repotting details

#### Scenario: Create pest observation entry
- **WHEN** user taps "Add journal entry" and selects "Pest observation"
- **THEN** the system creates a journal entry with type "pest" and the pest description

#### Scenario: Create diagnosis result entry
- **WHEN** user taps "Add journal entry" and selects "Diagnosis result"
- **THEN** the system creates a journal entry with type "diagnosis" and the diagnosis notes

### Requirement: User can view journal timeline
The system SHALL display all journal entries for a plant in reverse chronological order (newest first).

#### Scenario: Empty journal shows placeholder
- **WHEN** user navigates to a plant's journal and there are no entries
- **THEN** the system displays an empty-state message "No journal entries yet"

#### Scenario: Journal shows entries in order
- **WHEN** user navigates to a plant's journal and entries exist
- **THEN** the system displays entries sorted by timestamp descending, with each entry showing its type icon, timestamp, and notes preview

#### Scenario: Journal shows photo thumbnails
- **WHEN** a journal entry has a photo
- **THEN** the system displays a thumbnail of the photo in the entry card

### Requirement: User can edit a journal entry
The system SHALL allow users to modify the notes and photo of an existing journal entry.

#### Scenario: Edit entry notes
- **WHEN** user taps on a journal entry and modifies the notes
- **THEN** the system updates the entry's notes and persists the change

#### Scenario: Replace entry photo
- **WHEN** user taps on a photo journal entry and selects a new photo
- **THEN** the system replaces the photo file and updates the entry reference

### Requirement: User can delete a journal entry
The system SHALL allow users to permanently remove a journal entry.

#### Scenario: Delete entry with confirmation
- **WHEN** user taps delete on a journal entry and confirms the dialog
- **THEN** the system removes the entry and deletes its photo file from disk (if any)

#### Scenario: Cancel delete
- **WHEN** user taps delete on a journal entry and cancels the confirmation dialog
- **THEN** the system does not modify the entry

### Requirement: Journal entries are stored locally
The system SHALL persist all journal entries in local SQLite storage.

#### Scenario: Entries survive app restart
- **WHEN** user creates journal entries and restarts the app
- **THEN** all journal entries are still available

#### Scenario: Entries are plant-specific
- **WHEN** user views journal for plant A and journal for plant B
- **THEN** each plant shows only its own journal entries
