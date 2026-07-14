## Purpose

Plant journal feature allowing users to create, view, edit, and delete timestamped journal entries (text notes, photos, task completions, growth updates, repotting, pest observations, diagnosis results) for individual plants. Entries are stored locally and displayed in a reverse-chronological timeline.

## Requirements

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

### Requirement: User can view journal timeline
The system SHALL display all journal entries, symptom logs, and diagnosis results for a plant merged into a single reverse-chronological timeline (newest first). The system SHALL load entries from the journal store, symptom logger datasource, and diagnosis datasource and merge them at query time.

#### Scenario: Empty journal shows placeholder
- **WHEN** user navigates to a plant's journal and there are no entries, symptom logs, or diagnosis results
- **THEN** the system displays an empty-state message "No journal entries yet"

#### Scenario: Journal shows entries in order
- **WHEN** user navigates to a plant's journal and entries exist
- **THEN** the system displays entries sorted by timestamp descending, with each entry showing its type icon, timestamp, and notes preview

#### Scenario: Journal shows photo thumbnails
- **WHEN** a journal entry has a photo
- **THEN** the system displays a thumbnail of the photo in the entry card

#### Scenario: Journal shows symptom log entries
- **WHEN** a plant has symptom log entries
- **THEN** they appear in the journal timeline with symptom-specific rendering (symptom type icons, severity badge, onset timing, affected parts, resolved/unresolved status)

#### Scenario: Journal shows diagnosis result entries
- **WHEN** a plant has diagnosis results
- **THEN** they appear in the journal timeline with diagnosis-specific rendering (top cause name, confidence badge, summary evidence, date evaluated)

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
The system SHALL persist all journal entries in local storage.

#### Scenario: Entries survive app restart
- **WHEN** user creates journal entries and restarts the app
- **THEN** all journal entries are still available

#### Scenario: Entries are plant-specific
- **WHEN** user views journal for plant A and journal for plant B
- **THEN** each plant shows only its own journal entries

### Requirement: JournalEntry supports symptom and diagnosis types
The `JournalEntryType` enum SHALL be extended with `symptom` and `diagnosis` values. The `JournalEntry` entity SHALL support optional structured data fields (`referenceId`, `structuredData`) to carry symptom and diagnosis rendering data when projected from health event stores.

#### Scenario: Symptom entry projected at query time
- **WHEN** the journal datasource loads the timeline
- **THEN** each symptom log entry SHALL be projected into a `JournalEntry` with type `symptom` and the symptom's structured data (symptom types, severity, affected parts, onset timing, resolved status) populated in the entry

#### Scenario: Diagnosis entry projected at query time
- **WHEN** the journal datasource loads the timeline
- **THEN** each diagnosis result SHALL be projected into a `JournalEntry` with type `diagnosis` and the diagnosis's structured data (top cause, confidence, evidence summary) populated in the entry

#### Scenario: Linked symptom-diagnosis entries carry reference IDs
- **WHEN** a symptom log has a `diagnosisResultId`
- **THEN** the projected symptom `JournalEntry` SHALL store the diagnosis result ID in `referenceId`
- **AND** the projected diagnosis `JournalEntry` SHALL store the symptom log ID in `referenceId`

### Requirement: Journal entries of type "task" can be auto-created by care system

The system SHALL support auto-created journal entries of type `task` that originate from the care schedule's `completeTask` operation. These entries SHALL appear in the journal timeline alongside manually-created entries, with no visual distinction.

#### Scenario: Auto-created entry appears in timeline

- **WHEN** a care task is completed and an auto-journal entry is created
- **THEN** the entry appears in the plant's journal timeline sorted by timestamp
- **AND** the entry displays its task type description as the preview text
- **AND** the entry is visually consistent with manually-created task entries

#### Scenario: User can delete auto-created entry

- **WHEN** user views an auto-created task journal entry
- **THEN** the user can edit or delete the entry just like any manually-created entry
- **AND** deleting the journal entry does NOT affect the task completion in the care schedule history
