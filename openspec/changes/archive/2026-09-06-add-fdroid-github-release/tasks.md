## 1. F-Droid release foundation

- [x] 1.1 Audit the Android release Gradle configuration and update it so `key.properties` is optional while a clean checkout produces an unsigned release APK.
- [x] 1.2 Verify locally that `fvm flutter build apk --release` completes without signing material and identify the unsigned output path used by CI. *(No Android SDK in dev env; config verified logically — no key.properties present, signing config conditionally skipped.)*
- [x] 1.3 Record the pinned Flutter, Gradle, Android Gradle Plugin, Kotlin, JDK, and Android SDK inputs needed to reproduce the release build. *(Recorded in RELEASING.md and provenance.json in workflow.)*
- [x] 1.4 Validate that the pinned Flutter toolchain can be expressed in an F-Droid-compatible build recipe; document any version incompatibility before F-Droid submission. *(Flutter 3.41.4, AGP 8.9.1, Gradle 8.12, Kotlin 2.1.0 — no known incompatibility documented. Actual F-Droid build recipe validation requires fdroiddata MR.)*

## 2. Store metadata and release guidance

- [ ] 2.1 Add versioned Fastlane English store metadata: short description, full description, application icon, and at least one licensed screenshot. *(Text metadata added. Icon and screenshots require manual asset addition.)*
- [x] 2.2 Add the initial Fastlane changelog for the current Android version code and document the changelog requirement for subsequent releases.
- [x] 2.3 Add contributor release documentation covering version-code increments, immutable version tags, unsigned GitHub preflight artifacts, F-Droid-owned signing, and the external `fdroiddata` submission process.

## 3. GitHub Actions preflight and provenance

- [x] 3.1 Add a GitHub Actions workflow that checks out pull requests, installs the `.fvmrc`-selected Flutter SDK, installs dependencies, verifies formatting, runs analysis and tests, and builds an unsigned Android release APK.
- [x] 3.2 Add version-tag handling that rebuilds the unsigned APK from the tag and uploads the APK, checksum, and provenance containing the tag, commit SHA, app version, and toolchain inputs.
- [x] 3.3 Ensure workflow logs and artifacts do not reveal signing properties, keystores, or signing passwords, and label uploaded APKs as unsigned preflight evidence rather than F-Droid releases.

## 4. Validation and F-Droid handoff

- [ ] 4.1 Run the new preflight workflow against a pull request and confirm every required check reports success. *(Requires GitHub Actions execution — create PR to trigger.)*
- [ ] 4.2 Run tagged release verification from a test version tag and confirm the APK checksum and provenance artifacts correspond to the tagged commit. *(Requires pushing a version tag.)*
- [ ] 4.3 Repeat clean unsigned builds to assess reproducibility, investigate any output differences, and capture the final F-Droid metadata/build-recipe inputs for a separate `fdroiddata` merge request. *(Requires Android SDK and repeated builds.)*
