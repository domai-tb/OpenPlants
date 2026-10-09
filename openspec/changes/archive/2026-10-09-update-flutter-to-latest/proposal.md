## Why

Pinned Flutter 3.41.4 is ~2 stable releases behind (latest stable 3.47.6, Dart 3.13.5). Staying current keeps security patches, Android toolchain support, and dependency compatibility.

## What Changes

- Pin Flutter to latest stable (3.47.6) via FVM (`.fvmrc`).
- Update Dart SDK constraint in `pubspec.yaml` to match new Dart (3.13.x).
- Run `flutter pub upgrade --major-versions` scope review; update outdated deps where compatible.
- Fix breaking API / lint fallout from Flutter + Dart + dep bumps.
- Regenerate l10n + verify `fvm flutter analyze` and `fvm flutter test` clean.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- None — tooling-only change, no user-visible behavior contract changes (`skip_specs: true`).

## Impact

- `.fvmrc`, `pubspec.yaml`, `pubspec.lock`.
- `android/` toolchain versions if new Flutter requires newer AGP / Kotlin / compileSdk.
- Possible code churn in `lib/` from breaking APIs and stricter lints.
- CI / docs referencing Flutter version.
