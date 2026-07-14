## ADDED Requirements

### Requirement: Engine applies persisted schedule actions without completing care
The engine SHALL accept an optional active schedule action for each plant and task type and SHALL apply it only to the schedule occurrence identified by that action. A schedule action MUST NOT replace the most recent genuine completion used as the care-history anchor.

#### Scenario: Snooze uses the selected duration
- **WHEN** a user snoozes a task for 3 days at a known time
- **THEN** the task's overridden due date is exactly 3 calendar days after the action time
- **AND** the underlying completion anchor remains unchanged

#### Scenario: Skip advances one effective interval
- **WHEN** a user skips a task whose current due date is known and whose effective interval is 7 days
- **THEN** the task's overridden due date is 7 days after the current due date
- **AND** the underlying completion anchor remains unchanged

#### Scenario: Schedule action survives restart
- **WHEN** the schedule is recomputed after the app restarts with an active persisted snooze or skip
- **THEN** the engine returns the same overridden due date

#### Scenario: Stale schedule action is ignored
- **WHEN** a schedule action identifies an occurrence that is no longer current
- **THEN** the engine computes the task from the current completion and configuration inputs without applying that action

### Requirement: Genuine completion supersedes active schedule actions
The system SHALL clear the active schedule action for a plant and task type when genuine care is completed and SHALL compute the next due date from that new completion.

#### Scenario: Mark done after snooze
- **WHEN** a user marks a snoozed task done
- **THEN** the system records a genuine completion
- **AND** clears the active snooze for that plant and task type
- **AND** computes the next due date from the completion time
