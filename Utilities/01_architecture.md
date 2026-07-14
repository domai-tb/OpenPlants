# Architecture Utilities

`lib/core/` contains application-wide services and wiring:

- `injection.dart` registers dependencies with GetIt before the app starts.
- `app_scope.dart` exposes `AppServices` and `SettingsController` to widgets.
- `app_services.dart` is the aggregate of UI-facing feature services.
- `settings.dart`, `locale_service.dart`, and `unit_preferences.dart` provide persisted preferences, locale resolution, and temperature formatting.
- `themes.dart` defines the app's light and dark themes.

<<<<<<< HEAD
- `lib/core/`
  - Cross-cutting concerns (app scope, settings, themes, etc.).
- `lib/core/injection.dart`
  - Dependency injection wiring (GetIt).
- `lib/l10n/`
  - Generated localization code (see the Localization page).
- `lib/pages/`
  - Feature modules. In this app they are `page1` to `page6`.
  - Each module demonstrates a layered approach:
    - `*_datasource.dart` for I/O (API, DB, etc.)
    - `*_repository.dart` for domain-friendly access
    - `*_usecases.dart` for orchestration / business rules
    - `*_entity.dart` for immutable data models
    - `*_page.dart` for UI
- `lib/widgets/`
  - Shared widgets used across multiple pages (buttons, search bar, etc.).

## Dependency Wiring

OpenPlant uses GetIt for dependency injection, wired in one place:

- `lib/core/injection.dart` registers datasources, repositories, and usecases, and builds `AppServices`.
- `lib/main.dart` calls `init()` at startup.
- `lib/core/app_scope.dart` exposes `SettingsController` and `AppServices` to the widget tree (so pages stay free of plugin imports).

Pages access services via:

- `AppScope.of(context).services.pageN`

For the full architecture description, see [Architecture](Architecture).
=======
Widgets access dependencies through `AppScope.of(context)` rather than directly through GetIt. This keeps the service locator outside presentation code and centralizes feature wiring in `injection.dart`.

For the full structure and dependency direction, see [Architecture](Architecture).
>>>>>>> dev
