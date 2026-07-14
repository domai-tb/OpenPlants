## Purpose

Unit preferences for temperature display and locale-aware formatting of dates and numbers.

## Requirements

### Requirement: User can choose temperature unit

The system SHALL allow users to select between Celsius and Fahrenheit for displaying temperatures. The preference SHALL be persisted.

#### Scenario: User switches to Fahrenheit
- **WHEN** user selects "Fahrenheit" in the unit preferences section of Settings
- **THEN** all temperature displays throughout the app SHALL show values in °F
- **AND** the preference SHALL be persisted across app restarts

#### Scenario: User switches back to Celsius
- **WHEN** user selects "Celsius" in the unit preferences section
- **THEN** all temperature displays SHALL show values in °C

### Requirement: TemperatureFormatter use-case converts values

The system SHALL include a `TemperatureFormatter` use-case that accepts a raw Celsius value and returns a locale-aware, unit-aware display string.

#### Scenario: Format Celsius with English locale
- **WHEN** `TemperatureFormatter.format(25.0)` is called with locale `en` and unit `celsius`
- **THEN** the result SHALL be `"25°C"`

#### Scenario: Format Fahrenheit with English locale
- **WHEN** `TemperatureFormatter.format(25.0)` is called with locale `en` and unit `fahrenheit`
- **THEN** the result SHALL be `"77°F"`

#### Scenario: Format Fahrenheit with German locale
- **WHEN** `TemperatureFormatter.format(25.0)` is called with locale `de` and unit `fahrenheit`
- **THEN** the result SHALL use the German number format (decimal comma): `"77°F"` (or appropriate localized symbol)

### Requirement: TemperatureUnit is stored in Settings

The system SHALL include a `TemperatureUnit` enum with values `celsius` and `fahrenheit`, stored as a JSON-serializable field in the `Settings` model.

#### Scenario: TemperatureUnit serialization round-trip
- **WHEN** a `Settings` instance with `temperatureUnit: TemperatureUnit.fahrenheit` is serialized to JSON and deserialized
- **THEN** the restored instance SHALL have `temperatureUnit == TemperatureUnit.fahrenheit`

### Requirement: Locale-aware date formatting

The system SHALL format dates according to the active locale's conventions.

#### Scenario: Date formatted for English locale
- **WHEN** a date like `2026-07-06` is formatted with locale `en`
- **THEN** the result SHALL follow English date conventions (e.g., `"Jul 6, 2026"`)

#### Scenario: Date formatted for German locale
- **WHEN** a date like `2026-07-06` is formatted with locale `de`
- **THEN** the result SHALL follow German date conventions (e.g., `"6. Juli 2026"`)
