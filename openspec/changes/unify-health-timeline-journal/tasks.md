## 1. Data Model: Extend JournalEntry entity

- [ ] 1.1 Add `symptom` and `diagnosis` values to `JournalEntryType` enum in `plant_journal_item_entity.dart`
- [ ] 1.2 Add optional `referenceId` (String?) field to `JournalEntry` for linking to symptom log or diagnosis result IDs
- [ ] 1.3 Add optional `structuredData` (Map<String, dynamic>?) field to `JournalEntry` for carrying type-specific rendering data
- [ ] 1.4 Update `JournalEntry.copyWith()` to handle the new fields
- [ ] 1.5 Update `JournalEntry.toJson()` / `fromJson()` to serialize/deserialize new fields
- [ ] 1.6 Ensure `fromJson` gracefully handles missing keys for backward compatibility with existing stored entries

## 2. Data Layer: Extend Journal datasource with merged loading

- [ ] 2.1 Add `SymptomLoggerDataSource` and `DiagnosisDataSource` as constructor dependencies of `PlantJournalDataSource`
- [ ] 2.2 Implement `getUnifiedTimeline(String plantId)` method that loads from all three stores (journal entries, symptom logs, diagnosis results) and merges them sorted by timestamp descending
- [ ] 2.3 Implement symptom-to-JournalEntry projection: maps `SymptomLogEntry` fields into `JournalEntry` with type `symptom`, populating `referenceId`, `structuredData` (symptom types, severity, affected parts, onset timing, resolved status, linked diagnosis ID), `notes`, `photoPath`, and `timestamp`
- [ ] 2.4 Implement diagnosis-to-JournalEntry projection: maps `DiagnosisResultEntity` fields into `JournalEntry` with type `diagnosis`, populating `referenceId`, `structuredData` (top cause, confidence, evidence summary, linked symptom ID), `notes`, and `timestamp`
- [ ] 2.5 Ensure linked symptom-diagnosis pairs carry bidirectional reference IDs for paired rendering
- [ ] 2.6 Update `PlantJournalRepository` to expose the new unified timeline method (delegate to datasource)

## 3. Business Logic: Update Journal usecases

- [ ] 3.1 Add `getUnifiedTimeline(String plantId)` method to `PlantJournalUseCases` that delegates to repository
- [ ] 3.2 Add `getLatestUnifiedEntry(String plantId)` helper (returns most recent entry across all types)
- [ ] 3.3 Add `getAllUnifiedTimeline()` cross-plant method (for potential today dashboard / notifications usage)

## 4. UI: Build health event card widgets

- [ ] 4.1 Create `journal_symptom_card.dart` widget that renders symptom-type entries (symptom type icons, severity badge, onset timing, affected parts, resolved/unresolved status, Mark Resolved action)
- [ ] 4.2 Create `journal_diagnosis_card.dart` widget that renders diagnosis-type entries (top cause name, confidence badge, evidence summary, date evaluated, link to source symptom)
- [ ] 4.3 Create `journal_linked_pair_card.dart` widget that visually groups a symptom entry with its linked diagnosis result (shows connector indicator)

## 5. UI: Update Journal page

- [ ] 5.1 Update `PlantJournalPage` to use `getUnifiedTimeline()` instead of the basic journal-only loading
- [ ] 5.2 Add entry-type routing in the page's `build` method to render the appropriate card for each `JournalEntryType` (existing types render as-is, `symptom` and `diagnosis` use the new widgets)
- [ ] 5.3 Add "Log Symptom" and "Diagnose" action buttons to the journal page header/empty state
- [ ] 5.4 Implement navigation: "Log Symptom" → opens SymptomLoggerPage, "Diagnose" → opens diagnosis questionnaire, diagnosis entry tap → opens DiagnosisResultPage
- [ ] 5.5 Update empty state message to mention health events alongside journal entries
- [ ] 5.6 Update the page title if needed (e.g., "Journal" → "Timeline" or keep "Journal")

## 6. DI Wiring: Update injection and services

- [ ] 6.1 Update `AppServices` — remove `plantHealthTimeline` field
- [ ] 6.2 Update `AppServices` constructor — remove `plantHealthTimeline` parameter
- [ ] 6.3 Update `injection.dart` — remove `PlantHealthTimeline` registration
- [ ] 6.4 Update `injection.dart` — pass `SymptomLoggerDataSource` and `DiagnosisDataSource` to journal datasource registration

## 7. Cleanup: Remove health timeline module

- [ ] 7.1 Delete `lib/pages/plant_health_timeline/plant_health_timeline_datasource.dart`
- [ ] 7.2 Delete `lib/pages/plant_health_timeline/plant_health_timeline_item_entity.dart`
- [ ] 7.3 Delete `lib/pages/plant_health_timeline/plant_health_timeline_page.dart`
- [ ] 7.4 Delete `lib/pages/plant_health_timeline/plant_health_timeline_repository.dart`
- [ ] 7.5 Delete `lib/pages/plant_health_timeline/plant_health_timeline_usecases.dart`
- [ ] 7.6 Delete `lib/pages/plant_health_timeline/widgets/timeline_entry_card.dart`
- [ ] 7.7 Delete `lib/pages/plant_health_timeline/widgets/` directory reference (if empty after deletion)
- [ ] 7.8 Search for any remaining imports of `plant_health_timeline` across the codebase and update them

## 8. Navigation: Update plant detail page

- [ ] 8.1 Search for all references to `PlantHealthTimelinePage` in the codebase (plant detail page, home screen, etc.)
- [ ] 8.2 Replace `PlantHealthTimelinePage` navigation with `PlantJournalPage` navigation
- [ ] 8.3 Update any references to "health timeline" text in the plant detail UI to point to "journal" or "timeline"

## 9. Localization: Update l10n keys

- [ ] 9.1 Search `assets/l10n/` for health-timeline-specific keys (e.g., `healthTimelineTitle`, `healthTimelineEmpty`, `healthTimelineEmptyHint`)
- [ ] 9.2 Retire or reassign health-timeline keys — either remove them if unused, or map them to journal-equivalent keys
- [ ] 9.3 Run `fvm flutter gen-l10n` to regenerate localization code
- [ ] 9.4 Remove any dead import references to retired l10n keys in the journal page

## 10. Validation

- [ ] 10.1 Run `fvm flutter analyze` — fix any lint errors (always_use_package_imports, unused imports, etc.)
- [ ] 10.2 Run `fvm flutter test` — ensure existing tests still pass
- [ ] 10.3 Update any existing test that references health timeline or journal APIs to reflect the merged approach
- [ ] 10.4 Add new test coverage for the journal datasource's merged timeline loading and entry projection logic
- [ ] 10.5 Run `fvm dart format --line-length=120 .` to ensure formatting compliance
