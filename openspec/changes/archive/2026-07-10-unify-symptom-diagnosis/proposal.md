## Why

Symptom logging and diagnosis currently exist as separate islands — the symptom logger collects rich structured data (symptom type, severity, onset, soil moisture, light conditions) but never feeds it into the diagnosis engine. Users must manually re-enter symptoms and context in a separate questionnaire to get a diagnosis. This creates friction, data duplication, and a fragmented picture of plant health. Worse, diagnosis results are ephemeral — they're shown once on a result page and then lost, making it impossible to track health trends over time.

## What Changes

- **Unified symptom vocabulary**: Replace `SymptomType` (symptom logger) and `PlantSymptom` (diagnosis) with a single `PlantSymptom` enum used by both features. Merge overlapping entries, fill gaps, and adopt diagnosis's more fine-grained vocabulary. **BREAKING** — both enums are removed; all references migrate to the unified enum.

- **Auto-diagnosis on symptom log**: When a user completes the 7-step symptom logger form, the system automatically builds a `DiagnosisContext` from the logged data (mapping symptoms, inferring environmental context from soil moisture and light conditions) and runs the diagnosis engine. The result is persisted.

- **Persisted diagnosis results**: `DiagnosisResult` gains a proper entity with persistence (JSON in SharedPreferences, same pattern as symptom logs), linked to a plant and optionally to its originating symptom log entry.

- **Plant health timeline**: A new timeline view on the plant detail page shows symptom log entries and diagnosis results together in reverse chronological order. Users can see logged symptoms, see what the engine diagnosed, mark symptoms resolved, and track changes over time.

- **Diagnosis triggered from the timeline**: From the health timeline, users can tap "Diagnose" to run the engine against their currently active (unresolved) symptoms, or tap a specific symptom to diagnose from that entry.

- **Diagnosis enriches from room profiles**: When running auto-diagnosis, the system pulls in environmental context from the plant's assigned room profile (humidity, light exposure) if available, reducing what the user needs to fill in manually.

## Capabilities

### New Capabilities

- `plant-health-timeline`: Combined reverse-chronological view of symptom logs and diagnosis results on the plant detail page, with filtering (active/resolved), resolución marking, and entry points for diagnosis.

### Modified Capabilities

- `symptom-logger`: Symptoms SHALL be recorded using the unified `PlantSymptom` enum. After each symptom log submission, the system SHALL auto-trigger diagnosis with the collected data. The symptom log entry SHALL link to the resulting diagnosis.

- `diagnosis-engine`: The engine SHALL consume the unified `PlantSymptom` enum. The `DiagnosisContext` SHALL accept environmental data from logged symptom entries (soil moisture → watering context, light conditions → light exposure) as an alternative to questionnaire input. Rules SHALL remain unchanged in their logic.

- `diagnosis-ui`: The questionnaire page SHALL remain functional for standalone diagnosis (from More menu) but SHALL also accept pre-filled symptom data from the symptom logger or timeline. A new "Diagnosis from symptoms" flow SHALL skip the symptom selection step when symptoms are pre-supplied. The result page SHALL offer to persist results. The plant detail page SHALL gain a health timeline section.

## Impact

- **Files modified**: `symptom_logger_item_entity.dart` (SymptomType → PlantSymptom), `diagnosis_item_entity.dart` (PlantSymptom unified), `symptom_logger_usecases.dart` (auto-diagnosis hook), `diagnosis_usecases.dart` (context enrichment), `diagnosis_repository.dart` (persistence), `plant_collection_detail_page.dart` (timeline), `injection.dart` (new registrations)
- **Files created**: `diagnosis_result_entity.dart`, `plant_health_timeline_widget.dart`, possibly `plant_health_datasource.dart`/`repository.dart`
- **Files removed**: None — `SymptomType` is replaced in-place, `PlantSymptom` is replaced in-place
- **Tests**: ~11 existing test files may need updates for enum changes; new tests needed for auto-diagnosis hook, persistence, timeline
- **Localization**: New strings for timeline UI, auto-diagnosis messaging, persisted result labels
- **Data**: Existing symptom log entries in SharedPreferences use `SymptomType` names in JSON — migration needed on first read after upgrade
