## REMOVED Requirements

### Requirement: Species library list page
**Reason**: The species library list page is removed from navigation. Users can no longer browse all species as a standalone page. Species discovery now happens through identification (scan a plant → learn about it).

**Migration**: The `SpeciesLibraryPage` widget is deleted. Its data source (`SpeciesLibraryDatasource`, `SpeciesRepository`, `SpeciesLibraryUsecases`) remains intact for internal consumption by identification results, care plans, and plant detail.

### Requirement: Search by name or keyword
**Reason**: Species search is removed along with the species library page. The search UI and filter chips for difficulty and toxicity are no longer accessible.

**Migration**: Users can still search for plants by name on the dashboard. Species-level search is no longer available. If a user needs to find a specific species, they can identify a plant via camera, which shows the matched species information.

### Requirement: Filter by difficulty
**Reason**: Removed along with the species library page.

**Migration**: None. Difficulty filtering was only available in the species browsing context.

### Requirement: Filter by toxicity
**Reason**: Removed along with the species library page.

**Migration**: Toxicity information remains visible on the species detail page, which is still reachable from identification results and plant detail pages. The global toxicity filter is removed.

## MODIFIED Requirements

### Requirement: Species detail page
The system SHALL provide a detail page for a single species. The detail page SHALL display: scientific name, common names, description, difficulty badge, care summary, and all care sections (light, water, humidity, soil, repotting). Toxicity warnings SHALL be highlighted in red. The species detail page SHALL be reachable from identification results (tapping a matched species) and from plant detail pages (tapping a plant's assigned species).

#### Scenario: Detail page shows all fields
- **WHEN** the user opens a species detail page from identification results or plant detail
- **THEN** the page SHALL display all species data fields in a structured layout

#### Scenario: Toxicity warning for toxic species
- **WHEN** the species has `toxicToPets == true`
- **THEN** the detail page SHALL display a prominent "Toxic to pets" warning with a red/amber background

#### Scenario: Care plan section
- **WHEN** the user views a species detail page
- **THEN** the page SHALL include a "Care Plan" section generated from the species data
