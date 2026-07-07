## ADDED Requirements

### Requirement: Bundled species JSON asset
The system SHALL ship a `assets/species/species.json` file containing an array of species records. Each record SHALL include: scientific name, common names (list), difficulty level, light needs, water needs, humidity preference, soil type, repotting interval, and toxicity flags (toxic to humans, toxic to pets). The file SHALL be declared in `pubspec.yaml` under `flutter: assets:`.

#### Scenario: Asset file exists
- **WHEN** the app is built
- **THEN** `assets/species/species.json` SHALL be present in the APK bundle

#### Scenario: Asset JSON is valid
- **WHEN** the data source loads the species JSON
- **THEN** it SHALL parse without errors and return a list of species records

### Requirement: Species data source loads bundled JSON
The system SHALL provide a `SpeciesLibraryDataSource` class that loads and parses the bundled species JSON asset. Loading SHALL happen lazily (on first access, not at app startup). The data source SHALL cache the parsed list in memory for subsequent access.

#### Scenario: First load succeeds
- **WHEN** `SpeciesLibraryDataSource` loads species data for the first time
- **THEN** it SHALL read the asset, parse JSON, and return a list of `SpeciesEntity` objects

#### Scenario: Loading returns cached data on subsequent calls
- **WHEN** species data has already been loaded
- **THEN** subsequent calls SHALL return the cached in-memory list without re-reading the asset

### Requirement: Species repository maps data to domain entities
The system SHALL provide a `SpeciesLibraryRepository` that wraps the data source and returns domain entities. It SHALL expose methods for listing all species, searching, and looking up a single species by scientific name.

#### Scenario: Repository lists all species
- **WHEN** `repository.listAll()` is called
- **THEN** it SHALL return a list of `SpeciesEntity` objects representing every species in the database

#### Scenario: Repository looks up species by scientific name
- **WHEN** `repository.findByScientificName('Monstera deliciosa')` is called
- **THEN** it SHALL return a `SpeciesEntity` with matching scientific name, or null if not found

### Requirement: Fuzzy scientific name matching
The repository SHALL support case-insensitive matching for scientific name lookups. It SHOULD also attempt fuzzy matching (Levenshtein distance ≤ 2) when an exact case-insensitive match is not found.

#### Scenario: Case-insensitive match
- **WHEN** `repository.findByScientificName('monstera deliciosa')` is called
- **THEN** it SHALL return the species record for Monstera deliciosa

#### Scenario: Fuzzy match for close typo
- **WHEN** `repository.findByScientificName('Monstera delicios')` is called (missing terminal 'a')
- **THEN** it SHALL return the closest match with Levenshtein distance ≤ 2

### Requirement: Species data schema
Each species entity SHALL contain the following fields:
- `scientificName` (String)
- `commonNames` (list of String)
- `difficulty` (enum: easy, moderate, challenging)
- `lightNeeds` (enum: low, medium, bright, direct)
- `waterNeeds` (enum: low, moderate, frequent)
- `humidityPreference` (enum: low, moderate, high)
- `soilType` (String)
- `repottingIntervalMonths` (int)
- `toxicToHumans` (bool)
- `toxicToPets` (bool)
- `description` (String)
- `careSummary` (String)

#### Scenario: Entity construction
- **WHEN** a species entity is constructed with all required fields
- **THEN** it SHALL be immutable (all fields final, const constructor)
