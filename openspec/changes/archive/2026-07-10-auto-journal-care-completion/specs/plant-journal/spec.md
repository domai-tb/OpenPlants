## ADDED Requirements

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
