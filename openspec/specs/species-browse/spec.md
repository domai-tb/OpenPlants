# Species Browse

## Purpose

Define the species detail viewing experience, accessible from the dashboard plant grid or identification results.

## Requirements

### Requirement: Species detail page
The system SHALL provide a detail page for a single species. The detail page SHALL display: scientific name, common names, description, difficulty badge, care summary, and all care sections (light, water, humidity, soil, repotting). Toxicity warnings SHALL be highlighted in red.

#### Scenario: Detail page shows all fields
- **WHEN** the user opens a species detail page
- **THEN** the page SHALL display all species data fields in a structured layout

#### Scenario: Toxicity warning for toxic species
- **WHEN** the species has `toxicToPets == true`
- **THEN** the detail page SHALL display a prominent "Toxic to pets" warning with a red/amber background

#### Scenario: Care plan section
- **WHEN** the user views a species detail page
- **THEN** the page SHALL include a "Care Plan" section generated from the species data
