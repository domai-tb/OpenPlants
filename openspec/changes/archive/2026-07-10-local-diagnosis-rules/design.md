## Context

OpenPlant currently provides species identification (ONNX classifier), care plan guidance, and basic care tracking (watering/fertilizing status). Users have no way to get help when their plant shows signs of distress — leaf yellowing, drooping, brown tips, etc. The app runs fully offline for core features, and diagnosis should follow the same pattern: no cloud dependency, no AI inference, pure deterministic rule evaluation.

The existing Clean Architecture (Page → UseCase → Repository → DataSource), GetIt DI, and `lib/pages/pageN/` 5-file pattern define the structural constraints. All diagnosis data must be locally defined (no external API calls).

## Goals / Non-Goals

**Goals:**
- Provide a questionnaire-based diagnosis flow: user selects observed symptoms and provides plant context (species, pot type, soil, recent care) → system evaluates local rules → shows likely causes with confidence levels
- Cover 8 problem categories: overwatering, underwatering, low light, sunburn, low humidity, nutrient problems, root issues, pests
- Frame results as "likely causes" with explicit uncertainty (not medical-style diagnosis)
- Each result includes: cause name, confidence level (low/medium/high), evidence summary (which answers led to this), recommended actions, and follow-up checks
- Fully offline — no internet required
- Follow existing 5-file Clean Architecture pattern for the new `diagnosis` page module

**Non-Goals:**
- ML-based diagnosis or image analysis of plant distress (out of scope)
- Treatment tracking or "diagnosis history" beyond the immediate session
- Cloud sync of diagnosis data
- Prescription-level certainty or veterinary-level advice
- Integration with external plant disease databases

## Decisions

### Decision 1: Pure Dart rule engine (no DSL, no external rules engine)

- **Choice**: Implement diagnosis rules as Dart functions/classes evaluating against a `DiagnosisContext` value object, scored via weighted evidence accumulation.
- **Rationale**: Avoids adding a rules-engine dependency (Drools-like, BRMS, etc.) for ~8 rule categories. Pure Dart keeps the app small, avoids native FFI, and rules are simple enough that a weighted heuristic approach is transparent and easy to test. Each problem category maps to a `Rule` class with a `score(DiagnosisContext) → double` method.
- **Alternatives considered**:
  - **JSON-driven rules**: Would allow rule changes without code release, but adds parsing complexity and serialisation overhead. Overkill for 8 stable rule categories.
  - **Decision trees**: Natural for diagnosis but rigid — a weighted evidence approach allows partial matching and confidence granularity.

### Decision 2: Questionnaire as distinct step, not inline on result page

- **Choice**: A separate questionnaire page (`DiagnosisPage`) collects answers before evaluation. Results are shown on a separate `DiagnosisResultPage` after evaluation.
- **Rationale**: Keeps the UI focused — user answers questions without distraction, then sees results clearly. The questionnaire can adapt (conditional questions based on earlier answers). Follows the existing page-per-feature pattern in the project.
- **Alternatives considered**:
  - **Single scroll page**: Simpler but overwhelms the user with all inputs and results at once.
  - **Stepper/wizard widget**: Flutter's Stepper widget is rigid; a custom page flow gives full control over animations and branching.

### Decision 3: `DiagnosisContext` as the sole input to the rule engine

- **Choice**: All user answers are collected into an immutable `DiagnosisContext` value object (not a stateful session). The rule engine takes `DiagnosisContext` and returns a `DiagnosisResult`.
- **Rationale**: Immutable input → deterministic output (pure function). Easy to unit test — just construct a context and assert on results. No side effects during evaluation. Aligns with the project's entity pattern (`*_item_entity.dart`).
- **Fields on DiagnosisContext**: `symptoms` (list of enum values), `plantSpecies` (optional species entity), `potType` (enum: standard/self-watering/no-drainage), `soilType` (enum: standard/succulent/orchid/cactus), `recentWatering` (enum: over/normal/under), `lightExposure` (enum: low/indirect/direct), `humidityLevel` (enum: low/moderate/high), `recentFertilizing` (enum: yes/no), `pestSigns` (bool)

### Decision 4: Confidence as three-tier enum (low/medium/high)

- **Choice**: Confidence levels are computed from weighted evidence scores:
  - `high` (>70% of max possible score): Strong signal, multiple symptoms align
  - `medium` (40-70%): Some symptoms match, but not the full picture
  - `low` (<40%): Weak match, listed as possible but unlikely
- **Rationale**: Avoids false precision of percentages. Users intuitively understand "likely cause" vs. "possible cause." The evidence summary explains what contributed.

### Decision 5: Diagnosis rules defined in the UseCases layer

- **Choice**: Rule classes live in `diagnosis_usecases.dart`, alongside the orchestration logic. Each rule is a small class with a `score(DiagnosisContext)` method.
- **Rationale**: Rules are business logic — they belong in the UseCase layer per Clean Architecture. The datasource/repository layers handle data access; rules are pure logic with no I/O. Keeping them in one file (at least initially) avoids premature abstraction while remaining testable.

## Risks / Trade-offs

- **[Risk] Limited coverage**: 8 rule categories will not cover every plant problem. Users with rare issues may get no clear match.
  - **Mitigation**: The result page will show "No clear match" with general plant care suggestions when confidence is below a threshold for all rules.
- **[Risk] Questionnaire fatigue**: Too many questions may frustrate users.
  - **Mitigation**: Keep the questionnaire to 6-8 core questions with sensible defaults. Show progress indicator. Allow skipping questions (reduces confidence but still produces results).
- **[Risk] User misinterpretation**: Users may treat "likely cause" as a definitive diagnosis.
  - **Mitigation**: Every result includes a disclaimer: "This is a suggestion based on the information provided, not a medical/veterinary diagnosis." Use "likely cause" / "possible cause" language consistently.
- **[Trade-off] No image-based diagnosis**: Symptom selection via checkboxes is less intuitive than "take a photo of the problem." Purposely excluded as a non-goal (ML-based distress detection is a separate feature).
