# Releasing OpenPlants

## Overview

OpenPlants is distributed through F-Droid. F-Droid independently rebuilds and
signs the app from public source. GitHub Actions provides unsigned preflight
evidence only; it does not produce the production release.

## Release inputs

- `pubspec.yaml` contains the upstream `versionName` and `versionCode`.
- `fastlane/metadata/android/en-US/` contains the description, graphics, and
  numeric changelogs.
- `metadata/com.domai_tb.openplants.yml` is a staging copy of the F-Droid
  build recipe. The official copy is submitted to the separate `fdroiddata`
  GitLab repository. F-Droid metadata uses `.yml`, not `.yaml`.
- `assets/ml/plant-identification/` must contain the runtime model before a
  release that advertises on-device identification.

## Release process

1. Update `pubspec.yaml`. For this release it is `1.1.0+3`; future version
   codes must increase monotonically.
2. Add or review `fastlane/metadata/android/en-US/changelogs/<versionCode>.txt`.
   Each file must stay below 500 characters.
3. Replace the temporary feature graphic and phone screenshots with real app
   captures before the release commit. The current files are placeholders.
4. Ensure the model strategy below is complete and the model is present in the
   tagged source, or remove/disable the identification feature and its store
   claim for this release.
5. Run the local checks:

   ```bash
   fvm flutter pub get
   fvm flutter gen-l10n
   fvm dart format --line-length=120 .
   fvm flutter analyze
   fvm flutter test --dart-define=platform=vm
   fvm flutter build apk --release --split-per-abi
   ```

   The split build should produce `app-armeabi-v7a-release.apk`,
   `app-arm64-v8a-release.apk`, and `app-x86_64-release.apk` under
   `build/app/outputs/flutter-apk/`.
6. Commit the complete release inputs on the current branch.
7. Merge that branch into `main` manually. Do not tag a pre-merge commit.
8. On the final `main` commit, create the immutable tag `v1.1.0`. Never move
   or force-push a release tag.
9. Push `main` and the tag to the public source repository. The tag workflow
   runs the checks above and uploads the three unsigned APKs, their checksums,
   and build provenance.
10. Copy the F-Droid recipe to `fdroiddata/metadata/com.domai_tb.openplants.yml`,
    replace its staging commit with the full SHA of the tagged release commit,
    run the F-Droid lint/build checks, and open the GitLab merge request.

## F-Droid ABI split

F-Droid builds each ABI as a separate build block. The upstream version code is
`3`; the recipe maps it to `31` (armeabi-v7a), `32` (arm64-v8a), and `33`
(x86_64). Keeping the ABI digit at the least-significant position preserves
correct update ordering between architectures and releases.

The split is configured in the F-Droid recipe and the tag preflight workflow.
There is no default ABI split in `android/app/build.gradle.kts`, so ordinary
Flutter builds remain predictable.

## ML model distribution

Do not make an F-Droid build download the model from Hugging Face during the
build. F-Droid builds in an isolated environment and needs the tagged source and
its build inputs to be inspectable.

Choose one of these before submitting:

1. Preferably export a smaller, validated model (for example dynamic INT8
   quantization), update the app to use that file, and include the exact model
   plus `labels.json`, `preprocessor_config.json`, `config.json`, and
   `onnx_export_info.json` in the release source or a pinned public submodule.
2. If the model remains too large for the app repository, put it in a separate
   public model repository, pin an immutable commit as a Git submodule, and
   document the model, dataset, and redistribution licenses. The F-Droid recipe
   then needs `submodules: true`; the model still has to pass maintainer review.
3. If neither is ready, ship an F-Droid-compatible build without plant
   identification and remove the bundled-model claim until a compliant model is
   available.

The current exporter can create `model.int8.onnx` with
`--quantize-dynamic`, but the app currently loads `model.onnx`; quantization is
not complete until the app is changed and on-device accuracy/runtime are
validated.

## Unsigned builds

The conditional release signing config in `android/app/build.gradle.kts` uses a
local `key.properties` only when it exists. CI and F-Droid builds therefore
produce unsigned APKs; F-Droid signs the final artifacts.

Never commit `key.properties`, signing keystores, passwords, or local Android
SDK paths.
