## ADDED Requirements

### Requirement: Optional plant identification model setup
The onboarding flow SHALL offer a skippable step where the user can open the official model download page or import a previously downloaded model ZIP. Model setup SHALL NOT be required to finish onboarding.

#### Scenario: User imports a model during onboarding
- **WHEN** the user selects a valid model ZIP in the setup step
- **THEN** the app installs it and onboarding can continue to completion

#### Scenario: User skips model setup
- **WHEN** the user skips the setup step without an installed model
- **THEN** onboarding completes normally
- **AND** the user can import the model later from Model Information or plant identification

#### Scenario: Import is cancelled or fails
- **WHEN** the user cancels archive selection or import reports an error
- **THEN** onboarding remains usable and can still be completed without the model
