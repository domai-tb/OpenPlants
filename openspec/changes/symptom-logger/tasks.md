## 1. Data Layer

- [ ] 1.1 Create `symptom_logger_item_entity.dart` with `SymptomLogEntry` class: id, plantId, symptomTypes (List<SymptomType>), severity, affectedParts, onsetTiming, soilMoisture, lightConditions, notes, photoPath, createdAt, resolved, resolvedAt
- [ ] 1.2 Define enums: `SymptomType` (yellowLeaves, brownTips, drooping, pests, mold, softStems, drySoil, wetSoil, leafSpots), `Severity` (mild, moderate, severe), `AffectedPart` (leaves, stems, roots, soil, flowers, multipleAreas), `OnsetTiming` (today, fewDaysAgo, aboutAWeekAgo, moreThanAWeekAgo), `SoilMoisture` (dry, moist, wet, soggy), `LightCondition` (fullSun, partialShade, lowLight, unknown)
- [ ] 1.3 Create `symptom_logger_datasource.dart` with local storage: save, getAllByPlant, update, delete operations using SharedPreferences JSON serialization
- [ ] 1.4 Create `symptom_logger_repository.dart` mapping raw JSON to/from `SymptomLogEntry` entities
- [ ] 1.5 Create `symptom_logger_usecases.dart`: LogSymptom, GetSymptomHistory, MarkResolved, SaveDraft, GetDraft, DeleteDraft

## 2. UI — Symptom Logger Page

- [ ] 2.1 Create `symptom_logger_page.dart` as StatefulWidget with multi-step form flow
- [ ] 2.2 Build Step 1: Symptom type selection grid (multi-select chips with icons)
- [ ] 2.3 Build Step 2: Severity selector (mild/moderate/severe radio options)
- [ ] 2.4 Build Step 3: Affected parts multi-select (leaves, stems, roots, soil, flowers, multiple areas)
- [ ] 2.5 Build Step 4: Onset timing selector (radio options)
- [ ] 2.6 Build Step 5: Environmental observations — soil moisture and light condition selectors
- [ ] 2.7 Build Step 6: Optional notes text field (500 char max) and photo attachment button (reuses camera-capture)
- [ ] 2.8 Build Step 7: Review screen showing all collected data before submission
- [ ] 2.9 Implement step navigation (next/back), validation per step, and form progress indicator
- [ ] 2.10 Implement draft auto-save on step transitions and draft resume on page load

## 3. UI — Symptom History

- [ ] 3.1 Add "Symptom History" section to plant detail page showing all entries in reverse chronological order
- [ ] 3.2 Display each entry with: symptom icons, severity badge, affected parts, date, resolved status
- [ ] 3.3 Add "Mark Resolved" button on unresolved entries with confirmation dialog
- [ ] 3.4 Show photo thumbnail if photo is attached to an entry

## 4. Care Tracking Integration

- [ ] 4.1 Add symptom log events to the care-tracking timeline with distinct icon and color
- [ ] 4.2 Update care status logic: severe symptom entry auto-sets plant status to `needs_attention`
- [ ] 4.3 Add `needs_attention` to the care status enum in the existing care-tracking entity

## 5. Navigation & DI

- [ ] 5.1 Register SymptomLoggerDataSource, SymptomLoggerRepository, SymptomLoggerUseCases in `injection.dart` as lazy singletons
- [ ] 5.2 Add SymptomLoggerUseCases to `AppServices` constructor and field
- [ ] 5.3 Add "Log Symptom" navigation entry in home/more page
- [ ] 5.4 Add "Log Symptom" action button on plant detail page

## 6. Validation & Polish

- [ ] 6.1 Run `fvm flutter analyze` — fix all lint violations
- [ ] 6.2 Run `fvm flutter test` — ensure no regressions
- [ ] 6.3 Add localization strings for symptom logger UI in `assets/l10n/l10n_en.arb` and run `fvm flutter gen-l10n`
- [ ] 6.4 Format all new files with `fvm dart format --line-length=120 .`
