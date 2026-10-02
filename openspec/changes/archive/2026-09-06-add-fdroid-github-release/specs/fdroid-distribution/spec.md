## ADDED Requirements

### Requirement: F-Droid-ready store listing metadata
The project SHALL version F-Droid-compatible Fastlane metadata under `fastlane/metadata/android/en-US/`, including a
short description, full description, application icon, at least one screenshot, and a changelog file for each released
Android version code.

#### Scenario: Preparing a new store listing
- **WHEN** maintainers prepare the application for F-Droid submission
- **THEN** the repository contains the required Fastlane metadata and visual assets at the documented paths

#### Scenario: Releasing a new Android version
- **WHEN** a release increments the Android version code
- **THEN** maintainers add a matching Fastlane changelog file describing that release

### Requirement: Secret-free unsigned release build
The Android release configuration SHALL produce an unsigned release APK from a clean checkout when no local signing
properties or keystore are present. The project MUST NOT commit signing keys, signing passwords, or other signing
secrets.

#### Scenario: F-Droid-compatible build
- **WHEN** F-Droid or CI builds the release variant without `key.properties`
- **THEN** the build completes and produces an unsigned Android release APK

#### Scenario: Local developer signing
- **WHEN** an authorized maintainer supplies local signing properties outside version control
- **THEN** the existing optional signing path remains available without exposing its secrets in the repository

### Requirement: GitHub Actions release preflight
The project SHALL run a GitHub Actions workflow for pull requests that uses the Flutter version selected by `.fvmrc`,
installs dependencies, verifies formatting, runs static analysis and tests, and builds an unsigned Android release APK.

#### Scenario: Pull request validation
- **WHEN** a pull request changes release-relevant source or configuration
- **THEN** GitHub Actions reports the result of dependency installation, formatting verification, analysis, tests, and
  the unsigned release build

### Requirement: Tagged release provenance
The project SHALL run tagged release verification only from an immutable version tag whose source includes the intended
`pubspec.yaml` version. The workflow SHALL archive the unsigned APK with its checksum and provenance identifying the
tag, commit SHA, and pinned build-tool inputs.

#### Scenario: Version tag verification
- **WHEN** a version tag triggers release verification
- **THEN** GitHub Actions rebuilds the unsigned release APK from that tag and uploads the APK, checksum, and provenance
  as workflow artifacts

#### Scenario: Preparing an F-Droid build recipe
- **WHEN** maintainers submit a release to the main F-Droid repository
- **THEN** the external F-Droid metadata references the corresponding full immutable commit SHA and does not contain
  signing secrets

### Requirement: F-Droid submission guidance
The project SHALL document the official F-Droid submission process, including F-Droid-owned production signing,
monotonically increasing version codes, immutable release commits, and the requirement to verify toolchain
compatibility before submission.

#### Scenario: First-time F-Droid submission
- **WHEN** a maintainer follows the project release documentation
- **THEN** they can distinguish GitHub preflight artifacts from the independently built and signed F-Droid release
