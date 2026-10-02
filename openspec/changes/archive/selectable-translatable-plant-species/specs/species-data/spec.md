## MODIFIED Requirements

### Requirement: Bundled species JSON asset
The system SHALL ship versioned bundled species assets containing approximately 14,000 model-aligned species records. Each record SHALL include a stable species ID, model label index, scientific name, aliases, care fields, and references to locale-specific names and information. The assets SHALL be declared in `pubspec.yaml` under `flutter: assets:`.

#### Scenario: Asset file exists
- **WHEN** the app is built
- **THEN** the base catalog and supported locale assets SHALL be present in the APK bundle

#### Scenario: Asset JSON is valid
- **WHEN** the data source loads catalog assets
- **THEN** it SHALL parse without errors and return immutable species records

#### Scenario: Model alignment is valid
- **WHEN** catalog generation validates the model labels
- **THEN** duplicate IDs, duplicate model indices, missing model indices, or unmapped catalog records SHALL fail validation

### Requirement: Species data source loads bundled JSON
The system SHALL provide a species catalog data source that loads base and locale JSON assets lazily on first access and caches parsed immutable data for subsequent access.

#### Scenario: First load succeeds
- **WHEN** the data source loads species data for the first time
- **THEN** it SHALL read the assets, parse JSON, and return catalog entities

#### Scenario: Loading returns cached data on subsequent calls
- **WHEN** species data has already been loaded
- **THEN** subsequent calls SHALL return cached data without rereading assets

### Requirement: Species repository maps data to domain entities
The system SHALL provide repository methods for listing, stable-ID lookup, model-index lookup, localized search, and exact scientific-name compatibility lookup.

#### Scenario: Repository lists all species
- **WHEN** `repository.listAll()` is called
- **THEN** it SHALL return a list of catalog entities representing every species in the database

#### Scenario: Repository looks up by stable ID
- **WHEN** `repository.findById(id)` is called
- **THEN** it SHALL return the matching species entity or null when absent

#### Scenario: Repository searches localized fields
- **WHEN** `repository.search(query, locale)` is called
- **THEN** it SHALL return case-insensitive matches across scientific name, aliases, and localized common names

#### Scenario: Legacy scientific name is matched
- **WHEN** `repository.findByScientificName(name)` is called with an existing exact scientific name
- **THEN** it SHALL return the corresponding stable species ID

### Requirement: Fuzzy scientific name matching
The repository SHALL support case-insensitive matching for scientific-name compatibility lookups and SHOULD attempt fuzzy matching with Levenshtein distance ≤ 2 when an exact match is not found.

#### Scenario: Case-insensitive match
- **WHEN** `repository.findByScientificName('monstera deliciosa')` is called
- **THEN** it SHALL return the species record for Monstera deliciosa

#### Scenario: Fuzzy match for close typo
- **WHEN** `repository.findByScientificName('Monstera delicios')` is called
- **THEN** it SHALL return the closest match with Levenshtein distance ≤ 2

### Requirement: Species data schema
Each species entity SHALL contain stable ID, model label index, scientific name, aliases, localized metadata references, difficulty, light needs, water needs, humidity preference, soil type, repotting interval, description/care metadata, and toxicity fields. Entities SHALL be immutable.

#### Scenario: Entity construction
- **WHEN** a species entity is constructed with valid required fields
- **THEN** all fields SHALL be final and the entity SHALL be immutable
