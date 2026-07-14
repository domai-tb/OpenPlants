## ADDED Requirements

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
