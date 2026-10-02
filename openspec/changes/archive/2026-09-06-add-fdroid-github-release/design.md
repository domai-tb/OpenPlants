## Context

OpenPlant is an Android-focused Flutter application with FVM-managed Flutter, an optional local Android signing
configuration, and no build or release CI. F-Droid independently rebuilds and signs applications from public source;
therefore, GitHub Actions must validate the same secret-free release path rather than act as the production publisher.

## Goals / Non-Goals

**Goals:**
- Provide an F-Droid-ready source, metadata, and release process.
- Make unsigned Android release builds repeatable from a clean checkout without signing material.
- Catch release-build regressions through GitHub Actions on pull requests and version tags.
- Preserve the existing optional developer signing flow without exposing signing secrets.

**Non-Goals:**
- Publishing APKs to a custom F-Droid repository.
- Automating acceptance into the main F-Droid repository or modifying the external `fdroiddata` repository.
- Replacing F-Droid's signing and publication process with GitHub Releases.
- Adding runtime analytics, proprietary services, or app functionality.

## Decisions

### Use the main F-Droid repository submission model

The project will prepare the source repository for an official F-Droid submission and document the separate
`fdroiddata` merge-request step. F-Droid will build an unsigned APK from an immutable source revision and sign the
published artifact.

This avoids operating repository infrastructure and keeps the distribution process aligned with F-Droid policy.
A custom F-Droid repository was considered but rejected because it would require repository-key operations and would
not provide the discovery or independent build verification of the main repository.

### Make the release build secret-free by default

The Android release configuration will continue to load `key.properties` only when present. When it is absent, the
F-Droid/CI path MUST still produce an unsigned release APK. Keystores and passwords remain local or protected GitHub
secrets and are never included in source, workflow logs, or F-Droid metadata.

This supports F-Droid's isolated builds. Requiring signing secrets in CI was rejected because F-Droid cannot access
them and because it would couple validation to private material.

### Use FVM-pinned tooling and immutable tag inputs

Workflows will use the SDK selected by `.fvmrc` and invoke Flutter through `fvm`. A release starts by incrementing the
`pubspec.yaml` version code, committing all release inputs, and creating an immutable version tag. The tagged workflow
records the commit SHA, version, APK checksum, and relevant toolchain input files alongside its unsigned artifact.

The exact pinned Flutter version must be validated as usable by F-Droid before submitting a build recipe. FVM alone
does not guarantee that F-Droid's build environment supports that SDK.

### Split CI into pull-request preflight and tagged release verification

Pull-request CI will install dependencies, run formatting verification, analysis, tests, and an unsigned Android
release build. Version-tag CI repeats the unsigned build and uploads the APK plus provenance/checksum artifacts for
review and F-Droid submission preparation.

This gives rapid regression feedback without claiming that a GitHub-built artifact is the F-Droid production artifact.
A developer-signed reference APK is deferred because its reproducibility verification and signing-key distribution
need separate operational decisions.

### Store listing assets live with application source

Fastlane metadata under `fastlane/metadata/android/en-US/` will hold descriptions, release changelogs, icon, and
screenshots. This keeps user-visible F-Droid listing content versioned with the app. The F-Droid build recipe remains
external in `fdroiddata/metadata/<applicationId>.yml` and will pin each build to a full commit SHA.

## Risks / Trade-offs

- [F-Droid does not support the pinned Flutter SDK] → Validate an F-Droid-compatible build recipe before submission;
  adjust the project pin or recipe only through a separate reviewed change.
- [Unsigned Gradle release build fails without `key.properties`] → Add CI coverage before relying on the submission
  workflow and keep signing configuration conditional.
- [Flutter/Gradle output is not reproducible] → Build repeatedly from clean checkouts, record toolchain inputs, and
  investigate differences before filing an F-Droid submission.
- [Listing assets are incomplete or do not meet F-Droid requirements] → Validate metadata paths and required media as
  part of release documentation and pre-submission review.
- [GitHub Actions artifacts are mistaken for official F-Droid releases] → Clearly label workflow artifacts as unsigned
  preflight evidence and document F-Droid as the production signer and publisher.

## Migration Plan

1. Add the F-Droid metadata, documentation, and GitHub Actions preflight without altering the app's runtime behavior.
2. Validate the unsigned release build locally and in CI from a clean checkout.
3. Create a tagged release candidate, review uploaded provenance, and verify F-Droid toolchain compatibility.
4. Submit an RFP or merge request to `fdroiddata` that references the immutable release commit.
5. Roll back by disabling the new workflow or reverting the metadata/documentation changes; no user-data migration or
   installed-app rollback is required.

## Open Questions

- Which exact F-Droid-supported Flutter SDK/toolchain will build the app's pinned Flutter version?
- Are icon and screenshots already available under a license and format suitable for the F-Droid listing?
- Should a future change add developer-signed reference APKs for reproducibility verification?
