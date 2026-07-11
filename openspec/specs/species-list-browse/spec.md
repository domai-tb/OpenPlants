# Species List Browse

## Purpose

Define the browsable, searchable list of all species accessible from the More page. This capability provides an entry point for users to discover and explore the species catalog without needing to identify a plant first.

## Requirements

### Requirement: Species list accessible from More page
The system SHALL include a "Species List" menu item in the More page. The menu item SHALL display a title and subtitle. The menu item SHALL be positioned as the first item in the More page list.

#### Scenario: Species list item appears in More page
- **WHEN** the user opens the More page
- **THEN** a "Species List" menu item SHALL be displayed as the first item with title and subtitle

#### Scenario: Tapping species list item opens species list page
- **WHEN** the user taps the "Species List" menu item
- **THEN** the system SHALL navigate to the species list page

### Requirement: Species list page displays all species
The system SHALL provide a species list page that displays all species from the bundled species database. Each species entry SHALL show the scientific name, primary common name, and a difficulty indicator.

#### Scenario: Species list loads all species
- **WHEN** the user opens the species list page
- **THEN** the page SHALL display a scrollable list of all species in the database

#### Scenario: Species entry shows key information
- **WHEN** a species entry is rendered in the list
- **THEN** it SHALL display the scientific name, the first common name (if available), and a difficulty badge (green for easy, amber for moderate, red for challenging)

#### Scenario: Species with toxicity shows indicator
- **WHEN** a species has `toxicToPets == true` or `toxicToHumans == true`
- **THEN** the species entry SHALL display a toxicity warning icon

### Requirement: Species list search
The system SHALL provide a search field on the species list page. Search SHALL filter species by scientific name, common names, and description text. Search SHALL be case-insensitive.

#### Scenario: Search filters by common name
- **WHEN** the user types "monstera" in the search field
- **THEN** the list SHALL display only species whose scientific name or common names contain "monstera"

#### Scenario: Search filters by scientific name
- **WHEN** the user types "ficus" in the search field
- **THEN** the list SHALL display only species whose scientific name contains "ficus"

#### Scenario: Empty search shows all species
- **WHEN** the search field is empty
- **THEN** the list SHALL display all species

#### Scenario: No results found
- **WHEN** the search query matches no species
- **THEN** the page SHALL display an empty state message

### Requirement: Species list navigation to detail page
The system SHALL navigate to the existing species detail page when a user taps a species in the list.

#### Scenario: Tap opens detail page
- **WHEN** the user taps a species entry in the list
- **THEN** the system SHALL navigate to the species detail page for that species

### Requirement: Species list page title
The species list page SHALL display a page title in the AppBar. The page SHALL include a back button to return to the More page.

#### Scenario: Page has title and back navigation
- **WHEN** the user opens the species list page
- **THEN** the AppBar SHALL display a localized title and a back button
