# Architecture

<<<<<<< HEAD
This page documents the current project architecture used by OpenPlant.
=======
OpenPlants is a Flutter plant companion app organised around a lightweight Clean Architecture. It avoids a BLoC layer: feature pages keep local presentation state, while shared application state is supplied through `AppScope`.
>>>>>>> dev

## Project Layout

- `lib/core/` — application wiring, settings, localization and formatting services, themes, and shared failures.
- `lib/pages/` — feature modules, including collection management, care scheduling, diagnosis, journals, identification, and species data.
- `lib/widgets/` — reusable UI components shared by features.
- `assets/l10n/` — source ARB localization files; generated Dart output is in `lib/l10n/`.
- `assets/ml/plant-identification/` and `assets/species/` — bundled identification and species-reference assets.

## Feature Boundaries

<<<<<<< HEAD
At the top level, OpenPlant is split into:

- `lib/core/`: Cross-cutting code (settings persistence, theming, dependency wiring).
- `lib/pages/`: Feature modules. In this app they are `page1` to `page6` and serve as examples.
- `lib/widgets/`: Globally reusable widgets (buttons, search bar, etc.).
- `lib/l10n/`: Generated localization code.

Within each feature module (example: `lib/pages/page1/`) we follow a small layered structure:

- `*_datasource.dart`: Data access boundary (API, DB, platform, etc.).
- `*_repository.dart`: Domain-friendly access and mapping.
- `*_usecases.dart`: Orchestration and business rules.
- `*_entity.dart`: Immutable data models used by the UI.
- `*_page.dart`: UI.

As a simplified tree:
=======
Feature modules normally follow this dependency direction:
>>>>>>> dev

```text
Page → UseCases → Repository → DataSource
```

- `*_page.dart` renders the feature and handles local widget state.
- `*_usecases.dart` coordinates feature behaviour.
- `*_repository.dart` exposes domain-oriented operations.
- `*_datasource.dart` owns external or persisted data access.
- Entity and value files model feature data.

<<<<<<< HEAD
OpenPlant uses a simple layered approach inspired by Clean Architecture. The exact naming is less important than the dependency direction:
=======
Some larger features include focused helpers, such as the care-schedule engine and modifiers, the diagnosis engine, or the plant-identification classifier pipeline. Keep those details inside the owning feature rather than leaking them into pages.
>>>>>>> dev

## Application Wiring

`main()` calls `init()` in `lib/core/injection.dart` before `runApp()`. The initializer loads `SettingsController` and registers feature data sources, repositories, use cases, and supporting services with GetIt.

`AppServices` groups the UI-facing feature services. `AppScope`, an `InheritedWidget`, makes both `AppServices` and `SettingsController` available to the widget tree:

```dart
final services = AppScope.of(context).services;
final settings = AppScope.of(context).settings;
```

Pages must use `AppScope` rather than importing the GetIt container directly. This keeps service lookup at the application boundary and makes dependencies explicit in feature wiring.

## Cross-Cutting State

<<<<<<< HEAD
### Application Layer

The Application layer holds UI-facing state and orchestration that should not live directly in the widgets.

In this app:

- Feature pages use `StatefulWidget` for local UI state.
- Global app state is managed by `SettingsController` (a `ChangeNotifier`) and observed in `lib/main.dart`.

No BLoC pattern is used by this app.

### Domain Layer

The Domain layer is represented by entities, repositories, and use-cases:

- Entities are immutable data models used by the UI.
- Repositories abstract where data comes from and map raw data into domain entities.
- Use-cases provide an entry point for UI actions and orchestrate repository calls.

### Infrastructure Layer

The Infrastructure layer contains datasources. A datasource is the only place that should talk to external systems such as HTTP APIs, databases, or platform channels.

## Dependency Injection

OpenPlant uses GetIt as a service locator to keep object creation centralized and testable.

- DI container: `lib/core/injection.dart`
- Called from: `lib/main.dart`

`lib/core/injection.dart` registers:

- `SettingsController` (loaded from persistence at startup).
- Datasources, repositories, and use-cases per feature module.
- An `AppServices` aggregate used by the UI (`AppScope.of(context).services`).

The UI does not need to import GetIt directly: `AppScope` exposes `SettingsController` and `AppServices` down the widget tree.
=======
- `SettingsController` is the single source of truth for persisted user preferences.
- `LocaleService` resolves an explicit language selection, then the system locale, and finally English as a fallback.
- `TemperatureFormatter` formats Celsius input in the user-selected unit and active locale.
- `OpenPlantsApp` rebuilds `MaterialApp` when settings or the locale service changes, applying theme, locale, and text-scaling preferences.
>>>>>>> dev
