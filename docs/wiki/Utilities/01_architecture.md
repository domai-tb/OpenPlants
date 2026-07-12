# Architecture Utilities

`lib/core/` contains application-wide services and wiring:

- `injection.dart` registers dependencies with GetIt before the app starts.
- `app_scope.dart` exposes `AppServices` and `SettingsController` to widgets.
- `app_services.dart` is the aggregate of UI-facing feature services.
- `settings.dart`, `locale_service.dart`, and `unit_preferences.dart` provide persisted preferences, locale resolution, and temperature formatting.
- `themes.dart` defines the app's light and dark themes.

Widgets access dependencies through `AppScope.of(context)` rather than directly through GetIt. This keeps the service locator outside presentation code and centralizes feature wiring in `injection.dart`.

For the full structure and dependency direction, see [Architecture](Architecture).
