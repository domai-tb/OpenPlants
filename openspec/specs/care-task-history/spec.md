# Care Task History

Event-sourced completion history for plant care tasks.

## Purpose

Record and retrieve immutable task-completion events so the scheduling engine can compute last-done anchors and users can review their care log.

## Requirements

### Requirement: Task completions are persisted as an event log
The system SHALL record each task completion as an immutable event containing: task type, plant UUID, completion timestamp, and optional note.

#### Scenario: Completion event stored on "Mark done"
- **WHEN** user taps "Mark done" on a watering task for plant "Aloe Vera"
- **THEN** the system persists a completion event with task type "watering", plant ID, current timestamp, and empty note

#### Scenario: Completion event includes note when provided
- **WHEN** user adds a note "Used moisture meter — still damp at 3 inches" when marking a task done
- **THEN** the persisted event includes the note text

### Requirement: Completion events are retrievable per plant
The system SHALL support querying the history sorted by most recent first, filterable by plant and/or task type.

#### Scenario: Filter by plant returns that plant's history
- **WHEN** user views task history filtered to plant "Aloe Vera"
- **THEN** the system returns only events for that plant, sorted newest first

#### Scenario: Filter by plant + task type returns specific events
- **WHEN** user views task history for plant "Aloe Vera" and task type "watering"
- **THEN** the system returns only watering events for that plant

### Requirement: The engine uses the most recent completion per task type
The engine SHALL read the latest completion event per (plantId, taskType) to compute the last-done anchor for schedule calculation.

#### Scenario: Engine reads latest watering event
- **WHEN** the schedule engine runs for a plant that has 12 watering completion events
- **THEN** the engine uses the most recent watering event's timestamp as the "last watered" anchor

### Requirement: History is displayed on the plant detail page
The system SHALL show a history of recent care tasks for each plant on its detail page, grouped by task type.

#### Scenario: Plant detail shows last 5 completions
- **WHEN** user opens a plant's detail page
- **THEN** the system displays the 5 most recent task completions for that plant

#### Scenario: Empty history shows "No care logged yet"
- **WHEN** a plant has no task completions
- **THEN** the system displays "No care tasks completed yet" on the plant detail

### Requirement: User can manually add a historical completion
The system SHALL allow users to back-date a task completion (e.g., "I watered this 3 days ago") when onboarding existing plants.

#### Scenario: Back-date watering
- **WHEN** user adds a new plant and marks "I watered this 2 days ago"
- **THEN** the system creates a completion event with timestamp set to 2 days ago

### Requirement: User can delete a completion event
The system SHALL allow deleting individual completion events (e.g., if recorded by accident).

#### Scenario: Delete event recalculates schedule
- **WHEN** user deletes a completion event and there is an earlier event for the same task type
- **THEN** the engine uses the earlier event as the last-done anchor; if no earlier event exists, the anchor is the plant creation date

### Requirement: Completion history excludes schedule-only actions
The completion event log SHALL contain only genuine care completions created by marking a task done or manually adding a historical completion. Snooze and skip actions MUST NOT appear in completion queries, history UI, care-status timestamps, or recently completed state.

#### Scenario: Snooze is absent from completion history
- **WHEN** a user snoozes a task and then opens that plant's care history
- **THEN** no completion event is added for the snooze

#### Scenario: Skip is absent from completion history
- **WHEN** a user skips a task and then opens that plant's care history
- **THEN** no completion event is added for the skip

#### Scenario: Mark done remains in completion history
- **WHEN** a user marks a task done
- **THEN** one completion event is stored and returned by the plant and task-type history queries

#### Scenario: Existing completion records remain readable
- **WHEN** the app loads completion records created by an earlier version
- **THEN** the system continues to decode and display those records without attempting to infer whether they originated from snooze or skip
