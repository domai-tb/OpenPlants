## Why

OpenPlant currently helps users identify plant species and track basic care (watering, fertilizing), but provides no guidance when a plant shows signs of distress. Users need actionable, offline-capable diagnosis suggestions to understand what might be wrong with their plant — without requiring an internet connection or cloud AI. A rule-based diagnosis engine powered by local logic gives immediate, private, and transparent feedback.

## What Changes

- New **diagnosis engine** capability with local rule-based heuristics for common plant problems
- New **diagnosis UI page** with a questionnaire flow (symptom selection, plant context) and results display
- **Plant entity** extended with optional fields to support diagnosis context (pot type, soil type, recent symptoms log)
- New localisation entries for all diagnosis-related strings
- No breaking changes to existing features

## Capabilities

### New Capabilities

- `diagnosis-engine`: Local rule-based diagnosis engine that maps user answers (symptoms, plant type, environment) to likely causes with confidence scores, recommended actions, and follow-up checks. Covers overwatering, underwatering, low light, sunburn, low humidity, nutrient problems, root issues, and pests.
- `diagnosis-ui`: Questionnaire-driven UI for symptom selection and plant context, plus a diagnosis result page showing likely causes, confidence levels, evidence summary, recommended actions, and follow-up tasks.

### Modified Capabilities

- *(None — this is a net-new feature; no existing spec-level requirements change.)*

## Impact

- **New feature module**: `lib/pages/diagnosis/` with the standard 5-file Clean Architecture pattern (datasource, repository, usecases, entity, page)
- **Plant entity extension**: Optional fields for pot type, soil type, and symptom log on the plant entity (or a standalone diagnosis session entity)
- **Dependency**: No new external packages — pure Dart logic for rule evaluation
- **Localisation**: `assets/l10n/l10n_en.arb` extended with diagnosis-related strings
- **DI registration**: `lib/core/injection.dart` — new lazy singletons for diagnosis datasource, repository, and usecases
- **Navigation**: New entry in `lib/pages/home/home_page.dart` added to the more/bottom-sheet menu, plus deep-link from a plant detail page to start a diagnosis for that plant
