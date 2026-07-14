# Architecture

OpenPlants is a Flutter plant companion app organised around a lightweight Clean Architecture. It avoids a BLoC layer: feature pages keep local presentation state, while shared application state is supplied through `AppScope`.

## Project Layout

- `lib/core/` — application wiring, settings, localization and formatting services, themes, and shared failures.
- `lib/pages/` — feature modules, including collection management, care scheduling, diagnosis, journals, identification, and species data.
- `lib/widgets/` — reusable UI components shared by features.
- `assets/l10n/` — source ARB localization files; generated Dart output is in `lib/l10n/`.
- `assets/ml/plant-identification/` and `assets/species/` — bundled identification and species-reference assets.

## Feature Boundaries

Feature modules normally follow this dependency direction:

```text
Page → UseCases → Repository → DataSource
```

- `*_page.dart` renders the feature and handles local widget state.
- `*_usecases.dart` coordinates feature behaviour.
- `*_repository.dart` exposes domain-oriented operations.
- `*_datasource.dart` owns external or persisted data access.
- Entity and value files model feature data.

Some larger features include focused helpers, such as the care-schedule engine and modifiers, the diagnosis engine, or the plant-identification classifier pipeline. Keep those details inside the owning feature rather than leaking them into pages.

## Application Wiring

`main()` calls `init()` in `lib/core/injection.dart` before `runApp()`. The initializer loads `SettingsController` and registers feature data sources, repositories, use cases, and supporting services with GetIt.

`AppServices` groups the UI-facing feature services. `AppScope`, an `InheritedWidget`, makes both `AppServices` and `SettingsController` available to the widget tree:

```dart
final services = AppScope.of(context).services;
final settings = AppScope.of(context).settings;
```

Pages must use `AppScope` rather than importing the GetIt container directly. This keeps service lookup at the application boundary and makes dependencies explicit in feature wiring.

## Cross-Cutting State

- `SettingsController` is the single source of truth for persisted user preferences.
- `LocaleService` resolves an explicit language selection, then the system locale, and finally English as a fallback.
- `TemperatureFormatter` formats Celsius input in the user-selected unit and active locale.
- `OpenPlantsApp` rebuilds `MaterialApp` when settings or the locale service changes, applying theme, locale, and text-scaling preferences.
