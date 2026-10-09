## Purpose

User-managed model loading: plant identification models come from user-imported archives, not the Flutter asset bundle. Package contract lives in `plant-model-management`.

## Requirements

### Requirement: Model loading uses installed packages
The system SHALL load the identification model from the installed user-managed package as defined by `plant-model-management`, not from bundled assets.

#### Scenario: Loading resolves to installed package
- **WHEN** plant identification initializes the model
- **THEN** it uses the active installed package or reports the model as absent

