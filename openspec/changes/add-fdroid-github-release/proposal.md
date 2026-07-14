## Why

OpenPlant has no automated Android release validation or F-Droid distribution setup. A source-built F-Droid release path will make the Android-only app available through a privacy-respecting FLOSS store while using GitHub Actions to detect release-build drift before submission.

## What Changes

- Add F-Droid-ready Fastlane store metadata, including localized descriptions, release changelogs, icon, and screenshots.
- Define a reproducible unsigned Android release contract that builds from a clean, public source checkout without signing secrets.
- Add GitHub Actions preflight checks for formatting, static analysis, tests, and unsigned Android release builds.
- Add tag-triggered release verification that archives the unsigned APK, checksums, and build provenance for the tagged source revision.
- Document the official F-Droid submission workflow, including immutable release commits, version-code progression, and F-Droid-owned production signing.

## Capabilities

### New Capabilities
- `fdroid-distribution`: F-Droid metadata, reproducible unsigned release requirements, and GitHub Actions release preflight for OpenPlant.

### Modified Capabilities

- None.

## Impact

- New GitHub Actions workflow(s) under `.github/workflows/`.
- Android Gradle release configuration, if needed to ensure a secret-free unsigned release build.
- New Fastlane metadata and graphic assets under `fastlane/metadata/android/`.
- Release documentation and contributor instructions.
- No runtime app APIs, user-facing features, or third-party runtime dependencies.
