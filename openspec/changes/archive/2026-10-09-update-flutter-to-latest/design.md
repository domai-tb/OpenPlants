## Context

See proposal.md Why. Current pin: Flutter 3.41.4 (`.fvmrc`), Dart `>=3.6.0 <4.0.0`, Kotlin 2.3.20, minSdk 26, Java 17. Target: Flutter 3.47.6 stable (Dart 3.13.5). All `flutter`/`dart` commands run via `fvm`.

## Goals / Non-Goals

**Goals:**
- Reproducible pin to 3.47.6 via FVM for every checkout.
- Compatible dep set with zero `analyze` / `test` failures.

**Non-Goals:**
- No feature work, no Dart 4 migration, no minSdk bump unless new Flutter forces it.
- No AGP/Kotlin upgrade beyond what 3.47.6 requires.

## Decisions

- Pin exact `3.47.6` in `.fvmrc`, not `stable` float. Alternative (track stable): rejected, breaks reproducible builds.
- `fvm install 3.47.6 + fvm use 3.47.6`, then `fvm flutter pub upgrade` first (minor-safe), then `--major-versions` only for blockers. Alternative (majors first): rejected, maximizes breakage surface.
- Tighten SDK constraint to tested range (e.g. `>=3.13.0 <4.0.0`) after install. Alternative (leave `>=3.6.0`): allows wrong-Dart resolves.
- Fix fallout in dependency order: Android toolchain → Dart language breakage → lint (`flutter_lints` 6.x may need bump) → `gen-l10n` → tests. Alternative (code first): churns against shifting APIs.
- Keep `permission_handler` 13.x hold comment unless new compileSdk supports API 37; revisit only if upgrade unblocks it.

## Risks / Trade-offs

- [Risk] New Flutter requires newer AGP/Kotlin/compileSdk → Mitigation: follow `flutter doctor --android-licenses` + template diff, change minimum to boot.
- [Risk] Third-party plugins (onnxruntime, notifications, camera) lag behind → Mitigation: check changelogs first, hold individual deps, note holds in pubspec comments.
- [Risk] `flutter_lints` major bump adds new violations → Mitigation: fix or document `ignore` with reason; keep diff reviewable.
- [Risk] Golden/l10n churn → Mitigation: regenerate l10n, run full test suite before calling done.

## Migration Plan

1. `fvm install 3.47.6 && fvm use 3.47.6 && fvm flutter doctor`
2. Update SDK constraint, `pub upgrade`, triage majors, fix code/lints.
3. `gen-l10n`, `analyze`, `test` green. Rollback: revert `.fvmrc` + `pubspec.lock`, `fvm use 3.41.4`.

## Open Questions

- None.
