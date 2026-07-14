# Unified Timeline

## Purpose

Single reverse-chronological view on the plant detail page that merges manually-created journal entries (notes, photos, tasks, etc.) with health events (symptom logs and diagnosis results), providing a complete plant story in one place.

## Requirements

### Requirement: Unified timeline shows all entry types interleaved
The system SHALL display a single unified journal timeline on the plant detail page that shows manually-created journal entries, symptom log entries, and diagnosis results merged into one reverse-chronological feed sorted by timestamp descending.

#### Scenario: Timeline shows mixed event types
- **WHEN** a plant has journal entries, symptom logs, and diagnosis results
- **THEN** the timeline SHALL display all three types interleaved, sorted by `timestamp`/`createdAt` descending

#### Scenario: Timeline shows only journal entries
- **WHEN** a plant has journal entries but no health events
- **THEN** the timeline SHALL show only the journal entries

#### Scenario: Timeline shows only health events
- **WHEN** a plant has health events (symptom logs and/or diagnoses) but no manually-created journal entries
- **THEN** the timeline SHALL show only the health events

#### Scenario: Empty unified timeline
- **WHEN** a plant has no journal entries, no symptom logs, and no diagnosis results
- **THEN** the timeline SHALL display an empty state message encouraging the user to log a symptom, run a diagnosis, or create a journal entry

### Requirement: Each entry type has a distinct visual appearance
Every entry type SHALL render with type-appropriate card UI that surfaces the most relevant information for that type.

#### Scenario: Text/photo/task/growth/repotting/pest entry appearance
- **WHEN** a timeline entry is a manually-created journal entry (text, photo, task, growth, repotting, pest)
- **THEN** it SHALL display its type icon, timestamp, and notes preview (and photo thumbnail for photo type)

#### Scenario: Symptom log appearance
- **WHEN** a timeline entry is a symptom log
- **THEN** it SHALL display: symptom type icons, severity badge, onset timing, affected parts, and resolved/unresolved status

#### Scenario: Diagnosis result appearance
- **WHEN** a timeline entry is a diagnosis result
- **THEN** it SHALL display: top cause name, confidence badge, summary evidence, and the date evaluated

#### Scenario: Linked events shown as paired
- **WHEN** a diagnosis result was auto-generated from a symptom log
- **THEN** the timeline SHALL visually group or indicate the relationship between the symptom entry and its resulting diagnosis

### Requirement: Timeline provides action entry points
The unified timeline SHALL provide buttons to create a journal entry, log a symptom, and start a diagnosis.

#### Scenario: Create journal entry from timeline
- **WHEN** user taps "Add Entry" on the timeline
- **THEN** the system shows a menu of journal entry types to create (text, photo, task, growth, repotting, pest)

#### Scenario: Log symptom from timeline
- **WHEN** user taps "Log Symptom" on the timeline
- **THEN** the system opens the symptom logger form for the current plant

#### Scenario: Diagnose from timeline
- **WHEN** user taps "Diagnose" on the timeline
- **THEN** the system opens the diagnosis questionnaire with current unresolved symptoms pre-selected

### Requirement: Symptoms can be marked resolved from the timeline
The system SHALL allow the user to mark a symptom log entry as resolved directly from the unified timeline without navigating away.

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
The timeline SHALL load all events for a plant on section mount and display them without pagination (acceptable for typical user data volumes under 200 events).

#### Scenario: Initial load
- **WHEN** the plant detail page opens and the unified timeline section is visible
- **THEN** the system SHALL load all journal entries, symptom log entries, and diagnosis results for that plant and merge them into a single list sorted by timestamp descending
