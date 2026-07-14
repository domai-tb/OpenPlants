# Getting Started

OpenPlants is an Android-focused Flutter application. The project pins Flutter **3.41.0** with [FVM](https://fvm.app/), so always run Flutter and Dart through `fvm`.

## Prerequisites

1. Install Flutter tooling and FVM.
2. Install Android Studio or another Android SDK setup, then create or connect an Android device. Android API 26 is the minimum supported version.
3. Clone the repository and open its root directory.

## Run the App

From the repository root:

```bash
fvm flutter pub get
fvm flutter run
```

Use Flutter's terminal commands while the app is running: `r` performs a hot reload, `R` performs a hot restart, and `q` stops the session.

## Contributor Commands

```bash
# Static analysis and the project's strict lint rules
fvm flutter analyze

# Full test suite
fvm flutter test

# One test file on the Dart VM
fvm flutter test --dart-define=platform=vm test/path.dart

# Regenerate localization after changing assets/l10n/*.arb
fvm flutter gen-l10n

# Format source using the project's 120-character line length
fvm dart format --line-length=120 .
```

Do not use bare `flutter` or `dart`: doing so can select a different SDK version from the one configured by `.fvmrc`.

## Before Opening a Pull Request

Run `fvm flutter analyze` and `fvm flutter test`. When adding localized text, update every supported ARB file and run `fvm flutter gen-l10n` before validating the app.
