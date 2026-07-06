## 1. Settings Model — Add TemperatureUnit

- [ ] 1.1 Add `TemperatureUnit` enum (celsius, fahrenheit) to `lib/core/settings.dart`
- [ ] 1.2 Add `temperatureUnit` field to `Settings` value class with default `TemperatureUnit.celsius`
- [ ] 1.3 Update `Settings.copyWith`, `fromJson`, and `toJson` for the new field
- [ ] 1.4 Verify serialization round-trip: old settings JSON (without the field) loads without error (graceful default)

## 2. LocaleService — Runtime Locale Switching

- [ ] 2.1 Create `lib/core/locale_service.dart` with `LocaleService extends ChangeNotifier`
- [ ] 2.2 Implement `Locale get activeLocale` — explicit locale → system locale → `Locale('en')` fallback
- [ ] 2.3 Implement `setLocale(String? localeCode)` that updates settings and notifies listeners
- [ ] 2.4 Implement `bool isSupported(Locale locale)` against `AppLocalizations.supportedLocales`
- [ ] 2.5 Register `LocaleService` as a lazy singleton in `lib/core/injection.dart`
- [ ] 2.6 Add `LocaleService` to `AppServices` and wire it in `injection.dart`
- [ ] 2.7 Wire `MaterialApp.locale` in `main.dart` to drive off `LocaleService.activeLocale`
- [ ] 2.8 Update `AppScope` to pass `LocaleService` (or ensure it's accessible through `AppServices`)

## 3. Locale Management — Settings UI

- [ ] 3.1 Update onboarding/language picker to call `LocaleService.setLocale()` instead of just storing `localeCode`
- [ ] 3.2 Ensure language picker reflects the current locale immediately
- [ ] 3.3 Add ARB strings for any new language picker labels

## 4. Unit Preferences — TemperatureFormatter

- [ ] 4.1 Create `lib/core/unit_preferences.dart` with `TemperatureFormatter` class
- [ ] 4.2 Implement `String format(double celsius, {required Locale locale})` returning locale-aware °C/°F
- [ ] 4.3 Add `TemperatureFormatter` as a use-case on `AppServices` (or a new `UnitPreferencesUsecases`)
- [ ] 4.4 Register new use-cases in `injection.dart`
- [ ] 4.5 Add unit preference section to the Settings UI (language picker area or dedicated section)

## 5. Locale-Aware Date Formatting

- [ ] 5.1 Create a `DateFormatter` utility (or extension on `DateTime`) using `intl.DateFormat` with the active locale
- [ ] 5.2 Audit existing date displays in pages (page1–page6, plant identification) and convert to locale-aware formatting
- [ ] 5.3 Add ARB strings if date format labels need to be localizable

## 6. Plant Names — Data Layer

- [ ] 6.1 Create `lib/pages/plant_names/plant_names_entity.dart` with `PlantNameEntry` (speciesId + localized names map)
- [ ] 6.2 Create `lib/pages/plant_names/plant_names_datasource.dart` — loads `assets/data/plant_names.json`
- [ ] 6.3 Create `lib/pages/plant_names/plant_names_repository.dart` — tiered lookup (in-memory → bundle → scientific fallback)
- [ ] 6.4 Create `lib/pages/plant_names/plant_names_usecases.dart` — `getDisplayName(speciesId, locale)`
- [ ] 6.5 Create `lib/pages/plant_names/plant_names_page.dart` (minimal — or skip page if not navigation-target; module can exist without a page)
- [ ] 6.6 Create `assets/data/plant_names.json` with starter entries for common species
- [ ] 6.7 Register datasource, repository, and usecases in `injection.dart`
- [ ] 6.8 Add `PlantNamesUsecases` to `AppServices`
- [ ] 6.9 Verify fallback: species missing from JSON returns scientific name without error

## 7. ARB Strings — New Localization Keys

- [ ] 7.1 Add locale-management keys to `l10n_en.arb` and `l10n_de.arb` (language names, locale labels)
- [ ] 7.2 Add unit-preferences keys (temperature unit labels, format labels)
- [ ] 7.3 Add any new plant-names-related labels
- [ ] 7.4 Run `fvm flutter gen-l10n` and verify generated Dart compiles

## 8. UI Text Flexibility — Audit & Documentation

- [ ] 8.1 Audit each page (page1–page6, plant identification, home, settings) for hardcoded text widths
- [ ] 8.2 Fix any overflow issues found (use Flexible, FittedBox, ellipsis, or padding-based sizing)
- [ ] 8.3 Add localization code-review checklist to `docs/wiki/` or `AGENTS.md`
- [ ] 8.4 Verify no user-facing strings are hardcoded in Dart widgets (all go through `context.l10n`)

## 9. Integration & Verification

- [ ] 9.1 Run `fvm flutter analyze` — zero new lint violations
- [ ] 9.2 Run `fvm flutter test` — all existing tests pass
- [ ] 9.3 Manual smoke test: switch language from English to German, verify full UI updates
- [ ] 9.4 Manual smoke test: toggle Celsius/Fahrenheit, verify temperature displays update
- [ ] 9.5 Manual smoke test: verify date format changes with locale
- [ ] 9.6 Manual smoke test: switch to System locale and verify device locale is respected
