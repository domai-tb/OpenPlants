## ADDED Requirements

### Requirement: Missing model setup
The system SHALL check model availability before starting camera inference and provide setup actions when no model is installed.

#### Scenario: Identification opens without an installed model
- **WHEN** the user opens plant identification and no model is installed
- **THEN** the camera and inference flow are not started
- **AND** the page offers to open Model Information or the official Hugging Face download page
- **AND** the user can import a previously downloaded model archive

#### Scenario: Model is imported while identification is open
- **WHEN** the user returns from model import with a valid installed package
- **THEN** the identification page refreshes model status and makes the camera flow available

#### Scenario: Model is unavailable
- **WHEN** the user closes the download page or cancels archive selection without a model
- **THEN** identification remains unavailable with a clear setup action
- **AND** other app features remain usable
