# Diagnosis Engine — Delta Spec

## MODIFIED Requirements

### Requirement: DiagnosisResult entity for persistence
The system SHALL provide a persisted `DiagnosisResult` entity that records the outcome of an engine evaluation, including the input context snapshot, scored causes, and optional link to a symptom log entry.

#### Scenario: Persist diagnosis result
- **WHEN** the engine evaluates a context (whether from questionnaire or auto-diagnosis)
- **THEN** the system SHALL create a `DiagnosisResult` entity with: id, plantId, optional symptomLogEntryId, createdAt, the full `DiagnosisContext` snapshot, and the full `DiagnosisResult` output

#### Scenario: Load diagnosis results for a plant
- **WHEN** viewing a plant's journal timeline
- **THEN** the system SHALL load all `DiagnosisResult` entities for that plant in reverse chronological order for display within the unified timeline
