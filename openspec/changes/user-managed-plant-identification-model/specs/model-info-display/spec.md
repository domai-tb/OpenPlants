## REMOVED Requirements

### Requirement: Model metadata asset
**Reason**: Installed model metadata comes from the imported package rather than a bundled `model_meta.json` asset.
**Migration**: Read `onnx_export_info.json` from the installed package and retain static source/license details when no model is installed.

## MODIFIED Requirements

### Requirement: Model info page displays metadata
The system SHALL provide a "Model Information" page that displays available model details and installation state, with actions to open the official external download page, import or replace an archive, and remove an installed model.

#### Scenario: Page shows model identity
- **WHEN** the user navigates to the Model Information page
- **THEN** the model name and installed source revision are displayed prominently at the top
- **AND** the page clearly says when no model is installed

#### Scenario: Page shows license
- **WHEN** the user views the Model Information page
- **THEN** the model license identifier is displayed

#### Scenario: Page shows technical details
- **WHEN** the user views the Model Information page with a model installed
- **THEN** input dimensions and label count are displayed from the installed package metadata

#### Scenario: Page shows confidence behavior
- **WHEN** the user views the Model Information page
- **THEN** a human-readable description of confidence behavior is shown

#### Scenario: User opens download or import action
- **WHEN** the user chooses to obtain a model or import one
- **THEN** the app opens the official Hugging Face location in the external browser or launches the system document picker
- **AND** the app does not download the model itself

#### Scenario: User removes installed model
- **WHEN** the user confirms removal of the installed model
- **THEN** only the model's app-private files are deleted
- **AND** app settings and plant records remain unchanged

### Requirement: Navigation to model info page
The system SHALL provide a navigation entry from the settings page and More > About to the Model Information page, and a route to it from the missing-model state in plant identification.

#### Scenario: Settings entry exists
- **WHEN** the user opens the settings page
- **THEN** a "Model Information" tile or list entry is visible

#### Scenario: About entry exists
- **WHEN** the user opens More > About
- **THEN** a "Model Information" tile or list entry is visible

#### Scenario: Navigation works
- **WHEN** the user taps "Model Information" in settings or About, or follows the missing-model action
- **THEN** the Model Information page is displayed

## ADDED Requirements

### Requirement: Metadata reflects installation state
The system SHALL derive installed model revision, input/output details, label count, and confidence behavior from the active package's `onnx_export_info.json`. Static source and license information SHALL remain available when no model is installed.

#### Scenario: Model metadata is available without a model
- **WHEN** the Model Information page loads and no model is installed
- **THEN** the model source and license information remain visible
- **AND** the page identifies the model as not installed

#### Scenario: Installed model metadata is shown
- **WHEN** a valid model package is installed
- **THEN** the page displays its source revision, input dimensions, label count, and confidence behavior from the package metadata
