## 1. Pin toolchain

- [ ] 1.1 `fvm install 3.47.6 && fvm use 3.47.6 && fvm flutter doctor`
- [ ] 1.2 Update Dart SDK constraint in `pubspec.yaml` to cover Dart 3.13.x
- [ ] 1.3 Fix Android toolchain (AGP / Kotlin / compileSdk) only to minimum new Flutter requires

## 2. Dependencies

- [ ] 2.1 `fvm flutter pub upgrade`, review outdated, apply `--major-versions` only for blockers
- [ ] 2.2 Record any held deps (e.g. permission_handler) with reason comment

## 3. Fallout and verify

- [ ] 3.1 Fix breaking Dart/Flutter APIs in `lib/`
- [ ] 3.2 Bump `flutter_lints` if needed and clear new violations
- [ ] 3.3 `fvm flutter gen-l10n`, `fvm flutter analyze`, `fvm flutter test` all green
- [ ] 3.4 `openspec validate update-flutter-to-latest --strict` passes
