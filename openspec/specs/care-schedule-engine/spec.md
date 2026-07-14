# Care Schedule Engine

Pure-function scheduling engine that computes when each care task is due for a given plant.

## Purpose

Provide a deterministic, testable computation layer that transforms plant data, species defaults, room context, pot type, and completion history into a prioritized list of care tasks.

## Requirements

### Requirement: Engine generates a deterministic task schedule per plant
The system SHALL expose a pure function that accepts a plant entity, its schedule config, room attributes, current season, pot type, task completion history, custom care rules, and today's date, and returns a list of care tasks ordered by urgency (overdue first, then due-today, then upcoming).

#### Scenario: Happy path returns sorted task list
- **WHEN** the engine receives valid inputs for a plant with known species defaults and no overdue tasks
- **THEN** the engine returns a list of tasks sorted by next-due date, with no overdue items

#### Scenario: Same inputs produce identical output
- **WHEN** the engine is called twice with identical inputs
- **THEN** both calls return identical task lists

#### Scenario: Empty history computes from species defaults
- **WHEN** the engine receives a new plant with no task completion history
- **THEN** all tasks are scheduled based on the species-default intervals from today

### Requirement: Engine identifies overdue tasks
A task SHALL be flagged as overdue when the elapsed time since the last completion exceeds the effective interval by a tolerance margin of 20%.

#### Scenario: Task past interval plus tolerance is overdue
- **WHEN** the last completion of a task type was more than 1.2× the effective interval ago
- **THEN** the engine flags that task as `overdue`

#### Scenario: Task within tolerance is not overdue
- **WHEN** the last completion of a task type was within 1.2× the effective interval
- **THEN** the engine flags that task as `due` or `upcoming` based on its position

### Requirement: Engine applies seasonal modifiers
The engine SHALL apply a monthly multiplier table per task type, reducing or increasing the base interval based on the current month.

#### Scenario: Winter dormancy reduces watering frequency
- **WHEN** the current month is December and the species has a winter dormancy multiplier of 0.5 for watering
- **THEN** the effective watering interval is 2× the base interval (half as frequent)

#### Scenario: Summer growth increases fertilizing frequency
- **WHEN** the current month is July and the species has a summer growth multiplier of 1.5 for fertilizing
- **THEN** the effective fertilizing interval is reduced to 67% of the base interval (more frequent)

### Requirement: Engine applies room-context modifiers
The system SHALL modulate watering and misting intervals based on the assigned room's structured attributes (LightLevel enum, HumidityLevel enum) from the RoomEntity, if a room is assigned to the plant. When a plant has a user-set light level, the plant-level light assessment SHALL take precedence over the room's sunlight attribute for watering modifiers.

#### Scenario: High light increases watering frequency
- **WHEN** a plant is assigned to a room with light level `LightLevel.directSun` and the species has a high-light modifier
- **THEN** the effective watering interval is shorter than the base (0.7× multiplier)

#### Scenario: High humidity reduces watering frequency
- **WHEN** a plant is assigned to a room with humidity `HumidityLevel.high`
- **THEN** the effective watering interval is longer than the base (1.3× multiplier)

#### Scenario: Low humidity increases misting frequency
- **WHEN** a plant is assigned to a room with humidity `HumidityLevel.low`
- **THEN** the effective misting interval is shorter than the base (0.7× multiplier)

#### Scenario: Missing room config uses baseline
- **WHEN** a plant has no roomId assigned or the referenced room does not exist
- **THEN** the engine uses 1.0× (no modifier) for all room-based factors

#### Scenario: Room environment multiplied with seasonal modifier
- **WHEN** a plant is in a room with `LightLevel.bright` and the current month has a seasonal multiplier of 0.8×
- **THEN** the effective interval applies both multipliers (room × season) sequentially

#### Scenario: Plant light level overrides room sunlight
- **WHEN** a plant has a user-set light level of `low` and is in a room configured with "full sun"
- **THEN** the engine uses the `low` light-level modifier for watering, ignoring the room's sunlight attribute

#### Scenario: Null plant light level falls back to room sunlight
- **WHEN** a plant has no light level set (`null`) and is in a room with sunlight configured
- **THEN** the engine uses the room's sunlight attribute as the light modifier (existing behavior)

### Requirement: Engine applies pot-type modifiers
The engine SHALL adjust the watering interval based on the plant's pot type.

#### Scenario: Terracotta pot shortens watering interval
- **WHEN** a plant is in a terracotta pot
- **THEN** the effective watering interval is 0.8× the base (more frequent — clay breathes)

#### Scenario: Self-watering pot lengthens watering interval
- **WHEN** a plant is in a self-watering pot
- **THEN** the effective watering interval is 1.5× the base (less frequent — reservoir)

#### Scenario: Plastic pot uses moderate modifier
- **WHEN** a plant is in a standard plastic pot
- **THEN** the effective watering interval is 1.0× (baseline)

### Requirement: Engine supports 8 built-in task types
The engine SHALL recognize 8 built-in task types by default: watering, fertilizing, misting, pruning, rotating, repotting, leaf cleaning, pest inspection. Each has a species-default interval.

#### Scenario: All 8 task types present in output
- **WHEN** the engine computes a schedule for a species with all 8 defaults defined
- **THEN** the output includes tasks for all 8 types

#### Scenario: Zero-interval task types are omitted
- **WHEN** a species defines an interval of 0 days for a task type (e.g., "never needs repotting")
- **THEN** the engine does not include that task type in the output

### Requirement: Engine supports custom user-defined task types
The engine SHALL accept an optional list of custom care rules for a plant. For each rule where `isEnabled` is true, the engine SHALL use the rule's `intervalDays` as the effective interval for that task type, bypassing species defaults, room modifiers, and pot-type modifiers. If no matching rule exists for a task type, the engine falls back to the existing computation pipeline.

#### Scenario: Custom task appears in schedule
- **WHEN** a user has defined a custom task type "Check for flowers" with interval 7 days
- **THEN** the engine includes that task in the generated schedule

#### Scenario: Custom rule overrides species default
- **WHEN** a plant has a custom care rule for "watering" with interval 10 days and the species default is 7 days
- **THEN** the engine uses 10 days as the effective watering interval (no modifiers applied)

#### Scenario: Disabled rule is ignored
- **WHEN** a plant has a custom care rule for "watering" with isEnabled=false
- **THEN** the engine uses the species default for watering (rule is excluded from computation)

#### Scenario: No matching rule uses fallback
- **WHEN** a plant has no custom care rule for "fertilizing"
- **THEN** the engine computes the fertilizing interval from species defaults and modifiers as before

#### Scenario: Custom rule for user-defined task type
- **WHEN** a plant has a custom care rule for "Check for flowers" with interval 7 days
- **THEN** the engine includes "Check for flowers" as a task in the schedule with interval 7 days

### Requirement: Engine resets next-due after completion
When a completion event is recorded for a task type, the engine SHALL use that event's timestamp as the anchor for the next computation.

#### Scenario: Completion resets the timer
- **WHEN** a plant was watered 5 days ago (interval 7 days) and then watered again today
- **THEN** the next watering due date shifts to today + 7 days (adjusted by modifiers)

### Requirement: Schedule result includes completion timestamps
The schedule computation result SHALL include, for each task, the timestamp of the most recent `TaskCompletion` for that task type and plant (if any). This allows downstream consumers to apply grace-window detection without a separate query.

#### Scenario: Completed task includes timestamp
- **WHEN** the engine computes a schedule for a plant that has a watering completion from 2 hours ago
- **THEN** the returned `CareTask` for watering includes `completedAt` set to that timestamp

#### Scenario: Never-completed task has null timestamp
- **WHEN** the engine computes a schedule for a newly added plant with no completions
- **THEN** the returned tasks have `completedAt` set to null

### Requirement: Engine separates just-completed tasks in its output
The engine SHALL expose a method or output that groups tasks into four buckets for the caller: `overdue`, `dueNow` (due today or overdue within grace), `upcoming` (future due dates outside grace), and `completedEarly` (completed today with future next-due).

#### Scenario: Completed-early bucket contains only tasks in grace window
- **WHEN** the engine runs and one task has `completedAt` today with next-due tomorrow
- **THEN** the task appears in `completedEarly`, not in `upcoming`

#### Scenario: Empty completed-early bucket when no tasks completed today
- **WHEN** the engine runs and no tasks were completed today
- **THEN** the `completedEarly` list is empty

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
