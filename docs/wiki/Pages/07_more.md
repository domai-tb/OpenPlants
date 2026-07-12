# More

The **More** destination provides navigation to app settings and the About screen.

## Settings

Settings are stored locally and take effect immediately. Users can choose:

- system, light, or dark theme;
- system default, English, or German language;
- Celsius or Fahrenheit temperature display; and
- whether to respect the system text-scaling preference.

The settings UI is implemented in `lib/pages/more/more_settings_page.dart`; persistence is owned by `SettingsController` in `lib/core/settings.dart`.
