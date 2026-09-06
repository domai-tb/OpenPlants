## MODIFIED Requirements

### Requirement: Plant display names resolve to localized common names
The system SHALL resolve a plant species ID to localized common names and species information based on the active locale. When active-locale data is unavailable, it SHALL try the configured fallback locale and then the scientific/botanical name.

#### Scenario: Localized name exists for active locale
- **WHEN** displaying a plant with a catalog species ID and active locale `de`
- **THEN** the display name SHALL use the German catalog name

#### Scenario: No localized name, fallback to scientific name
- **WHEN** displaying a plant with no active- or fallback-locale name
- **THEN** the display name SHALL fall back to its scientific name

#### Scenario: Localized information is missing
- **WHEN** a catalog species has no localized description or care information
- **THEN** the system SHALL display available fallback information without failing

### Requirement: Plant names are loaded from bundled JSON assets
The system SHALL include bundled base and locale-keyed catalog assets that map stable species identifiers to localized common names, aliases, descriptions, and information. Missing or malformed locale assets SHALL NOT crash the app.

#### Scenario: Bundle loaded lazily
- **WHEN** a plant name or species information is requested
- **THEN** the datasource SHALL load the required bundled asset and cache it in memory

#### Scenario: Missing asset does not crash the app
- **WHEN** a locale asset is missing or malformed
- **THEN** the app SHALL continue functioning with fallback names and information
