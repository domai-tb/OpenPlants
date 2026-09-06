# Releasing OpenPlant

## Overview

OpenPlant is distributed through F-Droid. F-Droid independently rebuilds and signs
the app from public source. GitHub Actions provides preflight validation only — it
does not produce production artifacts.

## Version Code and Name

- `versionName` and `versionCode` live in `pubspec.yaml`.
- `versionCode` must increase monotonically for every release. Never reset or reuse
  a version code.
- `versionName` follows semantic versioning (e.g. `1.2.0`).

## Release Process

1. **Update version in `pubspec.yaml`** — bump `versionName` and increment `versionCode`.
2. **Update changelog** — add a file at `fastlane/metadata/android/en-US/changelogs/<versionCode>.txt`.
3. **Commit all release inputs** — the commit that bumps the version is the release commit.
4. **Create an immutable version tag** — `git tag v<versionName>` (e.g. `v1.2.0`).
   Tags must never be moved or force-pushed.
5. **Push the commit and tag** — `git push origin HEAD:dev --tags`.
6. **GitHub Actions preflight** — the tag-triggered workflow rebuilds the unsigned APK
   from the tagged commit, uploads the APK, checksum, and provenance as artifacts.
7. **Review artifacts** — confirm the APK checksum, commit SHA, and version match the
   tag before proceeding to F-Droid submission.

## Unsigned Builds

CI and F-Droid builds produce unsigned APKs. The release signing config in
`android/app/build.gradle.kts` is conditional on a local `key.properties` file.
When absent, the build completes without signing.

- CI artifacts are labeled **unsigned preflight evidence**, not production releases.
- F-Droid independently rebuilds, signs, and publishes the APK.

## F-Droid Submission

1. Ensure the release commit is immutable (no force-push, no tag movement).
2. The F-Droid `fdroiddata` metadata must reference the full commit SHA of the
   release commit.
3. Submit a merge request to `fdroiddata/metadata/<applicationId>.yml` with the
   new version and commit SHA.
4. F-Droid will build, sign, and publish the APK. The signed F-Droid artifact is
   the only production release.

## Toolchain Inputs

Record these for F-Droid build recipe validation:

| Input | Value |
|-------|-------|
| Flutter SDK | 3.41.4 (pinned via `.fvmrc`) |
| Gradle | 8.12 |
| Android Gradle Plugin | 8.9.1 |
| Kotlin | 2.1.0 |
| Min SDK | 26 |
| compileSdk | Set by Flutter |

## What Must Never Be Committed

- `key.properties` or any signing keystore (`.jks`, `.keystore`)
- Signing passwords or aliases
- Local Android SDK paths (`local.properties`)
