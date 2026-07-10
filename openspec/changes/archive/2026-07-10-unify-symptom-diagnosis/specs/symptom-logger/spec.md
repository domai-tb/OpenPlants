# Symptom Logger — Delta

Modified capability. Changes sourced from original spec at `openspec/specs/symptom-logger/spec.md`.

## MODIFIED Requirements

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

#### Scenario: Select single symptom type (unchanged behavior)
- **WHEN** user taps one symptom type option
- **THEN** the system records that selection and highlights it as active

#### Scenario: Select multiple symptom types (unchanged behavior)
- **WHEN** user taps multiple symptom type options
- **THEN** the system records all selected types for the entry

#### Scenario: No symptom type selected (unchanged behavior)
- **WHEN** user attempts to proceed without selecting any symptom type
- **THEN** the system displays a validation error and prevents progression

### Requirement: Symptom entry is persisted locally
The system SHALL save each symptom entry as a JSON record associated with the plant. Each record SHALL include: entry ID, plant ID, symptom types (array using unified `PlantSymptom` names), severity, affected parts (array), onset timing, soil moisture, light conditions, notes, photo path, created timestamp, resolved flag (default false), and optional `diagnosisResultId` linking to the auto-generated diagnosis.

#### Scenario: Save symptom entry (modified)
- **WHEN** user submits the completed symptom form
- **THEN** the system persists the entry to local storage, triggers the diagnosis engine, and persists the diagnosis result with the symptom entry's ID linked

#### Scenario: View symptom history for a plant (unchanged)
- **WHEN** user opens a plant's detail page and navigates to "Symptom History" or the health timeline
- **THEN** the system displays all symptom entries for that plant in reverse chronological order

## ADDED Requirements

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
