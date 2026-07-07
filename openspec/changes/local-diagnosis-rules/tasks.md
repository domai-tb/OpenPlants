## 1. Entity & Data Model

- [ ] 1.1 Create `diagnosis_item_entity.dart` with `DiagnosisContext` value object (symptoms list, plant species, pot type, soil type, watering frequency, light exposure, humidity level, recent fertilizing, pest signs)
- [ ] 1.2 Add `ScoredCause` entity with cause identifier, confidence level enum (low/medium/high), evidence summary string, recommended actions list, and follow-up checks list
- [ ] 1.3 Add symptom enum (`PlantSymptom`) with values: yellowing leaves, drooping/wilting, brown tips/crispy edges, brown patches/scorched spots, pale leaves, leggy growth, visible insects/webs, sticky residue, mold on soil, foul smell, stunted growth, leaf curling, leaf drop
- [ ] 1.4 Add context enums for pot type, soil type, watering frequency, light exposure, humidity level

## 2. Datasource & Repository

- [ ] 2.1 Create `diagnosis_datasource.dart` (empty/minimal — all rules are pure logic, datasource is a placeholder for future extensibility)
- [ ] 2.2 Create `diagnosis_repository.dart` with a single method `evaluate(DiagnosisContext) → DiagnosisResult` that delegates to the usecases layer

## 3. Rule Engine (UseCases)

- [ ] 3.1 Create `diagnosis_usecases.dart` with `DiagnosisEngine` class containing a `evaluate(DiagnosisContext)` method that returns a list of `ScoredCause`
- [ ] 3.2 Implement base `DiagnosisRule` abstract class with `score(DiagnosisContext) → double` method and `confidenceFromScore(double) → ConfidenceLevel` helper
- [ ] 3.3 Implement `OverwateringRule`: scores high when symptoms include yellowing/drooping + wet soil + frequent watering + no drainage holes
- [ ] 3.4 Implement `UnderwateringRule`: scores high when symptoms include drooping/brown tips + dry soil + infrequent watering
- [ ] 3.5 Implement `LowLightRule`: scores high when symptoms include leggy growth/pale leaves + low light location
- [ ] 3.6 Implement `SunburnRule`: scores high when symptoms include scorched patches + plant in direct sun + species prefers indirect light
- [ ] 3.7 Implement `LowHumidityRule`: scores high when symptoms include brown tips/edges + low humidity + tropical species
- [ ] 3.8 Implement `NutrientProblemRule`: scores high when symptoms include yellowing between veins/pale growth + no recent fertilizing
- [ ] 3.9 Implement `RootIssueRule`: scores high when symptoms include wilting despite moist soil + foul smell + overwatering history
- [ ] 3.10 Implement `PestRule`: scores high when symptoms include visible insects/webs/sticky residue/holes
- [ ] 3.11 Implement `NoClearMatchFallback` that returns general suggestions when all rules score below threshold
- [ ] 3.12 wire all rules into the `DiagnosisEngine` constructor as a list; `evaluate()` iterates rules, collects scores, sorts descending, filters by threshold

## 4. Diagnosis Page (Questionnaire)

- [ ] 4.1 Create `diagnosis_page.dart` as a `StatefulWidget` with a multi-step questionnaire form
- [ ] 4.2 Implement symptom selection step with a multi-select list of `PlantSymptom` values (checkboxes with icons)
- [ ] 4.3 Implement plant context step with dropdown fields for watering frequency, light exposure, humidity level, pot type, soil type
- [ ] 4.4 Implement additional questions: recent fertilizing toggle, pest signs toggle, optional species selector
- [ ] 4.5 Add progress indicator showing step X of N
- [ ] 4.6 Add "Start diagnosis" button that collects all answers, builds `DiagnosisContext`, calls the engine, and navigates to results
- [ ] 4.7 Add loading indicator during evaluation (brief — synchronous evaluation)

## 5. Diagnosis Result Page

- [ ] 5.1 Create `DiagnosisResultPage` that displays the ranked list of `ScoredCause` from the engine
- [ ] 5.2 Implement cause card widget showing cause name, confidence badge (color-coded: high=green, medium=amber, low=gray), and evidence explanation in plain language
- [ ] 5.3 Implement expandable sections on each card for "Recommended actions" and "Follow-up checks"
- [ ] 5.4 Implement "No clear match" fallback view with general plant care suggestions
- [ ] 5.5 Add disclaimer text: "This is a suggestion based on the information you provided..."
- [ ] 5.6 Add "Start over" button to restart the questionnaire

## 6. Navigation & Integration

- [ ] 6.1 Add "Plant Diagnosis" entry to the More/bottom-sheet menu in `home_page.dart`
- [ ] 6.2 Add "Diagnose this plant" button on the plant detail page that pre-fills plant context
- [ ] 6.3 Register datasource, repository, and usecases as lazy singletons in `lib/core/injection.dart`
- [ ] 6.4 Add diagnosis usecases to `AppServices` in `app_services.dart`
- [ ] 6.5 Verify navigation works: More menu → questionnaire → results → start over

## 7. Localization

- [ ] 7.1 Add diagnosis-related ARB entries to `assets/l10n/l10n_en.arb`: page titles, symptom labels, context question labels, confidence level labels, cause names, action text, disclaimer, fallback text
- [ ] 7.2 Run `fvm flutter gen-l10n` to regenerate localization files
- [ ] 7.3 Use `context.l10n.diagnosis*` keys throughout new pages

## 8. Testing

- [ ] 8.1 Write unit tests for each diagnosis rule (`test/diagnosis_usecases_test.dart`): test high/medium/low confidence scenarios from the specs
- [ ] 8.2 Write unit test for `DiagnosisEngine.evaluate()`: verify sorting, threshold filtering, empty input handling
- [ ] 8.3 Write unit test for confidence scoring: verify deterministic output and boundary values
- [ ] 8.4 Run `fvm flutter test` and `fvm flutter analyze` and fix any issues
