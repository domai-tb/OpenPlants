## Why

OpenPlant currently has English and German ARB strings but no structured approach to runtime locale switching, unit preferences (Celsius/Fahrenheit), localized plant names, or UI layouts that accommodate varying text lengths across languages. As the app grows — more pages, more plant data, more contributors — ad-hoc translation will create fragmentation and rework. Establishing a localization-ready architecture now ensures the first shipping language (English) doesn't block later translation to German, Spanish, French, or any other locale, and that contributors have clear patterns to follow.

## What Changes

- **Dynamic locale switching engine** — a service that responds to the user's locale preference (system vs. manual override) and propagates it live through the widget tree without an app restart
- **Locale persistence** — the existing `localeCode` setting is already persisted; wire it to drive `MaterialApp.locale` and listen for live changes
- **Unit preferences model** — add `temperatureUnit` (Celsius/Fahrenheit) to `Settings`, with a controller that surfaces the preference to all feature pages
- **Localized plant names** — a data layer that maps plant species identifiers to localized display names per locale, falling back to the scientific/botanical name
- **Date/number formatting** — use `intl` package (already a dependency) for locale-aware date and number formatting across the app
- **UI layout guidelines** — widget patterns and layout strategies that handle text expansion/contraction across languages (e.g., German compounds are 30-40% longer than English equivalents)
- **ARB workflow documentation** — conventions for adding new strings, maintaining translation parity, and running `fvm flutter gen-l10n`

## Capabilities

### New Capabilities

- `locale-management`: Runtime locale switching driven by SettingsController, system locale detection, and live propagation through the widget tree. Includes the `LocaleService` use-case and wiring in `MaterialApp`.
- `unit-preferences`: Temperature unit (Celsius/Fahrenheit) preference in Settings, plus a `UnitPreferences` use-case that formats temperatures, dates, and numbers according to the active locale. Exposed via `AppServices`.
- `localized-plant-names`: Data layer for resolving plant species identifiers to localized common names. Includes a bundled JSON lookup table pattern, a repository that falls back to scientific names, and a use-case that widgets call for display text.
- `ui-text-flexibility`: Widget-level patterns and layout recipes for handling variable text lengths across languages. Not a runtime feature — a spec that documents `FittedBox`, `Flexible`, `overflow: TextOverflow.ellipsis`, minimum width guidelines, and review checklists.

### Modified Capabilities

*(No existing specs to modify — this is the first spec set for OpenPlant.)*

## Impact

- **New files**: `lib/core/locale_service.dart`, `lib/core/unit_preferences.dart`, `lib/pages/plant_names/` (datasource, repository, usecases, entity)
- **Modified files**: `lib/core/settings.dart` (add `temperatureUnit`), `lib/core/injection.dart` (register new services), `lib/core/app_services.dart` (expose new use-cases), `lib/core/app_scope.dart` (pass locale service), `lib/main.dart` (wire dynamic locale), ARB files (new string keys)
- **Dependencies**: No new packages needed — `intl` and `flutter_localizations` are already declared
- **No breaking changes** to existing features
