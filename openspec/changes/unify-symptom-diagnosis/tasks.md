## 1. Foundation — Unified Symptom Enum

- [ ] 1.1 Define unified `PlantSymptom` enum merging `SymptomType` values (`softStems`, `leafSpots`) into the existing `PlantSymptom` in `diagnosis_item_entity.dart`, removing `SymptomType` from `symptom_logger_item_entity.dart`
- [ ] 1.2 Update `SymptomLogEntry` entity to use `List<PlantSymptom>` instead of `List<SymptomType>`, adjust `toJson()`/`fromJson()` serialization
- [ ] 1.3 Update `SymptomLoggerExtensions` (`symptom_logger_extensions.dart`) to reference `PlantSymptom` instead of `SymptomType` for icons, labels, colors
- [ ] 1.4 Update symptom logger page (`symptom_logger_page.dart`) — all `SymptomType` references → `PlantSymptom`, update `_buildSymptomTypeStep()` to iterate `PlantSymptom.values`
- [ ] 1.5 Update diagnosis engine (`diagnosis_usecases.dart`) — remove old standalone `PlantSymptom` definition (now unified), ensure `_symptomLabel()` covers all unified values including new additions
- [ ] 1.6 Update diagnosis page (`diagnosis_page.dart`) — ensure symptom chip list uses unified `PlantSymptom.values`
- [ ] 1.7 Update all affected test files — import paths, enum value renames (`yellowLeaves`→`yellowingLeaves`, `drooping`→`droopingWilt`, `brownTips` stays, `pests`→`visibleInsects` etc.)
- [ ] 1.8 Add schema version migration in `SymptomLoggerDataSource._loadAll()` — detect old `SymptomType` names and map to new `PlantSymptom` equivalents

## 2. Core — DiagnosisResult Persistence

- [ ] 2.1 Add `DiagnosisResultEntity` class to `diagnosis_item_entity.dart` with fields: `id`, `plantId`, `symptomLogEntryId` (nullable), `createdAt`, `contextSnapshot` (serialized DiagnosisContext), `scoredCauses` (serialized list), `resultType`
- [ ] 2.2 Create `DiagnosisDataSource` with CRUD methods: `save(DiagnosisResultEntity)`, `getAllByPlant(String plantId)`, `getById(String id)`, `delete(String id)` — SharedPreferences JSON pattern
- [ ] 2.3 Create `DiagnosisRepository` methods for persistence: `saveResult()`, `loadResultsByPlant()`, `loadResult()` in addition to existing `evaluate()`
- [ ] 2.4 Register `DiagnosisDataSource` and updated `DiagnosisRepository` in `lib/core/injection.dart`
- [ ] 2.5 Update `AppServices` if needed to expose new persistence methods

## 3. Feature — Auto-Diagnosis Hook

- [ ] 3.1 Add `DiagnosisContext` factory constructor `fromSymptomLogEntry(SymptomLogEntry entry, {RoomProfile? roomProfile})` that maps: symptom types directly, soil moisture → watering frequency hint, light conditions → light exposure hint
- [ ] 3.2 Update `SymptomLoggerUseCases.logSymptom()` to: persist entry (existing), run `DiagnosisEngine.evaluate()` with context built from entry, persist result, link result ID back to entry, return enhanced result
- [ ] 3.3 Add room profile enrichment — look up plant's assigned room, load `RoomProfile`, populate `humidityLevel` and `lightExposure` on the `DiagnosisContext`
- [ ] 3.4 Update `SymptomLogEntry` to include optional `diagnosisResultId` field, update serialization
- [ ] 3.5 Wire auto-diagnosis into the symptom logger page — after successful `_submit()`, if a diagnosis result was generated, show snackbar with "View Diagnosis" action navigating to the result page

## 4. Feature — Standalone Diagnosis Persistence

- [ ] 4.1 Add "Save to plant history" button to `DiagnosisResultPage` when the diagnosis was started from manual questionnaire
- [ ] 4.2 Implement save flow — prompt plant selection if result wasn't linked to a specific plant, persist via `DiagnosisRepository.saveResult()`
- [ ] 4.3 When diagnosis is triggered from plant detail / timeline, auto-associate result with that plant (no plant selection prompt)

## 5. UI — Plant Health Timeline

- [ ] 5.1 Create `PlantHealthTimelineWidget` — section widget for plant detail page that loads and merges symptom logs + diagnosis results for the plant
- [ ] 5.2 Implement timeline entry rendering — distinct card layouts for symptom log entries (icons, severity badge, resolved status) and diagnosis results (top cause, confidence badge, evidence)
- [ ] 5.3 Add filter controls to timeline — "All" / "Active" toggle
- [ ] 5.4 Add empty state for timeline when no health events exist
- [ ] 5.5 Add "Log Symptom" and "Diagnose" action buttons to timeline header
- [ ] 5.6 Implement "Mark Resolved" on symptom log entries inline in the timeline
- [ ] 5.7 Integrate timeline widget into `PlantCollectionDetailPage` — add as a new section/tab
- [ ] 5.8 Link timeline entries — tap symptom → navigate to symptom detail/edit, tap diagnosis → navigate to persisted result page

## 6. UI — Navigate to Persisted Results

- [ ] 6.1 Create `PersistedDiagnosisResultPage` or adapt existing `DiagnosisResultPage` to accept a persisted `DiagnosisResultEntity` and render it with the same layout, showing source and timestamp
- [ ] 6.2 Add navigation from timeline diagnosis entry → persisted result page
- [ ] 6.3 Add "View linked symptom" link from diagnosis result back to the originating symptom log entry

## 7. Localization & Polish

- [ ] 7.1 Add l10n strings for timeline UI: section title, filter labels, empty state, "Mark Resolved", "View Diagnosis", "Save to plant history", "Auto-diagnosis", source labels
- [ ] 7.2 Run `fvm flutter gen-l10n` to regenerate localization code
- [ ] 7.3 Review and update German translations (`l10n_de.arb`) for new strings

## 8. Tests

- [ ] 8.1 Update existing `plant_journal_usecases_test.dart` and other tests that reference old enum values
- [ ] 8.2 Add unit tests for `DiagnosisContext.fromSymptomLogEntry()` — mapping correctness for all symptom types, soil moisture, light conditions
- [ ] 8.3 Add unit tests for auto-diagnosis in symptom logger — verify engine is called with correct context after logSymptom()
- [ ] 8.4 Add unit tests for `DiagnosisDataSource` — save/load/delete of persisted results
- [ ] 8.5 Add unit tests for timeline data merging — correct interleaving and chronological sort
- [ ] 8.6 Add widget test for health timeline empty state and populated state
- [ ] 8.7 Run `fvm flutter analyze` and resolve any lint issues
- [ ] 8.8 Run `fvm flutter test` and verify all tests pass
