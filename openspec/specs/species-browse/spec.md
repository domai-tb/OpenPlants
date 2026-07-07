# Species Browse

## Purpose

Define the species browsing, search, filter, and detail viewing experience in the species library.

## Requirements

### Requirement: Species library list page
The system SHALL provide a list view of all available species. Each item in the list SHALL display the common name, scientific name (italic), and difficulty indicator. The list SHALL be scrollable.

#### Scenario: List displays all species
- **WHEN** the user navigates to the species library page
- **THEN** the list SHALL display all species loaded from the bundled JSON

#### Scenario: Tapping a species opens detail
- **WHEN** the user taps a species in the list
- **THEN** the app SHALL navigate to the species detail page for that species

### Requirement: Search by name or keyword
The system SHALL provide a search bar that filters the species list by common name, scientific name, or description keywords. The search SHALL be case-insensitive and match on substrings.

#### Scenario: Search by common name
- **WHEN** the user types "monstera" in the search bar
- **THEN** the list SHALL filter to show only species whose common name or scientific name contains "monstera"

#### Scenario: Search by keyword in description
- **WHEN** the user types "climbing" in the search bar
- **THEN** the list SHALL filter to show only species whose description contains "climbing"

#### Scenario: Empty search shows all
- **WHEN** the search bar is empty
- **THEN** the list SHALL show all species unfiltered

#### Scenario: No matches found
- **WHEN** the user searches for a term that matches no species
- **THEN** the list SHALL display an empty state message ("No species found")

### Requirement: Filter by difficulty
The system SHALL provide filter chips for difficulty level (Easy, Moderate, Challenging). Multiple filters SHALL be combinable. The active filter SHALL be visually indicated.

#### Scenario: Filter by difficulty
- **WHEN** the user selects "Easy" filter chip
- **THEN** the list SHALL show only species with difficulty = easy

#### Scenario: Multiple difficulty filters
- **WHEN** the user selects both "Easy" and "Moderate" filter chips
- **THEN** the list SHALL show species with difficulty = easy OR moderate

### Requirement: Filter by toxicity
The system SHALL provide a toggle to filter by toxic/non-toxic species. The toggle SHALL default to showing all species.

#### Scenario: Filter toxic species
- **WHEN** the user enables the "Toxic" filter
- **THEN** the list SHALL show only species where `toxicToPets == true` OR `toxicToHumans == true`

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
