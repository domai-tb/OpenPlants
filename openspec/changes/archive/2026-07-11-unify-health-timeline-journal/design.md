## Context

The app currently maintains two independent timeline-style features on the plant detail page:

- **Plant Journal** (`lib/pages/plant_journal/`) — manually created timestamped entries (text notes, photos, task completions, growth updates, repotting events, pest observations). Entity: `JournalEntry` with `JournalEntryType` enum. Persisted as JSON in SharedPreferences.
- **Plant Health Timeline** (`lib/pages/plant_health_timeline/`) — auto-generated feed merging symptom log entries (`SymptomLogEntry` from `lib/pages/symptom_logger/`) and diagnosis results (`DiagnosisResultEntity` from `lib/pages/diagnosis/`). Entity: `TimelineEntry` with `TimelineEntryType` enum. The datasource fetches from both `SymptomLoggerDataSource` and `DiagnosisDataSource` at query time and merges them.

These two features are functionally overlapping (both display reverse-chronological event feeds for a plant) but are implemented as completely separate feature modules with duplicated patterns (separate page widgets, usecases, repositories, datasources, entities). This creates UX fragmentation where users must jump between two timeline sections, and code maintenance overhead from the parallel implementations.

Diagnosis results (`DiagnosisResultEntity`) and symptom logs (`SymptomLogEntry`) are persisted independently and do NOT have corresponding `JournalEntry` records — the health timeline datasource loads them in-memory and projects them into `TimelineEntry` objects at query time.

## Goals / Non-Goals

**Goals:**
- A single unified journal timeline on the plant detail page that interleaves manually-created entries (notes, photos, tasks, etc.) with health events (symptom logs, diagnosis results) in reverse chronological order.
- Each entry type renders with an appropriate card UI (notes shown as notes, symptoms with severity/icons, diagnoses with causes/confidence).
- Remove the standalone `plant_health_timeline/` feature module.
- All existing data (journal entries, symptom logs, diagnosis results) continues to work with zero data migration.

**Non-Goals:**
- No changes to the symptom logging form or flow.
- No changes to the diagnosis engine or questionnaire flow.
- No changes to the care-schedule auto-journal entry feature.
- No changes to how symptom logs or diagnosis results are persisted.
- No addition of pagination beyond the current "load all" pattern.
- No web or iOS-specific changes (Android-only as per project scope).
- No bulk import/migration of existing health timeline data into journal entries (the merge happens at query time).

## Decisions

### Decision 1: Query-time merge, not dual-write

**Choice:** Extend the journal datasource to load from all three stores (journal entries, symptom logs, diagnosis results) and merge them at query time — exactly as the current health timeline datasource works, but also including journal entries.

**Rationale:**
- Symptom logs and diagnosis results are persisted independently with rich structured data (symptom types enum, severity, ScoredCause lists, DiagnosisContext snapshots) that would be lossy to duplicate into a simpler JournalEntry record.
- Dual-write (creating a JournalEntry whenever a symptom or diagnosis is persisted) adds transactional complexity and a migration burden for existing data.
- The query-time merge pattern is already proven in the codebase by the existing `PlantHealthTimelineDataSource` — we're simply expanding it to include journal entries.
- Zero data migration: existing persisted data continues to work unchanged.

**Alternatives considered:**
- *Dual-write at symptom/diagnosis creation time* — rejected because existing data would need migration and keeping two sources in sync adds failure modes.
- *Store everything as JournalEntry records with a JSON blob* — rejected because it loses the type safety and structured access to symptom/diagnosis fields.

### Decision 2: Extend JournalEntryType enum, not a new unified type

**Choice:** Add `symptom` and `diagnosis` values to the existing `JournalEntryType` enum. The `JournalEntry` entity gains optional `referenceId` and `structuredData` fields. The journal datasource returns a merged list where manually-created entries come from the journal store and health events are projected into `JournalEntry` objects at query time.

**Rationale:**
- Simpler API surface: consumers (page, widgets) work with a single typed list `List<JournalEntry>` instead of having to merge separate lists.
- The existing `JournalEntry` entity already has `id`, `plantId`, `type`, `timestamp`, `notes`, `photoPath` — symptom logs and diagnosis results map cleanly onto these (symptom notes → `notes`, symptom photo → `photoPath`, symptom createdAt → `timestamp`).
- Adding `referenceId` and `structuredData` as optional fields keeps the entity clean for simple entry types while enabling rich rendering for health events.

**Alternatives considered:**
- *Sealed union / freezed sealed class* — cleaner type safety but introduces a new dependency and would require rewriting the entire journal page. Overkill for this change.
- *Parallel lists (journal, symptoms, diagnoses) merged in page* — puts presentation logic in the widget layer, violating Clean Architecture.

### Decision 3: Keep SymptomLogger and Diagnosis datasources as dependencies of Journal datasource

**Choice:** The journal datasource will depend on `SymptomLoggerDataSource` and `DiagnosisDataSource` (as the health timeline datasource currently does) to load health events for merging. The journal datasource does NOT need access to symptom/diagnosis *repositories* — direct datasource access suffices for read-only projection.

**Rationale:**
- Avoids circular dependencies (symptom_logger and diagnosis have no dependency on the journal).
- The health timeline datasource already depends on both, so this wiring pattern is established in `injection.dart`.
- Only read operations are needed — creating/updating symptom or diagnosis entries continues to go through their own usecases.

## Risks / Trade-offs

- **[Performance] Loading all three stores on every timeline view** — Acceptable: typical user data is under 100 journal entries + under 50 symptom logs + under 50 diagnoses. The current health timeline already loads symptoms + diagnoses this way. No pagination needed yet.
- **[Data consistency] Query-time merge means symptom/diagnosis edits immediately reflect in the timeline** — This is actually a benefit, not a risk. If a symptom is marked resolved, it shows as resolved in the journal timeline immediately.
- **[Removal risk] Deleting plant_health_timeline/ may miss a reference** — Mitigation: thorough search for all imports and navigation references to `PlantHealthTimelinePage`, `PlantHealthTimelineUseCases`, `PlantHealthTimelineRepository`, etc. before deletion. Use `dart analyze` to verify no dangling imports.
- **[L10n risk] Health timeline localization keys may still be referenced** — Mitigation: audit all health-timeline l10n keys in `assets/l10n/` after page removal. Retire unused keys.
- **[UI regression] The existing TimelineEntryCard widget is deleted with the module** — Mitigation: build the symptom and diagnosis card UI directly into the journal page using the extended JournalEntry, reusing visual patterns from the existing timeline_entry_card.dart.

## Open Questions

1. Should the journal page show a filter toggle (as the health timeline currently does with "Active" / "Show All") or keep the simpler unfiltered view of the current journal? **Decision for implementation:** Keep the current journal's simpler approach (no filter) for the MVP merge; the health timeline's "Active" filter can be added later as a separate enhancement.
2. Should linked symptom-diagnosis pairs be visually grouped (as the health timeline currently pairs them)? **Decision:** Yes — when a symptom entry has a `diagnosisResultId`, the diagnosis entry that follows should indicate the relationship. Visual approach: a subtle connector line or a "Diagnosis from symptom" label on the diagnosis card.
