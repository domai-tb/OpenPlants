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
