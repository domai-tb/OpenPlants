## 1. Data Layer

- [x] 1.1 Create `symptom_logger_item_entity.dart` with `SymptomLogEntry` class: id, plantId, symptomTypes (List<SymptomType>), severity, affectedParts, onsetTiming, soilMoisture, lightConditions, notes, photoPath, createdAt, resolved, resolvedAt
- [x] 1.2 Define enums: `SymptomType` (yellowLeaves, brownTips, drooping, pests, mold, softStems, drySoil, wetSoil, leafSpots), `Severity` (mild, moderate, severe), `AffectedPart` (leaves, stems, roots, soil, flowers, multipleAreas), `OnsetTiming` (today, fewDaysAgo, aboutAWeekAgo, moreThanAWeekAgo), `SoilMoisture` (dry, moist, wet, soggy), `LightCondition` (fullSun, partialShade, lowLight, unknown)
- [x] 1.3 Create `symptom_logger_datasource.dart` with local storage: save, getAllByPlant, update, delete operations using SharedPreferences JSON serialization
- [x] 1.4 Create `symptom_logger_repository.dart` mapping raw JSON to/from `SymptomLogEntry` entities
- [x] 1.5 Create `symptom_logger_usecases.dart`: LogSymptom, GetSymptomHistory, MarkResolved, SaveDraft, GetDraft, DeleteDraft

## 2. UI — Symptom Logger Page

- [x] 2.1 Create `symptom_logger_page.dart` as StatefulWidget with multi-step form flow
- [x] 2.2 Build Step 1: Symptom type selection grid (multi-select chips with icons)
- [x] 2.3 Build Step 2: Severity selector (mild/moderate/severe radio options)
- [x] 2.4 Build Step 3: Affected parts multi-select (leaves, stems, roots, soil, flowers, multiple areas)
- [x] 2.5 Build Step 4: Onset timing selector (radio options)
- [x] 2.6 Build Step 5: Environmental observations — soil moisture and light condition selectors
- [x] 2.7 Build Step 6: Optional notes text field (500 char max) and photo attachment button (reuses camera-capture)
- [x] 2.8 Build Step 7: Review screen showing all collected data before submission
- [x] 2.9 Implement step navigation (next/back), validation per step, and form progress indicator
- [x] 2.10 Implement draft auto-save on step transitions and draft resume on page load

## 3. UI — Symptom History

- [x] 3.1 Add "Symptom History" section to plant detail page showing all entries in reverse chronological order
- [x] 3.2 Display each entry with: symptom icons, severity badge, affected parts, date, resolved status
- [x] 3.3 Add "Mark Resolved" button on unresolved entries with confirmation dialog
- [x] 3.4 Show photo thumbnail if photo is attached to an entry

## 4. Care Tracking Integration

- [x] 4.1 Add symptom log events to the care-tracking timeline with distinct icon and color
- [x] 4.2 Update care status logic: severe symptom entry auto-sets plant status to `needs_attention`
- [x] 4.3 Add `needs_attention` to the care status enum in the existing care-tracking entity

## 5. Navigation & DI

- [x] 5.1 Register SymptomLoggerDataSource, SymptomLoggerRepository, SymptomLoggerUseCases in `injection.dart` as lazy singletons
- [x] 5.2 Add SymptomLoggerUseCases to `AppServices` constructor and field
- [x] 5.3 Add "Log Symptom" navigation entry in home/more page
- [x] 5.4 Add "Log Symptom" action button on plant detail page

## 6. Validation & Polish

- [x] 6.1 Run `fvm flutter analyze` — fix all lint violations
- [x] 6.2 Run `fvm flutter test` — ensure no regressions
- [x] 6.3 Add localization strings for symptom logger UI in `assets/l10n/l10n_en.arb` and run `fvm flutter gen-l10n`
- [x] 6.4 Format all new files with `fvm dart format --line-length=120 .`
