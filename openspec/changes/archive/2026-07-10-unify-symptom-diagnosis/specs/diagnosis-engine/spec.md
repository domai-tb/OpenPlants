# Diagnosis Engine — Delta

Modified capability. Changes sourced from original spec at `openspec/specs/diagnosis-engine/spec.md`.

## MODIFIED Requirements

### Requirement: Diagnosis rule engine evaluates user-provided context
The system SHALL provide a rule engine that takes a `DiagnosisContext` value object and returns a list of `ScoredCause` results. The `DiagnosisContext` SHALL accept symptom values from the unified `PlantSymptom` enum. The engine SHALL remain deterministic (same input → same output).

#### Scenario: Engine returns scored causes for valid context (modified symptom source)
- **WHEN** a `DiagnosisContext` with at least one symptom is provided to the engine (whether from the questionnaire or auto-built from a symptom log entry)
- **THEN** the engine SHALL return a list of `ScoredCause` results sorted by confidence descending

#### Scenario: Engine returns empty list for no symptoms (unchanged)
- **WHEN** a `DiagnosisContext` with zero symptoms is provided
- **THEN** the engine SHALL return an empty list

#### Scenario: Engine is deterministic (unchanged)
- **WHEN** the same `DiagnosisContext` is evaluated twice
- **THEN** both evaluations SHALL return identical results

### Requirement: Overwatering rule (modified symptom reference)
The system SHALL evaluate overwatering as a likely cause when symptoms include yellowing leaves, drooping/wilting with wet soil, or mold on soil surface, especially when combined with frequent watering and a pot without drainage holes.

#### Scenario: High confidence overwatering (unchanged logic, uses unified enum)
- **WHEN** symptoms include `yellowingLeaves` AND the user reports watering more than recommended AND the pot has no drainage holes
- **THEN** the engine SHALL return overwatering with high confidence

(Note: All remaining Overwatering / Underwatering / LowLight / Sunburn / LowHumidity / NutrientProblem / RootIssue / Pest rules are unchanged in logic. Only the enum reference changes from the old two-enum system to the unified `PlantSymptom`. Existing scenarios remain valid.)

## ADDED Requirements

### Requirement: DiagnosisContext can be built from symptom log data
The system SHALL provide a factory or constructor to build a `DiagnosisContext` from a `SymptomLogEntry`, mapping observed data to the context fields the engine expects.

#### Scenario: Map symptom types directly
- **WHEN** a `SymptomLogEntry` contains a list of `PlantSymptom` values
- **THEN** those values SHALL be passed as the `DiagnosisContext.symptoms` directly (no translation needed — same enum)

#### Scenario: Infer watering frequency from soil moisture
- **WHEN** a `SymptomLogEntry` reports `SoilMoisture.soggy` or `SoilMoisture.wet`
- **THEN** the system SHALL set `DiagnosisContext.wateringFrequency` to `WateringFrequency.frequent` as a hint
- **WHEN** soil moisture is `dry`, the system SHALL hint `WateringFrequency.infrequent`
- **WHEN** soil moisture is `moist` or null, the system SHALL leave `wateringFrequency` as null

#### Scenario: Infer light exposure from light condition
- **WHEN** a `SymptomLogEntry` reports `LightCondition.fullSun`
- **THEN** the system SHALL set `DiagnosisContext.lightExposure` to `LightExposure.direct`
- **WHEN** light condition is `partialShade`, the system SHALL set it to `LightExposure.indirect`
- **WHEN** light condition is `lowLight`, the system SHALL set it to `LightExposure.low`
- **WHEN** light condition is `unknown` or null, the system SHALL leave `lightExposure` as null

#### Scenario: Enrich context from room profile
- **WHEN** a plant is assigned to a room with an existing room profile
- **THEN** the system SHALL use the room's humidity level and light exposure to fill `DiagnosisContext.humidityLevel` and `DiagnosisContext.lightExposure` (may override the symptom-log-derived hint)
- **WHEN** the plant has no room or the room profile is incomplete
- **THEN** the system SHALL proceed with whatever data it has (all nulls are valid)

### Requirement: DiagnosisResult entity for persistence
The system SHALL provide a persisted `DiagnosisResult` entity that records the outcome of an engine evaluation, including the input context snapshot, scored causes, and optional link to a symptom log entry.

#### Scenario: Persist diagnosis result
- **WHEN** the engine evaluates a context (whether from questionnaire or auto-diagnosis)
- **THEN** the system SHALL create a `DiagnosisResult` entity with: id, plantId, optional symptomLogEntryId, createdAt, the full `DiagnosisContext` snapshot, and the full `DiagnosisResult` output

#### Scenario: Load diagnosis results for a plant
- **WHEN** viewing a plant's health timeline
- **THEN** the system SHALL load all `DiagnosisResult` entities for that plant in reverse chronological order
