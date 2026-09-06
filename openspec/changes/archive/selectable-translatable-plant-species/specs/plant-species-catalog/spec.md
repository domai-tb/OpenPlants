## ADDED Requirements

### Requirement: Bundled model-aligned species catalog
The system SHALL ship a bundled catalog containing one stable identifier for each supported identification-model label, approximately 14,000 records, plus scientific name, aliases, and available localized metadata.

#### Scenario: Catalog covers model labels
- **WHEN** catalog validation runs against the installed model label file
- **THEN** every model label index SHALL resolve to exactly one catalog species ID

#### Scenario: Catalog assets are available offline
- **WHEN** the app starts without network access
- **THEN** catalog lookup and species selection SHALL remain available from bundled assets

### Requirement: Species catalog supports localized resolution
The system SHALL resolve common names, aliases, descriptions, and catalog information using the active locale, configured fallback locale, and scientific name fallback in that order.

#### Scenario: Active locale metadata exists
- **WHEN** a species has metadata for the active locale
- **THEN** the catalog returns that localized metadata

#### Scenario: Locale metadata is missing
- **WHEN** active and fallback locale metadata are unavailable
- **THEN** the catalog returns scientific name and available non-localized fields without crashing

### Requirement: Species catalog provides stable lookup and search
The system SHALL expose lookup by stable ID, model label index, and case-insensitive search across scientific name, localized common names, and aliases.

#### Scenario: Search returns matching species
- **WHEN** a user searches for a case-insensitive common-name fragment
- **THEN** matching species are returned with stable IDs and localized display names

#### Scenario: Model result resolves to catalog species
- **WHEN** classifier output contains a model label index
- **THEN** the catalog returns the corresponding species ID or a classified unknown-label error

### Requirement: Catalog loading is lazy and cached
The system SHALL load catalog assets on first catalog access, cache immutable parsed data, and return classified errors for missing or malformed assets.

#### Scenario: First access loads assets
- **WHEN** the catalog is accessed for the first time
- **THEN** bundled base and locale assets are parsed and cached

#### Scenario: Subsequent access uses cache
- **WHEN** catalog data has already loaded
- **THEN** subsequent lookup and search calls SHALL not reread assets

### Requirement: Species selection persists stable IDs
The plant form SHALL return and persist a selected species ID while displaying the active localized name.

#### Scenario: User selects species
- **WHEN** the user taps a species result in the picker
- **THEN** the form stores the species ID and displays its localized name

#### Scenario: No selection is made
- **WHEN** the user saves without selecting a species
- **THEN** the plant species reference remains empty
