# Shared Widgets

Shared widgets live in `lib/widgets/`. They keep feature modules focused on their own behaviour and prevent UI duplication.

## Shared Components

- Buttons: `app_button.dart`, `custom_button.dart`, and `app_icon_button.dart`
- Search: `app_search_bar.dart`
- Controls: `app_segmented_triple_control.dart` and `scroll_to_top_button.dart`
- Feedback: `confirm_dialog.dart` and `error_message.dart`
- Camera preview: `inline_camera_preview.dart`

Keep a widget inside its feature module when it is used only by that feature; move it to `lib/widgets/` only once it represents a reusable app-wide component.

---

# Architecture Utilities

`lib/core/` contains application-wide services and wiring:

- `injection.dart` registers dependencies with GetIt before the app starts.
- `app_scope.dart` exposes `AppServices` and `SettingsController` to widgets.
- `app_services.dart` is the aggregate of UI-facing feature services.
- `settings.dart`, `locale_service.dart`, and `unit_preferences.dart` provide persisted preferences, locale resolution, and temperature formatting.
- `themes.dart` defines the app's light and dark themes.

Widgets access dependencies through `AppScope.of(context)` rather than directly through GetIt. This keeps the service locator outside presentation code and centralizes feature wiring in `injection.dart`.

For the full structure and dependency direction, see [Architecture](Architecture).

---

# Localization (l10n)

OpenPlants uses Flutter's built-in `gen-l10n` system with ARB files.

## Where Translations Live

- `assets/l10n/l10n_en.arb`
- `assets/l10n/l10n_de.arb`

Configuration lives in `l10n.yaml`; generated output is written to `lib/l10n/`.

## Using Translations in Widgets

Use the `BuildContext` extension from `lib/l10n/l10n_x.dart`:

```dart
Text(context.l10n.appTitle)
```

## Adding a New String

1. Add the key to every supported locale in `assets/l10n/`.
2. Run `fvm flutter gen-l10n` to regenerate `lib/l10n/`.
3. Use the new key via `context.l10n.<key>`.

`LocaleService` applies an explicit user choice when supported, otherwise uses the device locale and falls back to English. Keep the ARB files aligned so that every supported locale has each key.

---

# Settings (Persistent)

OpenPlants persists user preferences in `shared_preferences` as JSON.

## Where It Lives

`SettingsController` in `lib/core/settings.dart` loads settings once at startup and writes changes asynchronously.

## What Is Stored

The `Settings` model includes:

- theme mode flags;
- text-scaling preference;
- onboarding completion flag (`didCompleteOnboarding`);
- selected language (`localeCode`) or `null` for the system language; and
- temperature unit (Celsius or Fahrenheit).

## Why JSON

JSON keeps settings backwards-compatible: add a new field with a default in `Settings.fromJson(...)` so existing installations can load it safely.

---

