# Diagnosis Engine

## Purpose

Rule-based plant diagnosis engine that evaluates user-provided symptom and context information to identify likely causes of plant health issues.

## Requirements

### Requirement: Diagnosis rule engine evaluates user-provided context
The system SHALL provide a rule engine that takes a `DiagnosisContext` value object and returns a list of `ScoredCause` results. The `DiagnosisContext` SHALL accept symptom values from the unified `PlantSymptom` enum. Each `ScoredCause` SHALL contain: cause identifier, confidence level (low/medium/high), evidence summary, recommended actions, and follow-up checks. The engine SHALL remain deterministic (same input → same output).

#### Scenario: Engine returns scored causes for valid context
- **WHEN** a `DiagnosisContext` with at least one symptom is provided to the engine (whether from the questionnaire or auto-built from a symptom log entry)
- **THEN** the engine SHALL return a list of `ScoredCause` results sorted by confidence descending

#### Scenario: Engine returns empty list for no symptoms
- **WHEN** a `DiagnosisContext` with zero symptoms is provided
- **THEN** the engine SHALL return an empty list

#### Scenario: Engine is deterministic
- **WHEN** the same `DiagnosisContext` is evaluated twice
- **THEN** both evaluations SHALL return identical results

### Requirement: Overwatering rule
The system SHALL evaluate overwatering as a likely cause when symptoms include yellowing leaves, drooping/wilting with wet soil, or mold on soil surface, especially when combined with frequent watering and a pot without drainage holes.

#### Scenario: High confidence overwatering
- **WHEN** symptoms include yellowing leaves AND the user reports watering more than recommended AND the pot has no drainage holes
- **THEN** the engine SHALL return overwatering with high confidence

#### Scenario: Medium confidence overwatering
- **WHEN** symptoms include drooping leaves AND the user reports the soil stays wet between waterings
- **THEN** the engine SHALL return overwatering with at least medium confidence

#### Scenario: Low confidence overwatering
- **WHEN** the only symptom is yellowing leaves with no other contextual signals
- **THEN** the engine MAY return overwatering with low confidence if other symptoms do not match better

### Requirement: Underwatering rule
The system SHALL evaluate underwatering as a likely cause when symptoms include drooping/wilting with dry soil, crispy brown leaf tips, or leaf curling, especially when watering is infrequent or the plant is in a porous pot.

#### Scenario: High confidence underwatering
- **WHEN** symptoms include drooping leaves AND the user reports dry soil AND watering schedule is infrequent
- **THEN** the engine SHALL return underwatering with high confidence

#### Scenario: Medium confidence underwatering
- **WHEN** symptoms include crispy brown leaf tips AND the user reports infrequent watering
- **THEN** the engine SHALL return underwatering with at least medium confidence

### Requirement: Low light rule
The system SHALL evaluate low light as a likely cause when symptoms include leggy growth, small new leaves, or leaves turning pale, especially when the plant is placed in a low-light location or far from windows.

#### Scenario: High confidence low light
- **WHEN** symptoms include leggy growth AND the user reports the plant receives low indirect light or is placed far from windows
- **THEN** the engine SHALL return low light with high confidence

#### Scenario: Medium confidence low light
- **WHEN** symptoms include pale leaves AND the plant is in a low-light location
- **THEN** the engine SHALL return low light with at least medium confidence

### Requirement: Sunburn rule
The system SHALL evaluate sunburn as a likely cause when symptoms include brown/white scorched patches on leaves, especially on plants that prefer indirect light placed in direct sun or near south-facing windows without filtering.

#### Scenario: High confidence sunburn
- **WHEN** symptoms include scorched leaf patches AND the plant species prefers indirect light AND the plant receives direct sunlight
- **THEN** the engine SHALL return sunburn with high confidence

#### Scenario: Medium confidence sunburn
- **WHEN** symptoms include scorched leaf patches AND the plant is near a south-facing window
- **THEN** the engine SHALL return sunburn with at least medium confidence

### Requirement: Low humidity rule
The system SHALL evaluate low humidity as a likely cause when symptoms include brown leaf tips and edges, especially on tropical species placed in dry indoor environments (low humidity, near heating/AC vents).

#### Scenario: High confidence low humidity
- **WHEN** symptoms include brown leaf tips AND the plant species prefers high humidity AND the user reports low room humidity
- **THEN** the engine SHALL return low humidity with high confidence

#### Scenario: Medium confidence low humidity
- **WHEN** symptoms include brown leaf edges AND the user reports dry air or heating/AC vents nearby
- **THEN** the engine SHALL return low humidity with at least medium confidence

### Requirement: Nutrient problem rule
The system SHALL evaluate nutrient problems as a likely cause when symptoms include yellowing between leaf veins, pale new growth, or slow growth, especially when fertilizing has not been done recently or the plant has been in the same pot for a long time.

#### Scenario: High confidence nutrient problem
- **WHEN** symptoms include yellowing between leaf veins AND the user has not fertilized in over 3 months
- **THEN** the engine SHALL return nutrient problem with high confidence

#### Scenario: Medium confidence nutrient problem
- **WHEN** symptoms include pale new growth AND the plant has not been repotted recently
- **THEN** the engine SHALL return nutrient problem with at least medium confidence

### Requirement: Root issue rule
The system SHALL evaluate root issues as a likely cause when symptoms include wilting despite moist soil, stunted growth, or foul smell from soil, especially with a history of overwatering or compacted soil.

#### Scenario: High confidence root issue
- **WHEN** symptoms include wilting despite moist soil AND a foul smell is reported AND the plant has a history of overwatering
- **THEN** the engine SHALL return root issue with high confidence

#### Scenario: Medium confidence root issue
- **WHEN** symptoms include stunted growth AND the soil is compacted or drainage is poor
- **THEN** the engine SHALL return root issue with at least medium confidence

### Requirement: Pest rule
The system SHALL evaluate pests as a likely cause when symptoms include visible insects, sticky residue on leaves, webbing, or small spots/holes on leaves.

#### Scenario: High confidence pests
- **WHEN** symptoms include visible insects AND webbing on the plant
- **THEN** the engine SHALL return pests with high confidence

#### Scenario: Medium confidence pests
- **WHEN** symptoms include sticky residue on leaves OR small holes in leaves
- **THEN** the engine SHALL return pests with at least medium confidence

### Requirement: No-clear-match fallback
The system SHALL return a "No clear match" result when the highest confidence score across all rules is below a defined threshold.

#### Scenario: Fallback displayed for weak matches
- **WHEN** all rules score below the minimum threshold
- **THEN** the engine SHALL return a "No clear match" result with general plant care suggestions

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
