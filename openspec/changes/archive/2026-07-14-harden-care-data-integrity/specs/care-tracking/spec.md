## MODIFIED Requirements

### Requirement: Task completions auto-create journal entries

When a care task is marked as done via the schedule view (the `completeTask` operation), the system SHALL automatically create a `JournalEntry` of type `task` in the plant journal for the associated plant. The journal entry SHALL record what task type was completed and at what time. Snooze and skip are schedule-only actions and MUST NOT be persisted as task completions.

In addition, when the completed task is a watering or fertilizing task, the system SHALL update the plant's care status timestamps (`lastWateredAt` or `lastFertilizedAt`) and reset the stored `careStatus` to `happy` if it was the corresponding needs-status. This ensures the plant's effective care status reflects the completed care action.

#### Scenario: Journal entry created on task completion

- **WHEN** user marks a care task as done for a plant (e.g., watering, fertilizing, pruning)
- **THEN** the system persists the `TaskCompletion` to the care schedule history
- **AND** the system creates a `JournalEntry` of type `task` for that plant
- **AND** the journal entry's timestamp matches the completion time
- **AND** the journal entry's notes describe the completed task (e.g., "Watering completed")

#### Scenario: User note included in journal entry

- **WHEN** user marks a care task as done and provides a note (e.g., "gave extra water")
- **THEN** the journal entry's notes SHALL include both the task description and the user's note (e.g., "Watering completed — gave extra water")

#### Scenario: Watering task completion updates plant status

- **WHEN** user marks a watering task as done for a plant
- **THEN** the system sets `lastWateredAt` to the current timestamp
- **AND** if the plant's stored `careStatus` was `needsWater`, the system sets it to `happy`

#### Scenario: Fertilizing task completion updates plant status

- **WHEN** user marks a fertilizing task as done for a plant
- **THEN** the system sets `lastFertilizedAt` to the current timestamp
- **AND** if the plant's stored `careStatus` was `needsFertilizer`, the system sets it to `happy`

#### Scenario: Non-watering/fertilizing task does not update plant status

- **WHEN** user marks a task of type misting, pruning, rotating, repotting, leaf cleaning, or pest inspection as done
- **THEN** the system does NOT modify the plant's `lastWateredAt`, `lastFertilizedAt`, or `careStatus` fields

#### Scenario: Plant status update failure does not block task completion

- **WHEN** an error occurs while updating the plant's care status (e.g., plant not found, storage failure)
- **THEN** the task completion is still persisted
- **AND** the journal entry is still created (if applicable)
- **AND** the error is logged but not surfaced to the user

#### Scenario: Snooze does not complete care

- **WHEN** user snoozes a care task for a positive number of days
- **THEN** the system persists a schedule-only snooze action
- **AND** the system does NOT persist a `TaskCompletion`
- **AND** the system does NOT create a journal entry
- **AND** the system does NOT update the plant's care status

#### Scenario: Skip does not complete care

- **WHEN** user skips a care task
- **THEN** the system persists a schedule-only skip action
- **AND** the system does NOT persist a `TaskCompletion`
- **AND** the system does NOT create a journal entry
- **AND** the system does NOT update the plant's care status

#### Scenario: Journal failure does not block task completion

- **WHEN** an error occurs while creating the journal entry (e.g., storage failure)
- **THEN** the task completion is still persisted
- **AND** the error is logged but not surfaced to the user
