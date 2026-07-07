## MODIFIED Requirements

### Requirement: Engine supports custom user-defined task types
The engine SHALL accept an optional list of custom care rules for a plant. For each rule where `isEnabled` is true, the engine SHALL use the rule's `intervalDays` as the effective interval for that task type, bypassing species defaults, room modifiers, and pot-type modifiers. If no matching rule exists for a task type, the engine falls back to the existing computation pipeline.

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
