## ADDED Requirements

### Requirement: Engine schedules metric measurement reminders
The system SHALL include enabled metric-linked custom care rules in deterministic schedule computation. The next due date SHALL be anchored to the newest measurement for that metric, or to the rule creation time when no measurement exists. Recording a measurement SHALL reset the reminder interval even when entered outside the care-task flow.

#### Scenario: Existing measurement anchors reminder
- **WHEN** a seven-day measurement rule has a newest measurement from three days ago
- **THEN** the next measurement task is due four days from today

#### Scenario: First reminder uses rule creation
- **WHEN** a newly created metric-linked rule has no measurements
- **THEN** its first due date is the rule creation time plus its configured interval

#### Scenario: Manual measurement resets reminder
- **WHEN** user records a linked metric from the Metrics page before its reminder is due
- **THEN** schedule recomputation anchors the next due date to that new measurement

### Requirement: Engine exposes one task for an active metric alert episode
The system SHALL expose one active care task for each metric whose latest measurement is alerting, whose response is care-task, and whose alert episode remains active. Schedule computation SHALL NOT expose an alert task for warning-only metrics, metrics without alert criteria, disabled metrics, or recovered alert episodes.

#### Scenario: Alerting metric produces task
- **WHEN** an enabled metric configured for care-task response enters alert state
- **THEN** schedule output contains one active task identifying that metric and its latest alerting value

#### Scenario: Consecutive alert values remain one task
- **WHEN** an alerting metric receives another alerting measurement
- **THEN** schedule output still contains exactly one alert task for the active episode

#### Scenario: Recovery removes task
- **WHEN** a metric's latest measurement returns to normal state
- **THEN** schedule output contains no active alert task for its closed episode
