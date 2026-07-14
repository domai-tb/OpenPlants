## ADDED Requirements

### Requirement: Diagnosis entry point from multiple locations
The system SHALL provide entry points to start a diagnosis from the app's "More" menu and from a plant's detail page (pre-populating known plant context).

#### Scenario: Start diagnosis from More menu
- **WHEN** user taps "Plant Diagnosis" in the More/bottom-sheet menu
- **THEN** the system navigates to the diagnosis questionnaire with no pre-filled plant context

#### Scenario: Start diagnosis from plant detail
- **WHEN** user taps "Diagnose this plant" on a plant's detail page
- **THEN** the system navigates to the diagnosis questionnaire with the plant's species and care history pre-filled

### Requirement: Diagnosis questionnaire page
The system SHALL display a questionnaire page (`DiagnosisPage`) that collects symptom information and plant care context through a structured form.

#### Scenario: Questionnaire shows symptom selection first
- **WHEN** the user navigates to the diagnosis questionnaire
- **THEN** they see a multi-select list of common symptoms: yellowing leaves, drooping/wilting, brown leaf tips/crispy edges, brown patches/scorched spots, pale leaves, leggy growth, visible insects/webs, sticky residue, mold on soil, foul smell from soil, stunted growth, leaf curling, leaf drop

#### Scenario: Questionnaire asks plant care context
- **WHEN** the user has selected symptoms
- **THEN** the form presents contextual questions: watering frequency, light exposure, humidity level, pot type, soil type, recent fertilizing, and pest signs

#### Scenario: Questionnaire shows progress
- **WHEN** the questionnaire has multiple sections
- **THEN** a progress indicator (e.g., step dots or a progress bar) shows how many sections remain

#### Scenario: Questions can be skipped
- **WHEN** the user does not know an answer
- **THEN** they can skip the question and the engine uses a neutral default for that factor

#### Scenario: "Start diagnosis" button evaluates answers
- **WHEN** the user taps "Start diagnosis" after completing the questionnaire
- **THEN** the system collects all answers into a `DiagnosisContext`, passes it to the diagnosis engine, and navigates to the result page

### Requirement: Diagnosis result page
The system SHALL display a result page (`DiagnosisResultPage`) showing the evaluation output from the diagnosis engine.

#### Scenario: Results page shows likely causes ranked
- **WHEN** the engine returns scored causes
- **THEN** the results page displays them ranked by confidence, each showing: cause name, confidence badge (high/medium/low), evidence summary, recommended actions, and follow-up checks

#### Scenario: High confidence cause highlighted
- **WHEN** a cause has high confidence
- **THEN** it is visually distinguished (e.g., prominent card, accent color, or top position with emphasis)

#### Scenario: Each cause shows evidence explanation
- **WHEN** a cause is displayed
- **THEN** it includes a plain-language explanation of why this cause was suggested, referencing the specific answers the user provided (e.g., "You reported yellowing leaves and watering more than recommended — these are common signs of overwatering")

#### Scenario: Each cause shows recommended actions
- **WHEN** a cause is displayed
- **THEN** it includes 2-3 actionable steps the user can take (e.g., "Allow soil to dry out before watering again", "Check that your pot has drainage holes")

#### Scenario: Each cause shows follow-up checks
- **WHEN** a cause is displayed
- **THEN** it includes 1-2 things the user should check next to confirm or rule out the cause (e.g., "Check the roots for rot: healthy roots are firm and white, rotten roots are brown and mushy")

#### Scenario: No-clear-match fallback displayed
- **WHEN** the engine returns a no-match fallback
- **THEN** the results page shows a "No clear match" message with general plant care suggestions and a note that the user can try again with more detail

#### Scenario: Disclaimer displayed on results
- **WHEN** any results are shown
- **THEN** a disclaimer is displayed: "This is a suggestion based on the information you provided. It is not a definitive diagnosis. Consult a plant care expert for serious concerns."

#### Scenario: Retake/restart questionnaire
- **WHEN** the user is viewing results
- **THEN** a "Start over" or "Try again" button allows returning to the questionnaire to adjust answers

### Requirement: Loading state during evaluation
The system SHALL show a loading indicator while the diagnosis engine evaluates the questionnaire answers.

#### Scenario: Loading displayed during evaluation
- **WHEN** the user taps "Start diagnosis" and the engine is evaluating
- **THEN** a loading indicator is shown (brief — rule evaluation is synchronous and fast)

#### Scenario: Results displayed after evaluation
- **WHEN** evaluation completes
- **THEN** the loading indicator is replaced by the diagnosis results page

### Requirement: Diagnosis page uses Clean Architecture pattern
The diagnosis feature SHALL follow the existing 5-file Clean Architecture pattern: `diagnosis_datasource.dart`, `diagnosis_repository.dart`, `diagnosis_usecases.dart`, `diagnosis_item_entity.dart`, `diagnosis_page.dart`.

#### Scenario: Files follow project naming conventions
- **WHEN** the diagnosis feature is created
- **THEN** the files SHALL be named `diagnosis_*.dart` following the same pattern as other page modules

#### Scenario: Registration in DI
- **WHEN** the app initializes
- **THEN** the diagnosis datasource, repository, and usecases SHALL be registered as lazy singletons in `lib/core/injection.dart`
