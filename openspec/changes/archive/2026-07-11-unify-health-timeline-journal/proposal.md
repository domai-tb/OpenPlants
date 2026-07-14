## Why

The app currently has two separate "timeline" views on the plant detail page — the Plant Journal (text notes, photos, tasks, growth updates, repotting, pest observations) and the Plant Health Timeline (symptom logs, diagnosis results). This split is confusing: users must switch between two separate sections to understand their plant's full story. A user logging a symptom or running a diagnosis naturally expects those events to appear in the plant's journal feed alongside other entries like "repotted on Tuesday" or "watered today". Keeping them separate creates a fractured UX and adds unnecessary code complexity.

## What Changes

- **Extend `JournalEntryType`** with new values `symptom` and `diagnosis` so symptom logs and diagnosis results appear as native journal entries.
- **Extend `JournalEntry` entity** with optional fields to carry symptom/diagnosis-specific data (severity, symptom types, causes, confidence, etc.) so the journal card can render them with full detail.
- **Merge health timeline data source into journal data source** — the journal's repository/datasource will load journal entries AND symptom logs AND diagnosis results, merging them into a single reverse-chronological feed.
- **Replace the standalone health timeline page** with an enhanced journal page that shows all entry types. Navigation that previously pointed to `PlantHealthTimelinePage` will point to the journal instead.
- **Remove the `plant_health_timeline/` feature module** (page, usecases, repository, datasource, entity, widgets) as its functionality is absorbed by the journal.
- **Update `AppServices`** to remove `PlantHealthTimelineUseCases` and add the merged entry loading to `PlantJournalUseCases`.

## Capabilities

### New Capabilities
- `unified-timeline`: A single journal timeline on the plant detail page that shows ALL plant events (text notes, photos, tasks, growth, repotting, pest observations, symptom logs, and diagnosis results) merged in reverse chronological order with type-appropriate rendering per entry.

### Modified Capabilities
- `plant-journal`: **REQUIREMENTS CHANGED** — JournalEntryType gains `symptom` and `diagnosis` values; JournalEntry entity gains optional structured data fields for symptom/diagnosis rendering; Journal datasource is extended to load symptom logs and diagnosis results; Journal page is enhanced to render all entry types with appropriate cards.
- `plant-health-timeline`: **REMOVED** — The standalone health timeline feature is deleted. Its purpose (showing symptom and diagnosis events) is absorbed into the unified journal timeline. The spec doc will be archived.
- `symptom-logger`: **REQUIREMENTS CHANGED** — Symptom entries no longer appear on a separate health timeline; they appear in the journal timeline. No change to symptom data model or logging flow.
- `diagnosis-engine`: **REQUIREMENTS CHANGED** — Diagnosis results no longer appear on a separate health timeline; they appear in the journal timeline. No change to diagnosis engine or persistence.

## Impact

- **Delete `lib/pages/plant_health_timeline/`** — entire feature module (5 files + 1 widget) removed.
- **Modify `lib/pages/plant_journal/`** — entity, datasource, repository, usecases, and page all updated.
- **Modify `lib/core/app_services.dart`** — remove `plantHealthTimeline` field, update `PlantJournalUseCases` to include merged timeline loading.
- **Modify `lib/core/injection.dart`** — remove `PlantHealthTimeline` registration, update journal registration.
- **Modify plant detail page** — replace `PlantHealthTimelinePage` navigation with journal entry points.
- **Modify localization files** — potentially retire or re-assign health-timeline-specific l10n keys.
- **New test coverage** needed for journal datasource's merged loading and rendering of symptom/diagnosis entries.
