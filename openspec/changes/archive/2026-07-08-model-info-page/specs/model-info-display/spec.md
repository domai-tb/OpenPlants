## ADDED Requirements

### Requirement: Model metadata asset
The system SHALL provide a `model_meta.json` file in `assets/ml/plant-identification/` containing the model name, version, license identifier, input dimensions, label count, and a human-readable description of confidence behavior.

#### Scenario: Metadata file exists and is valid JSON
- **WHEN** the app starts or the model info page loads
- **THEN** `assets/ml/plant-identification/model_meta.json` is present and parseable as valid JSON

#### Scenario: Metadata contains required fields
- **WHEN** `model_meta.json` is loaded
- **THEN** it contains at minimum: `name` (string), `version` (string), `license` (string), `inputSize` (string, e.g. "224x224"), `labelCount` (int), `confidenceDescription` (string)

### Requirement: Model info page displays metadata
The system SHALL provide a read-only "Model Information" page that displays all fields from the model metadata asset in a clear, organized layout.

#### Scenario: Page shows model identity
- **WHEN** the user navigates to the Model Information page
- **THEN** the model name and version are displayed prominently at the top

#### Scenario: Page shows license
- **WHEN** the user views the Model Information page
- **THEN** the license identifier is displayed (e.g., "Apache 2.0", "MIT")

#### Scenario: Page shows technical details
- **WHEN** the user views the Model Information page
- **THEN** input dimensions (e.g., "224×224 pixels") and label count (e.g., "14,829 species") are displayed

#### Scenario: Page shows confidence behavior
- **WHEN** the user views the Model Information page
- **THEN** a human-readable description of confidence behavior is shown (e.g., "Scores are indicative. Results above 80% confidence are generally reliable.")

### Requirement: Navigation to model info page
The system SHALL provide a navigation entry from the settings page to the Model Information page.

#### Scenario: Settings entry exists
- **WHEN** the user opens the settings page
- **THEN** a "Model Information" tile or list entry is visible

#### Scenario: Navigation works
- **WHEN** the user taps "Model Information" in settings
- **THEN** the Model Information page is displayed

### Requirement: Model info page follows architecture pattern
The system SHALL implement the Model Information page using the project's 5-file Clean Architecture pattern: datasource, repository, usecases, entity, and page.

#### Scenario: Feature module exists
- **WHEN** the implementation is complete
- **THEN** `lib/pages/model_info/` contains `model_info_datasource.dart`, `model_info_repository.dart`, `model_info_usecases.dart`, `model_info_item_entity.dart`, and `model_info_page.dart`

#### Scenario: Dependency registration
- **WHEN** the app initializes
- **THEN** the model info use-case is registered in `lib/core/injection.dart` and exposed through `AppServices`
