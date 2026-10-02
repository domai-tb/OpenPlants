## Purpose

Enable users to define plant-specific statistics, record typed measurements over time, detect optional alert conditions, and understand trends through local visual history.

## ADDED Requirements

### Requirement: Users can define metrics per plant
The system SHALL let users create, edit, disable, and delete metric definitions owned by one plant. A metric SHALL have a unique identifier, plant identifier, required non-blank name, required non-blank unit, and a value type of numeric, boolean, or categorical. Value type SHALL default to numeric. Notes and data-entry instructions SHALL be optional.

#### Scenario: Create minimal metric
- **WHEN** user creates a metric named "Water level" with unit "cm" and supplies no other configuration
- **THEN** the system persists an enabled numeric metric for the selected plant

#### Scenario: Reject missing required fields
- **WHEN** user attempts to save a metric with a blank name or blank unit
- **THEN** the system rejects the metric and identifies each invalid field

#### Scenario: Metrics remain plant-specific
- **WHEN** two plants have metric definitions
- **THEN** each plant's Metrics page displays only definitions owned by that plant

### Requirement: Categorical metrics use custom options
A categorical metric SHALL contain at least one non-blank, case-insensitively unique user-defined option. Boolean metrics SHALL use the fixed values true and false without requiring custom options.

#### Scenario: Create categorical metric
- **WHEN** user creates a "Leaf color" metric with unit "state" and options "Green", "Yellow", and "Brown"
- **THEN** future entries for that metric offer exactly those category options

#### Scenario: Reject categorical metric without options
- **WHEN** user selects categorical value type but provides no valid options
- **THEN** the system rejects the definition and asks for at least one option

### Requirement: Metric alert criteria are optional
The system SHALL allow numeric metrics to define an optional minimum, optional maximum, or both. It SHALL allow boolean and categorical metrics to identify zero or more values as alert values. A numeric minimum SHALL NOT exceed its maximum. A metric without an applicable bound or alert value SHALL never enter an alert state, but MAY still have measurement reminders.

#### Scenario: Numeric metric has no bounds
- **WHEN** user saves a numeric metric without a minimum and maximum
- **THEN** measurements never trigger range warnings or alert care tasks for that metric

#### Scenario: One-sided numeric bound
- **WHEN** a numeric metric has minimum 2 and no maximum
- **THEN** values below 2 trigger its configured alert behavior and values at or above 2 do not

#### Scenario: Invalid numeric range
- **WHEN** user attempts to save minimum 10 and maximum 5
- **THEN** the system rejects the range without changing the persisted metric

#### Scenario: Categorical alert option
- **WHEN** "Yellow" is selected as an alert value for the "Leaf color" metric
- **THEN** a measurement of "Yellow" enters alert state and a measurement of any non-alert option does not

### Requirement: Alert response is configurable per metric
For a metric with alert criteria, the system SHALL let the user choose warning-only or care-task response. Warning-only SHALL be the default. Warning-only SHALL expose the active alert on the metric summary and graph without creating a care task. Care-task response SHALL additionally expose one active care task for the current alert episode.

#### Scenario: Default warning-only response
- **WHEN** user configures a target range without choosing a response and records an out-of-range value
- **THEN** the metric shows an active warning and no alert care task is created

#### Scenario: Care-task response
- **WHEN** a metric configured for care-task response changes from normal to alert state
- **THEN** the care schedule exposes one active task identifying the plant and metric

#### Scenario: Alert episode is deduplicated
- **WHEN** multiple consecutive measurements remain in alert state
- **THEN** the system maintains one alert episode and does not expose duplicate care tasks for that metric

#### Scenario: Recovery closes alert episode
- **WHEN** a later measurement no longer matches the metric's alert criteria
- **THEN** the warning clears, any unresolved generated alert task is no longer active, and a future alert can start a new episode

### Requirement: Users can record typed measurements
The system SHALL let users record a timestamped value for an enabled metric. Numeric values SHALL be finite decimal numbers, boolean values SHALL be true or false, and categorical values SHALL match one configured option. The timestamp SHALL default to the current time.

#### Scenario: Record decimal measurement
- **WHEN** user records nutrient concentration 1.75 with unit "mS/cm"
- **THEN** the system persists the exact decimal value with metric, plant, and timestamp associations

#### Scenario: Record boolean measurement
- **WHEN** user records true for a boolean "Pests visible" metric
- **THEN** the system persists a boolean value rather than a text approximation

#### Scenario: Reject value with wrong type
- **WHEN** user submits text for a numeric metric or an unknown option for a categorical metric
- **THEN** the system rejects the entry without changing measurement history

#### Scenario: Disabled metric rejects new entry
- **WHEN** user attempts to record a value for a disabled metric
- **THEN** the system rejects the entry while preserving existing history

### Requirement: Users can correct measurement history
The system SHALL let users edit a measurement value and timestamp or delete a measurement. After either operation, current metric status SHALL be recalculated from the newest remaining measurement.

#### Scenario: Correct latest value
- **WHEN** user replaces an erroneous latest measurement with a valid in-range value
- **THEN** the corrected entry is persisted and the active alert state is recalculated

#### Scenario: Delete latest value
- **WHEN** user deletes the newest measurement
- **THEN** the metric status is recalculated from the next-newest entry, or becomes "No measurements" when none remain

### Requirement: Metrics page displays summaries and history graphs
The system SHALL provide a Metrics page for one plant. It SHALL display each enabled metric's latest value, unit, timestamp, alert state, and an action to record a measurement. Selecting a metric SHALL display its chronological measurement history as a graph and an accessible textual history.

#### Scenario: Numeric history graph
- **WHEN** a numeric metric has multiple entries
- **THEN** the page plots values over time and displays configured minimum and maximum boundaries when present

#### Scenario: Boolean history graph
- **WHEN** a boolean metric has multiple entries
- **THEN** the page plots changes between labeled true and false states without converting them into user-visible numeric scores

#### Scenario: Categorical history graph
- **WHEN** a categorical metric has multiple entries
- **THEN** the page plots the selected labeled categories over time without requiring user-defined numeric scores

#### Scenario: Graph remains accessible without visual interpretation
- **WHEN** user opens any metric history
- **THEN** the same timestamped values and alert states are available as readable text entries

#### Scenario: Metric has no measurements
- **WHEN** user opens a metric with no history
- **THEN** the page shows a localized empty state and an action to record the first value

### Requirement: Metric data persists locally without silent loss
The system SHALL persist metric definitions and measurements on device. Missing storage SHALL load as an empty collection. Malformed or unsupported stored data SHALL produce a classified failure, preserve the raw stored value, and block mutation from overwriting unreadable data.

#### Scenario: Data survives restart
- **WHEN** user records measurements and restarts the app
- **THEN** all metric definitions, entries, and current alert states are reconstructed from local data

#### Scenario: Corrupt collection is preserved
- **WHEN** a persisted metric collection cannot be decoded
- **THEN** the system reports a classified persistence failure and does not replace the raw collection with empty data

### Requirement: Metric deletion handles owned data explicitly
Deleting a metric SHALL require confirmation and SHALL remove its measurements, linked measurement rule, and active generated alert state. Disabling a metric SHALL preserve those records but suppress new entries, reminders, warnings, and generated tasks until re-enabled.

#### Scenario: Confirm metric deletion
- **WHEN** user confirms deletion of a metric with measurements and a linked rule
- **THEN** the metric, measurements, rule, and active alert state are removed

#### Scenario: Cancel metric deletion
- **WHEN** user cancels the deletion confirmation
- **THEN** no metric-owned data changes
