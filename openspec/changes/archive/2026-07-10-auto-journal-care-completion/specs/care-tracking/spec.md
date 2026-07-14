## ADDED Requirements

### Requirement: Task completions auto-create journal entries

When a care task is marked as done via the schedule view (the `completeTask` operation), the system SHALL automatically create a `JournalEntry` of type `task` in the plant journal for the associated plant. The journal entry SHALL record what task type was completed and at what time.

#### Scenario: Journal entry created on task completion

- **WHEN** user marks a care task as done for a plant (e.g., watering, fertilizing, pruning)
- **THEN** the system persists the `TaskCompletion` to the care schedule history
- **AND** the system creates a `JournalEntry` of type `task` for that plant
- **AND** the journal entry's timestamp matches the completion time
- **AND** the journal entry's notes describe the completed task (e.g., "Watering completed")

#### Scenario: User note included in journal entry

- **WHEN** user marks a care task as done and provides a note (e.g., "gave extra water")
- **THEN** the journal entry's notes SHALL include both the task description and the user's note (e.g., "Watering completed — gave extra water")

#### Scenario: Journal entry not created on snooze

- **WHEN** user snoozes a care task (defers it)
- **THEN** the system records the `TaskCompletion` for schedule anchoring
- **AND** the system does NOT create a journal entry

#### Scenario: Journal entry not created on skip

- **WHEN** user skips a care task
- **THEN** the system records the `TaskCompletion` for schedule anchoring
- **AND** the system does NOT create a journal entry

#### Scenario: Journal failure does not block task completion

- **WHEN** an error occurs while creating the journal entry (e.g., storage failure)
- **THEN** the task completion is still persisted
- **AND** the error is logged but not surfaced to the user
