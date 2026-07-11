# Symptom Logger — Delta Spec

## MODIFIED Requirements

### Requirement: Symptom entry is persisted locally
The system SHALL save each symptom entry as a JSON record associated with the plant. Each record SHALL include: entry ID, plant ID, symptom types (array using unified `PlantSymptom` names), severity, affected parts (array), onset timing, soil moisture, light conditions, notes, photo path, created timestamp, resolved flag (default false), and optional `diagnosisResultId` linking to the auto-generated diagnosis.

#### Scenario: Save symptom entry
- **WHEN** user submits the completed symptom form
- **THEN** the system persists the entry to local storage, triggers the diagnosis engine, and persists the diagnosis result with the symptom entry's ID linked

#### Scenario: View symptom history for a plant
- **WHEN** user opens a plant's detail page and navigates to the journal timeline
- **THEN** the system displays all symptom entries for that plant in reverse chronological order within the unified journal timeline

### Requirement: User can log a symptom for a plant

#### Scenario: Open symptom logger from plant detail
- **WHEN** user navigates to a plant's detail page and taps "Log Symptom"
- **THEN** the system opens the symptom logger form pre-associated with that plant

#### Scenario: Open symptom logger from journal timeline
- **WHEN** user taps "Log Symptom" from the plant's journal timeline section
- **THEN** the system opens the symptom logger form pre-associated with that plant
