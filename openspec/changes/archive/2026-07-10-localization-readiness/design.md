## Context

OpenPlant already has ARB-based localization with English (`l10n_en.arb`) and German (`l10n_de.arb`) string files, a generated `AppLocalizations` delegate, and a `Settings.localeCode` field persisted via `shared_preferences`. However, the locale is not wired to `MaterialApp.locale` at runtime — there is no mechanism to switch languages live, no unit-preference model, no localized plant-name lookup, and no layout guidance for text-length variation across languages.

The `intl` package and `flutter_localizations` are already declared dependencies. The project uses `fvm flutter gen-l10n` to regenerate Dart code from ARB files.

## Goals / Non-Goals

**Goals:**
- Live locale switching driven by `SettingsController` without app restart
- `temperatureUnit` (Celsius/Fahrenheit) preference in `Settings` with a formatting use-case
- Locale-aware date and number formatting via `intl` (already present)
- A localized plant-name lookup repository that falls back to scientific names
- Widget layout patterns documented for text expansion (German: +30-40%) and contraction
- All new capabilities exposed through `AppServices` and accessible via `AppScope`

**Non-Goals:**
- Shipping translations beyond English and German in this change (structure only; translators fill ARBs later)
- On-device translation or ML-based language detection
- RTL layout support (not needed for initial European languages; accommodate later structurally)
- Replacing the ARB-based workflow with a different i18n system
- Automating translation file generation (CI integration deferred)

## Decisions

### Decision 1: LocaleService as a ChangeNotifier, not a stream
- **Chosen**: `LocaleService` extends `ChangeNotifier`, listens to `SettingsController`, and exposes `Locale get activeLocale`. When the user changes their locale preference, `SettingsController` notifies `LocaleService`, which notifies the widget tree.
- **Alternatives considered**: `ValueNotifier<Locale>` stream, redux-style store — overkill for a single-value concern.
- **Rationale**: Flutter's `MaterialApp` rebuilds when given a new `Locale` via `builder`/`locale`. The `ChangeNotifier` pattern is already established (`SettingsController`). Keeping one notification chain avoids duplicate wiring.

### Decision 2: Locale resolution order: explicit override → system locale → fallback (en)
- User-selected locale code (from `Settings.localeCode`) takes precedence if non-null and supported.
- If null/falsy, defer to `WidgetsBinding.instance.platformDispatcher.locale`.
- If that locale is unsupported, fall back to `const Locale('en')`.
- `LocaleService.isSupported(locale)` checks against `AppLocalizations.supportedLocales`.

### Decision 3: TemperatureUnit as a simple enum in Settings
```dart
enum TemperatureUnit { celsius, fahrenheit }
```
- Stored as a `String?` in the JSON blob alongside other settings.
- A new `TemperatureFormatter` use-case converts raw Celsius values to display strings based on the active setting.
- **Rationale**: Simple, serializable, no new dependencies. Future: pressure, wind speed, etc. can reuse the pattern.

### Decision 4: PlantNameRepository with tiered lookup
- Tier 1: In-memory `Map<String, Map<String, String>>` keyed by `(speciesId, localeCode)`
- Tier 2: Bundled JSON asset (`assets/data/plant_names.json`) loaded at startup
- Tier 3: Falls back to `scientificName` from the plant entity
- Bundled JSON structure:
  ```json
  {
    "monstera_deliciosa": {
      "en": "Swiss Cheese Plant",
      "de": "Monstera",
      "es": "Costilla de Adán"
    }
  }
  ```
- **Rationale**: Plant names are static data, not user-generated. Bundling avoids network dependency. The in-memory map allows future dynamic loading (e.g., download additional language packs).

### Decision 5: Text length flexibility as documented patterns, not a runtime framework
- Rather than building a custom widget library, document existing Flutter patterns: `FittedBox`, `Flexible`, `Expanded`, `TextOverflow.ellipsis`, `SoftWrap`, `TextWidthBasis`, and min-width constraints on buttons.
- Add a review checklist item: "Every Text widget with user-facing content has an overflow strategy."
- **Rationale**: Flutter already provides the tools. The gap is awareness and consistency.

### Decision 6: All new use-cases exposed via AppServices
- `LocaleService` → new field on `AppServices` (or a separate `LocaleNotifier` instance on `AppScope`)
- `TemperatureFormatter` → lives on a new `UnitPreferencesUsecases` class, exposed via `AppServices`
- `PlantNameUsecases` → new feature module under `lib/pages/plant_names/` following the 5-file pattern

## Risks / Trade-offs

- **[Risk] ARB file duplication** — Two ARB files (en, de) must stay in sync. A contributor adding an English string must also add the German key (value can be English as a placeholder).
  → **Mitigation**: Document the workflow in the spec; CI can validate that both ARB files have matching keys.
- **[Risk] Bundled plant names file grows** — With hundreds of species × many languages, the JSON asset could become large.
  → **Mitigation**: Structure the JSON per-language (not per-species) to allow lazy loading. Initial bundle holds only common species.
- **[Trade-off] No RTL** — Arabic, Hebrew, and Farsi speakers won't be supported by this change.
  → Accepted: This is a structural readiness change, not a full i18n rollout. The ARB + `intl` foundation naturally supports RTL when needed.
- **[Risk] Text overflow in existing layouts** — German text is 30-40% longer than English. Existing hardcoded widths may clip.
  → **Mitigation**: Each feature page screen gets a visual audit during implementation; the ui-text-flexibility spec provides the review checklist.
