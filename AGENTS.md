# AGENTS.md — OpenPlants

Flutter plant companion app with Clean Architecture. AGPL v3.

## Quick Commands

All `flutter` and `dart` commands MUST be prefixed with `fvm` — Flutter Version Manager handles the pinned version.

```bash
fvm flutter pub get          # install deps
fvm flutter run              # launch on connected device/emulator
fvm flutter analyze          # lint + metrics (uses analysis_options.yaml)
fvm flutter test             # run all tests
fvm flutter test --dart-define=platform=vm test/path.dart  # single test file
fvm flutter gen-l10n         # regenerate localization (lib/l10n/)
fvm dart format --line-length=120 .  # format everything
```

No `Makefile` or task runner is configured. Build helpers live in `scripts/`.

## Flutter Version

Pinned to **3.41.4** via FVM (`.fvmrc`). Never use bare `flutter` or `dart` — always go through `fvm`.

## Architecture

Layered Clean Architecture, no BLoC. Dependency flow: **Page → UseCase → Repository → DataSource**.

Feature modules live in `lib/pages/<feature>/`. Their files follow the feature's needs; do not add empty layers just to
match a template. Keep UI, use-cases, repositories, and data sources in the existing dependency direction.

**DI**: GetIt via `lib/core/injection.dart`. UI accesses deps through `AppScope.of(context).services` — never import GetIt directly in widgets.

**Core modules** (`lib/core/`): `app_scope.dart` (InheritedWidget for DI), `app_services.dart` (aggregate of all page use-cases), `settings.dart`, `themes.dart`, `exceptions.dart`, `failures.dart`.

## Lint (Strict)

`analysis_options.yaml` enforces 150+ lint rules from `package:flutter_lints` plus many additional rules.

Key enforced rules:
- **`always_use_package_imports`** — no relative imports (e.g. `import 'package:open_plant/...'`)
- `require_trailing_commas`
- `prefer_single_quotes`
- `prefer_const_constructors`
- `avoid_print` (use `debugPrint`)
- `prefer_final_locals` / `prefer_final_in_for_each`
- `unawaited_futures` (must use `unawaited()` or await explicitly)

Run `fvm flutter analyze` before pushing — CI-equivalent checks will fail on any lint violation.

## Localization

ARB files in `assets/l10n/`. Template: `l10n_en.arb`. Generated output: `lib/l10n/`.

After editing ARB files, run `fvm flutter gen-l10n` to regenerate. Access translations via `context.l10n.someKey`.

## Settings Persistence

`shared_preferences` with JSON serialization. `SettingsController` (a `ChangeNotifier`) is the single source of truth. Loaded at startup in `injection.dart` before `runApp()`.

## Line Length

120 characters (configured in `.vscode/settings.json` and `analysis_options.yaml`). Format on save is enabled.

## Adding a New Feature

1. Follow the closest existing feature's structure and add only the layers the feature needs.
2. Register required dependencies in `lib/core/injection.dart` and expose UI dependencies through `AppServices`/`AppScope`.
3. Add navigation where the feature is user-facing.
4. Run `fvm flutter analyze` and the relevant `fvm flutter test` checks.

## Testing

Tests live under `test/` and use `flutter_test` plus the existing `test` and `mockito` dependencies. Add focused tests with behavior changes.

## CI

Workflows are in `.github/workflows/`: documentation updates publish the wiki, and tagged releases run formatting, analysis, tests, and unsigned APK preflight builds.

## Gotchas

- **Android is the primary platform** (minSdk 26). iOS project files are maintained but are not covered by release preflight.
- **No `opencode.json`** exists — no custom OpenCode config in this repo.
- **`TODO` comments are ignored** by the analyzer (`errors: todo: ignore`).
- `close_sinks` and `no_default_cases` are also ignored.
- `implicit-casts` and `implicit-dynamic` are enabled (not strict null-safety everywhere).
- Release builds use ProGuard (`android/app/proguard-rules.pro`); keep rules must match dependencies used by the app.
