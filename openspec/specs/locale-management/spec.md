## Purpose

Locale management for the OpenPlant app — runtime language switching, system locale detection, persistence, and widget-tree propagation.

## Requirements

### Requirement: User can switch app language at runtime

The system SHALL allow users to select their preferred app language from a list of supported locales. The selection SHALL take effect immediately without restarting the app.

#### Scenario: User selects a supported language
- **WHEN** user selects "Deutsch" from the language picker in Settings
- **THEN** all UI text SHALL display in German within the same session

#### Scenario: User selects "System default"
- **WHEN** user selects "System" in the language picker
- **THEN** the app SHALL follow the device's system locale

### Requirement: System locale detection with fallback

The system SHALL detect the device locale on startup and select the best matching supported locale, falling back to English when the system locale is unsupported.

#### Scenario: App starts with a supported system locale
- **WHEN** the device locale is `de_DE` and no user override is set
- **THEN** the app SHALL display in German

#### Scenario: App starts with an unsupported system locale
- **WHEN** the device locale is `fr_FR` and no user override is set
- **THEN** the app SHALL display in English (fallback)

### Requirement: Locale preference is persisted

The system SHALL persist the user's locale selection across app restarts.

#### Scenario: Language persists after restart
- **WHEN** user selects German, force-closes the app, and reopens it
- **THEN** the app SHALL still display in German

### Requirement: LocaleService propagates locale changes to the widget tree

The system SHALL include a `LocaleService` that notifies listeners when the locale changes, driving `MaterialApp.locale` to rebuild the widget tree.

#### Scenario: Locale change triggers MaterialApp rebuild
- **WHEN** `LocaleService` emits a new locale
- **THEN** `MaterialApp` SHALL rebuild with the updated `locale` property

#### Scenario: AppScope provides access to LocaleService
- **WHEN** any widget calls `AppScope.of(context)`
- **THEN** the widget SHALL be able to access the active locale through the scope's services

### Requirement: Supported locales are defined in a single source of truth

The system SHALL derive the list of supported locales from `AppLocalizations.supportedLocales` (the generated ARB delegate).

#### Scenario: New locale added via ARB
- **WHEN** a new ARB file (e.g., `l10n_es.arb`) is added and `fvm flutter gen-l10n` is run
- **THEN** `AppLocalizations.supportedLocales` SHALL include the new locale automatically
- **AND** the language picker in Settings SHALL show the new locale as an option
