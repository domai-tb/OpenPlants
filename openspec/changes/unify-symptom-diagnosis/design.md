## Context

SymptomLogger and Diagnosis are two independent clean-architecture page modules. SymptomLogger collects structured data (SymptomType, severity, parts, onset, soil moisture, light) persisted as JSON in SharedPreferences. Diagnosis runs a stateless rule engine (DiagnosisEngine) against a manually-entered DiagnosisContext and displays ephemeral results.

Both define their own symptom enums with overlapping but mismatched entries. The symptom logger's usecase (`logSymptom()`) has a single cross-module side-effect — it updates the plant's care status to `needsAttention` for severe symptoms. No other data flows between the two features.

Room profiles (`room_profiles` feature) store environmental data (humidity, light) per room, but diagnosis has no way to consume them.

This design bridges the gap with minimal architectural disruption: no new persistence backend, no BLoC, no state management changes.

## Goals / Non-Goals

**Goals:**
- Replace `SymptomType` and `PlantSymptom` with a single unified enum used by both features
- Auto-trigger diagnosis engine after symptom log submission, using logged data as input
- Persist diagnosis results as entities linked to plants (same SharedPreferences JSON pattern)
- Show a combined health timeline (symptom logs + diagnosis results) on the plant detail page
- Enrich auto-diagnosis context from room profiles when available
- Keep the standalone diagnosis questionnaire working (for More menu entry)

**Non-Goals:**
- Not introducing a local database (SQLite, Hive, etc.) — SharedPreferences JSON remains sufficient
- Not changing the diagnosis rule logic or adding new rules
- Not redesigning the questionnaire UI beyond what's needed for pre-filled symptoms
- Not adding push notifications or reminders based on diagnosis results
- Not building an ML-based alternative to the rule engine

## Decisions

### Decision 1: Adopt PlantSymptom as the unified enum, drop SymptomType
**Rationale**: Diagnosis's `PlantSymptom` is more fine-grained (13 values vs 9), which gives the rules more signal. The logger's values that have no diagnosis counterpart (`softStems`, `drySoil`, `wetSoil`, `leafSpots`) become new entries in the unified `PlantSymptom`. `drySoil`/`wetSoil` stay as symptom observations (not env context) for backward compat with existing log entries.

**Alternatives considered**: Keep both enums with a mapper → adds a translation layer with no long-term benefit. Merge into `SymptomType` → loses diagnosis granularity and breaks all rule logic.

### Decision 2: Auto-diagnosis runs synchronously in SymptomLoggerUseCases.logSymptom()
**Rationale**: The diagnosis engine is synchronous and fast (~1ms). The symptom logger already has a cross-module side-effect (care status update). Adding a diagnosis evaluation there follows the established pattern. The result is persisted, and the UI navigates to the result page.

**Alternatives considered**: Fire-and-forget from the UI layer → couples page to diagnosis. Event bus → over-engineering for a single consumer.

### Decision 3: Persist diagnosis results in SharedPreferences as JSON array
**Rationale**: Same pattern as symptom logger. DiagnosisResult gains a proper entity with `id`, `plantId`, `symptomLogEntryId` (nullable link), `scoredCauses`, and `createdAt`. No new dependencies. Migration: older results are ephemeral anyway so there's nothing to migrate.

**Alternatives considered**: Embed results inside the symptom log entry → breaks separation of concerns (diagnosis has its own entity lifecycle). SQLite → adds complexity before it's justified.

### Decision 4: Health timeline is a widget embedded in the plant detail page
**Rationale**: The plant detail page (`plant_collection_detail_page.dart`) already exists with a tab/section layout. Adding a health timeline section avoids a separate navigation step and keeps the plant as the hub for all health data.

**Alternatives considered**: Separate page → adds navigation friction. Bottom sheet → limited space for timeline content.

### Decision 5: Room profile enrichment is best-effort and optional
**Rationale**: Not all plants are assigned to a room with a profile, and room profiles are themselves optional (may have partial data). The auto-diagnosis uses room data when available but never blocks on it. The `DiagnosisContext` fields that aren't filled from room data or symptom log remain null, and the engine handles nulls gracefully (they contribute 0 to scores).

### Decision 6: Migration for existing symptom log entries
**Rationale**: Existing SharedPreferences data uses `SymptomType` enum names. On first load after upgrade, map old names to new `PlantSymptom` names. Add a `_schemaVersion` field to the symptom log data blob. If absent or < 2, apply the migration map. This keeps the data readable without a full data wipe.

## Risks / Trade-offs

- **[Risk] Enum rename breaks serialized data** → Mitigation: explicit migration map in the datasource `_loadAll()` method, keyed by schema version.
- **[Risk] SharedPreferences JSON blobs grow large** — over time, many symptom logs + diagnosis results accumulate in one or two JSON strings → Mitigation: acceptable at this scale (typical user has <50 entries per plant); if it becomes a problem, switch to Isar or drift later.
- **[Trade-off] Auto-diagnosis is mandatory after log** — users can't yet choose "just log, don't diagnose" → Acceptable because the result is persisted silently; the user can ignore it.
- **[Risk] Unified enum is a breaking change for tests** — ~11 test files reference the old enums → Mitigation: mechanical find-and-replace; most tests use diagnosis's `PlantSymptom` already.
- **[Trade-off] Result persistence is append-only with no pruning** → Acceptable for MVP; could add auto-pruning of results older than N months later.

### Data Model Summary

```
SymptomLogEntry (existing, modified)
├── id, plantId, symptomTypes (now List<PlantSymptom>), severity, affectedParts
├── onsetTiming, soilMoisture, lightConditions, notes, photoPath, createdAt
├── resolved, resolvedAt
└── diagnosisResultId (NEW — nullable link to DiagnosisResult)

DiagnosisResult (NEW)
├── id, plantId, symptomLogEntryId (nullable), createdAt
├── context: DiagnosisContext (snapshot of input)
└── result: DiagnosisResult (scored causes + type)
```

### Auto-Diagnosis Flow

```
SymptomLoggerUseCases.logSymptom(entry)
  │
  ├─ 1. Persist symptom log entry (existing)
  ├─ 2. Update plant care status if severe (existing)
  ├─ 3. Build DiagnosisContext:
  │       symptoms ← entry.symptomTypes (unified enum, direct)
  │       soilMoisture → wateringFrequency hint
  │       lightConditions → lightExposure hint
  │       roomId ← plant.roomId → load room profile → humidityLevel, lightExposure
  ├─ 4. Run DiagnosisEngine.evaluate(context)
  ├─ 5. Persist DiagnosisResult (link to symptomLogEntry.id)
  ├─ 6. Return (entry, result) tuple
  └─ [UI] Navigate to result page or show badge on timeline
```
