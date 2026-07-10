# Plant Health Timeline

## Purpose

Unified reverse-chronological view of all plant health events (symptom logs and diagnosis results) on the plant detail page, providing a single place to monitor, track, and act on a plant's health status over time.

## Requirements

### Requirement: Health timeline displayed on plant detail page
The system SHALL display a health timeline section on the plant detail page showing symptom log entries and diagnosis results in reverse chronological order, merged into a single feed.

#### Scenario: Timeline shows mixed events
- **WHEN** a plant has both symptom log entries and diagnosis results
- **THEN** the timeline SHALL display them interleaved, sorted by `createdAt` descending

#### Scenario: Timeline shows only symptoms
- **WHEN** a plant has symptom log entries but no diagnosis results
- **THEN** the timeline SHALL show only symptom log entries

#### Scenario: Timeline shows only diagnoses
- **WHEN** a plant has diagnosis results but no symptom log entries (e.g., questionnaire-only diagnoses)
- **THEN** the timeline SHALL show only diagnosis results

#### Scenario: Empty timeline
- **WHEN** a plant has no health events
- **THEN** the timeline SHALL display an empty state message encouraging the user to log symptoms or start a diagnosis

### Requirement: Each event type has a distinct visual appearance
Symptom log entries and diagnosis results SHALL be visually distinguishable in the timeline.

#### Scenario: Symptom log appearance
- **WHEN** a timeline entry is a symptom log
- **THEN** it SHALL display: symptom type icons, severity badge, onset timing, affected parts, and resolved/unresolved status

#### Scenario: Diagnosis result appearance
- **WHEN** a timeline entry is a diagnosis result
- **THEN** it SHALL display: top cause name, confidence badge, summary evidence, and the date evaluated

#### Scenario: Linked events shown as paired
- **WHEN** a diagnosis result was auto-generated from a symptom log
- **THEN** the timeline SHALL visually group or indicate the relationship between the symptom entry and its resulting diagnosis

### Requirement: Timeline supports filtering
The system SHALL allow the user to filter the timeline to show only active (unresolved) symptoms or all events.

#### Scenario: Filter by active symptoms
- **WHEN** user applies the "Active" filter
- **THEN** the timeline SHALL show only unresolved symptom log entries and their linked diagnoses

#### Scenario: Show all events
- **WHEN** user selects "Show All"
- **THEN** the timeline SHALL show all events including resolved symptoms

### Requirement: Timeline provides action entry points
The health timeline SHALL provide buttons to log a new symptom and to start a diagnosis.

#### Scenario: Log symptom from timeline
- **WHEN** user taps "Log Symptom" on the timeline
- **THEN** the system opens the symptom logger form for the current plant

#### Scenario: Diagnose from timeline
- **WHEN** user taps "Diagnose" on the timeline
- **THEN** the system opens the diagnosis questionnaire with current unresolved symptoms pre-selected

### Requirement: Symptoms can be marked resolved from the timeline
The system SHALL allow the user to mark a symptom log entry as resolved directly from the timeline without navigating away.

#### Scenario: Mark resolved
- **WHEN** user taps "Mark Resolved" on an unresolved symptom log entry in the timeline
- **THEN** the system SHALL set the resolved flag to true and record the current timestamp, updating the view without a navigation

#### Scenario: Unresolved entry shows action
- **WHEN** a symptom log entry is unresolved
- **THEN** the timeline entry SHALL display a "Mark Resolved" action

#### Scenario: Resolved entry shows info
- **WHEN** a symptom log entry is resolved
- **THEN** the timeline entry SHALL display the resolved date and no action button

### Requirement: Timeline loads efficiently
The timeline SHALL load all health events for a plant on section mount and display them without pagination (acceptable for typical user data volumes under 100 events).

#### Scenario: Initial load
- **WHEN** the plant detail page opens and the timeline section is visible
- **THEN** the system SHALL load all symptom log entries and diagnosis results for that plant
