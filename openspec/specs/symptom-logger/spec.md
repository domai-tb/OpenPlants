# Symptom Logger

## Purpose

Allow users to record structured plant health symptom entries (symptom type, severity, affected parts, onset timing, environmental observations, notes, and photo) associated with plants in their collection, view symptom history, and mark entries as resolved.

## Requirements

### Requirement: User can log a symptom for a plant
The system SHALL provide a structured form to record a symptom entry for any plant in the collection. Each entry SHALL capture: symptom type (from the unified `PlantSymptom` enum), severity, affected parts, onset timing, soil moisture, light conditions, optional notes, and optional photo. After a symptom is logged, the system SHALL automatically run the diagnosis engine using the logged data and persist the result.

#### Scenario: Open symptom logger from plant detail
- **WHEN** user navigates to a plant's detail page and taps "Log Symptom"
- **THEN** the system opens the symptom logger form pre-associated with that plant

#### Scenario: Open symptom logger from health timeline
- **WHEN** user taps "Log Symptom" from the plant's health timeline section
- **THEN** the system opens the symptom logger form pre-associated with that plant

#### Scenario: Open symptom logger from quick action
- **WHEN** user taps "Log Symptom" from the home or collection screen
- **THEN** the system prompts the user to select a plant, then opens the symptom logger form

#### Scenario: Auto-diagnosis after symptom log
- **WHEN** user submits a completed symptom form
- **THEN** the system SHALL persist the symptom entry AND SHALL automatically build a `DiagnosisContext` from the logged data, run the diagnosis engine, persist the result linked to the symptom entry, and display a confirmation with an option to view the diagnosis

### Requirement: Symptom type is selected from a predefined list
The system SHALL present symptom types as selectable options from the unified `PlantSymptom` enum: yellowing leaves, drooping/wilting, brown leaf tips, brown patches/scorched, pale leaves, leggy growth, visible insects, sticky residue, mold on soil, foul smell, stunted growth, leaf curling, leaf drop, soft stems, leaf spots.

#### Scenario: Select single symptom type
- **WHEN** user taps one symptom type option
- **THEN** the system records that selection and highlights it as active

#### Scenario: Select multiple symptom types
- **WHEN** user taps multiple symptom type options
- **THEN** the system records all selected types for the entry

#### Scenario: No symptom type selected
- **WHEN** user attempts to proceed without selecting any symptom type
- **THEN** the system displays a validation error and prevents progression

### Requirement: Severity level is recorded
The system SHALL require the user to assign a severity level to each symptom entry: mild, moderate, or severe.

#### Scenario: Select severity
- **WHEN** user taps a severity option (mild, moderate, or severe)
- **THEN** the system records the severity and highlights the selected option

### Requirement: Affected plant parts are captured
The system SHALL allow the user to indicate which parts of the plant are affected: leaves, stems, roots, soil, flowers, or multiple areas.

#### Scenario: Select affected parts
- **WHEN** user selects one or more affected plant parts
- **THEN** the system records the selection for the symptom entry

### Requirement: Onset timing is recorded
The system SHALL ask when the symptom was first noticed: today, a few days ago, about a week ago, or more than a week ago.

#### Scenario: Select onset timing
- **WHEN** user selects an onset timing option
- **THEN** the system records the timing for the symptom entry

### Requirement: Environmental observations are collected
The system SHALL collect soil moisture observation (dry, moist, wet, soggy) and light conditions (full sun, partial shade, low light, unknown) as optional fields.

#### Scenario: Record soil moisture
- **WHEN** user selects a soil moisture observation
- **THEN** the system records the value for the symptom entry

#### Scenario: Record light conditions
- **WHEN** user selects a light condition observation
- **THEN** the system records the value for the symptom entry

### Requirement: Optional notes and photo
The system SHALL allow the user to add free-text notes (max 500 characters) and attach one photo per symptom entry.

#### Scenario: Add notes
- **WHEN** user types text in the notes field
- **THEN** the system stores the text with the symptom entry

#### Scenario: Attach photo
- **WHEN** user taps "Add Photo" and captures or selects an image
- **THEN** the system stores the photo path with the symptom entry

### Requirement: Symptom entry is persisted locally
The system SHALL save each symptom entry as a JSON record associated with the plant. Each record SHALL include: entry ID, plant ID, symptom types (array using unified `PlantSymptom` names), severity, affected parts (array), onset timing, soil moisture, light conditions, notes, photo path, created timestamp, resolved flag (default false), and optional `diagnosisResultId` linking to the auto-generated diagnosis.

#### Scenario: Save symptom entry
- **WHEN** user submits the completed symptom form
- **THEN** the system persists the entry to local storage, triggers the diagnosis engine, and persists the diagnosis result with the symptom entry's ID linked

#### Scenario: View symptom history for a plant
- **WHEN** user opens a plant's detail page and navigates to "Symptom History" or the health timeline
- **THEN** the system displays all symptom entries for that plant in reverse chronological order

### Requirement: Symptom entries can be marked as resolved
The system SHALL allow the user to mark a symptom entry as resolved. Resolved entries SHALL remain in the history with the resolved flag set to true and a resolved timestamp.

#### Scenario: Mark symptom as resolved
- **WHEN** user taps "Mark Resolved" on an unresolved symptom entry
- **THEN** the system sets the resolved flag to true and records the current timestamp

### Requirement: Symptom form supports draft auto-save
The system SHALL auto-save form progress at each step so users can resume later without losing data.

#### Scenario: Exit form mid-flow
- **WHEN** user navigates away from the symptom form before submitting
- **THEN** the system saves the current progress as a draft

#### Scenario: Resume draft
- **WHEN** user re-opens the symptom logger for the same plant with an active draft
- **THEN** the system pre-fills the form with the saved draft data

### Requirement: Symptom log migration from old SymptomType enum
The system SHALL transparently migrate existing symptom log entries that were serialized with the old `SymptomType` enum names when they are loaded.

#### Scenario: Load old-format entry
- **WHEN** a persisted symptom log entry uses old `SymptomType` names (e.g., "yellowLeaves", "drooping")
- **THEN** the system SHALL map them to the equivalent unified `PlantSymptom` names (e.g., "yellowingLeaves", "droopingWilt")

#### Scenario: Unknown old symptom type
- **WHEN** an old symptom type has no exact equivalent in the unified enum (e.g., "drySoil", "wetSoil")
- **THEN** the system SHALL keep it as a `PlantSymptom` entry with the same name (those values are already part of the unified enum)

### Requirement: Symptom entry links to auto-diagnosis result
When the auto-diagnosis runs after symptom logging, the symptom log entry SHALL store the resulting diagnosis ID for bidirectional navigation.

#### Scenario: Navigate from symptom to diagnosis
- **WHEN** viewing a symptom log entry that has a linked diagnosis
- **THEN** the system SHALL display an indicator (e.g., "Diagnosis available") and allow the user to navigate to the persisted diagnosis result

#### Scenario: Navigate from diagnosis to symptom
- **WHEN** viewing a diagnosis result that originated from a symptom log
- **THEN** the system SHALL link back to the source symptom log entry
