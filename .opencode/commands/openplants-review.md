---
description: Review OpenPlants OpenSpec worker commits, fix verified defects, and publish review markers.
---

# OpenPlants OpenSpec review loop

Review OpenSpec worker commits one at a time against the current OpenPlants Flutter implementation and its OpenSpec
contract. Inspect the exact worker diff, the relevant context, and the behavior on the current `dev` branch. Never treat
a checked task or archived change as proof that the implementation is correct.

## Project contract

- The default development branch is `dev`. Verify it before editing, committing, rebasing, or pushing. Do not switch
  branches over a dirty worktree.
- The Flutter SDK comes from `.fvmrc`; every Flutter or Dart command MUST be prefixed with `fvm`. Never run bare
  `flutter` or `dart` commands.
- Review the dependency path `Page → UseCase → Repository → DataSource` and the existing no-BLoC approach.
  Check DI through `lib/core/injection.dart`, `AppServices`, and `AppScope.of(context).services`.
- Check that local data follows the existing JSON/`shared_preferences` conventions, ARB is the source for localization,
  generated `lib/l10n/` files are not hand-edited, and Android-only code does not introduce web assumptions.
- Keep tests under `test/` and honor the project's strict lints, package imports, trailing commas, and 120-character
  formatting rules.

## Tools and safety

- Use the repository's `openspec` CLI and its actual commands: `context`, `list`, `show`, `status`, `instructions`,
  `validate`, and `archive`. If it is unavailable, use `npx --yes @fission-ai/openspec` consistently.
- Use CodeGraph only if `.codegraph/` exists. This checkout is unindexed, so use `rg`, `sed`, and Git inspection for
  source and dependency tracing. Do not initialize indexing as a review side effect.
- Capture `git status --short --branch` and preserve all unrelated user changes. Never use destructive reset/checkout
  commands, `git add .`, `git add -A`, amend another worker commit, rewrite published history, or force-push.
- Report findings directly in the review result and use only repository-local commands and standard Git operations.

## Discover worker commits and contracts

1. Verify the current branch is `dev` and capture the initial status. If the worktree is clean, fetch `origin/dev` and
   fast-forward with `git pull --ff-only origin dev`; otherwise preserve the dirty worktree and do not pull over it.
2. Inspect first-parent history and identify worker commits containing these trailers:

   ```text
   OpenSpec-Change: <change-name>
   OpenSpec-Schema: <schema-name>
   OpenSpec-Status: partial|complete
   OpenSpec-Tasks: <complete>/<total>
   ```

3. A worker is reviewed only after a later first-parent commit contains the exact full worker SHA and matching review
   metadata:

   ```text
   Reviewed-Commit: <full-worker-sha>
   OpenSpec-Change: <same-change>
   Review-Result: pass|fixed
   ```

4. Queue unreviewed workers oldest first. Ignore ordinary commits and review-marker commits. A trailer-less commit may
   be reviewed only when its subject/body identifies exactly one change and exactly one matching OpenSpec context;
   otherwise block rather than guessing.
5. Resolve the contract dynamically. For an active change, run:

   ```text
   openspec status --change "<name>" --json
   openspec instructions apply --change "<name>" --json
   ```

   For an archived change, locate the exact directory under `openspec/changes/archive/` and read its proposal, design,
   specs, and tasks. Validate the relevant change/spec before reviewing implementation.

## Review one worker commit

1. Announce the worker SHA, parent, change, schema, claimed status/progress, and resolved context.
2. Inspect the isolated diff with `git diff <parent>..<worker-sha>` and inspect earlier partial commits for the same
   change when needed. Compare the result with current `dev` behavior after later commits.
3. Trace every claimed task and scenario to implementation and tests. Specifically check:

   - correct layering, entity serialization, repository mapping, use-case behavior, DI registration, `AppServices`, and
     widget access through `AppScope`;
   - persistence migration, malformed data handling, idempotency, deletion/cleanup, and compatibility with existing
     `shared_preferences` data;
   - localization source/generated-file workflow and user-facing text coverage;
   - Android permissions, assets, release configuration, ONNX lifecycle, and platform boundaries when relevant;
   - asynchronous cleanup, concurrency, error paths, null safety, test isolation, and regressions;
   - real production wiring instead of placeholders, hard-coded identities, mocks in runtime code, or logging-only
     controls; and
   - accidental scope, secrets, generated junk, dead code, lint violations, and untested behavior.

4. Build verification from the affected files and contract. Run the narrowest useful checks first, then the required
   aggregate checks:

   ```text
   fvm dart format --line-length=120 --set-exit-if-changed <scoped paths>
   fvm flutter analyze <scoped paths>
   fvm flutter test --dart-define=platform=vm <affected tests>
   ```

   Run `fvm flutter pub get` after dependency changes, `fvm flutter gen-l10n` for ARB changes,
   `fvm dart run build_runner build --delete-conflicting-outputs` when generated Mockito code is affected,
   `fvm flutter build apk --release` for Android/release changes, and the full `fvm flutter analyze` plus
   `fvm flutter test` before a pass/fixed result when the scope warrants it. Never claim a device, CI, F-Droid, or
   other external check that was not run.
5. Run `openspec validate --strict --no-interactive "<change-name>"` (and the affected spec validation when relevant),
   then run `git diff --check` and inspect the complete review diff.
6. Report each finding before fixing it using one line with severity (`🔴`, `🟡`, or `🔵`), location, problem, and
   concrete fix. Red findings cover security, correctness, data loss, migration failure, or contract violations; yellow
   findings cover incomplete coverage and operational/maintainability risk; blue findings are optional improvements.
7. Fix every actionable red and yellow finding in the current change, add regression tests, and keep the fix scoped to
   the reviewed contract. If the contract is contradictory or required external evidence is unavailable, block the
   review instead of rewriting history or marking it passed.

## Review commit and publication

After all blockers are fixed and verification passes:

1. Stage only review fixes and inspect `git diff --cached`.
2. With fixes, create a focused Conventional Commit directly with Git. Without fixes, create an intentional empty marker
   commit with `--allow-empty`.
3. Include these trailers in the review commit:

   ```text
   Reviewed-Commit: <full-worker-sha>
   OpenSpec-Change: <same-change>
   Review-Result: pass|fixed
   ```

4. Fetch `origin/dev`. If it advanced, rebase only the scoped review commit, inspect interactions, and rerun affected
   verification.
5. Push with `git push origin HEAD:dev`; never force-push. Confirm the review marker is a descendant of the exact worker
   SHA and that local `dev` equals `origin/dev`.
6. Rebuild the review queue after each push because later workers may change the contract or behavior.

## Terminal report

Continue until no unreviewed worker remains, repository safety cannot be preserved, or the user interrupts. Report each
worker SHA/change/status, findings and fixes, validations actually run, review commit and push result, and every blocked
or unreviewed commit with its exact reason. Never create a pass/fixed marker for a blocked review.
