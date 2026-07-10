## Purpose

Localized plant name resolution — mapping species identifiers to locale-aware common names with scientific-name fallback.

## Requirements

### Requirement: Plant display names resolve to localized common names

The system SHALL resolve a plant species identifier to a localized common name based on the active locale. When no localized name is available, the system SHALL fall back to the scientific/botanical name.

#### Scenario: Localized name exists for active locale
- **WHEN** displaying a plant with species ID `monstera_deliciosa` and locale `de`
- **THEN** the display name SHALL be `"Monstera"` (the German common name)

#### Scenario: No localized name, fallback to scientific name
- **WHEN** displaying a plant with species ID `rare_species_2024` and locale `de`, and no German name exists in the lookup
- **THEN** the display name SHALL fall back to the plant's scientific name (e.g., `"Rare Species 2024"` or the botanical Latin name)

### Requirement: Plant names are loaded from a bundled JSON asset

The system SHALL include a bundled JSON asset (`assets/data/plant_names.json`) that maps species identifiers to localized common names per language code.

#### Scenario: Bundle loaded on startup
- **WHEN** the app starts
- **THEN** the `PlantNameDatasource` SHALL load `assets/data/plant_names.json` into an in-memory lookup map

#### Scenario: Missing asset does not crash the app
- **WHEN** the plant names asset file is missing or malformed
- **THEN** the app SHALL continue to function, falling back to scientific names for all plants

### Requirement: PlantNameRepository follows the Clean Architecture 5-file pattern

The system SHALL implement the plant-name feature at `lib/pages/plant_names/` with the standard datasource, repository, usecases, entity, and page files.

#### Scenario: Repository delegates to datasource for loading
- **WHEN** `PlantNameRepository.getDisplayName(speciesId, locale)` is called
- **THEN** the repository SHALL query the datasource's in-memory map
- **AND** fall back to the `scientificName` field on the plant entity if the map has no entry

### Requirement: Plant names are accessible via AppServices

The system SHALL expose plant name resolution through `AppServices` so any widget can access it via `AppScope.of(context).services`.

#### Scenario: Use-case on AppServices
- **WHEN** a widget needs a plant's display name
- **THEN** it SHALL call `AppScope.of(context).services.plantNames.getDisplayName(speciesId)`
