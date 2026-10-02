---
description: Implement OpenPlants OpenSpec changes with Flutter-aware checks, scoped commits, and safe publication.
---

# OpenPlants OpenSpec work loop

Implement active OpenSpec changes in this Flutter repository one change at a time. Discover the current queue and the
change artifacts before making implementation decisions; never assume a feature name, file layout, or task order from
this command.

## Project contract

- The default development branch is `dev`. Verify that branch before editing, committing, rebasing, or pushing. Do not
  switch branches over a dirty worktree.
- This project uses the Flutter SDK selected by `.fvmrc`. Every Flutter or Dart command MUST be prefixed with `fvm`.
  Never run bare `flutter` or `dart` commands.
- Preserve the existing dependency direction: `Page → UseCase → Repository → DataSource`.
  Do not introduce BLoC or a second state-management pattern.
- Feature code belongs under `lib/pages/<feature>/`. Follow the existing feature naming and structure. For a new
  feature, the normal starting set is datasource, repository, use-cases, entity, and page files.
- Register data sources, repositories, and use cases in `lib/core/injection.dart`, expose use cases through
  `lib/core/app_services.dart`, and access them from widgets through `AppScope.of(context).services`. Widgets must not
  import or access GetIt directly.
- Preserve local persistence conventions: JSON serialization through `shared_preferences`, with `path_provider` file
  references where the existing feature uses files. Do not add a remote service or database without an approved change.
- Edit localization sources under `assets/l10n/`, then run `fvm flutter gen-l10n`. Never hand-edit generated files under
  `lib/l10n/`.
- The app is Android-focused and has no web support. Keep platform-specific work compatible with the existing Android
  setup; do not add web-only APIs. For ONNX changes, preserve the bundled model, preprocessing, session reuse, and
  disposal conventions documented in `.opencode/skills/onnx-flutter/SKILL.md`.

## Tools and repository safety

- Use the repository's `openspec` CLI. If it is unavailable, use `npx --yes @fission-ai/openspec` consistently for the
  same command; do not mix CLI implementations during one change.
- Use CodeGraph only when a `.codegraph/` index exists. This checkout currently has no index, so use `rg`, `sed`, and
  normal Git inspection for unindexed source. Do not create an index merely to complete a routine change.
- Use the local FVM skill for SDK/toolchain questions. Do not require project-specific helper commands that are not
  present in this repository.
- Capture `git status --short --branch` before work. Treat every pre-existing modification as user-owned unless its
  ownership and relevance are clear; never overwrite, reset, or stage unrelated changes.
- Never use `git reset --hard`, destructive checkout commands, force-push, `git add .`, or `git add -A`.
- Keep one OpenSpec change per commit. Stage only inspected implementation, test, documentation, generated, and
  OpenSpec lifecycle files belonging to that change.

## Discover the work queue

1. Verify `git branch --show-current` is `dev`, then capture the initial worktree status.
2. If the worktree is clean, fetch `origin/dev` and fast-forward with `git pull --ff-only origin dev`. If it is dirty,
   preserve the worktree and do not pull over it.
3. Resolve the repository-local OpenSpec root with `openspec context --json`, then enumerate active changes with
   `openspec list --json`. Do not require a registered store when the command reports the nearest repository root.
4. For every active change, run:

   ```text
   openspec status --change "<name>" --json
   openspec instructions apply --change "<name>" --json
   ```

   Read every path returned in `contextFiles`. Treat the returned task progress and state as authoritative for planning,
   but verify implementation and tests independently.
5. Build a dependency order from each proposal, design, specification, task list, and the current worktree. Classify
   each change as eligible, finalize, blocked, or done. Select finalize work first, then partially completed eligible
   work, then dependency-free work by the OpenSpec `lastModified` value and name.
6. If a change has missing or contradictory artifacts, stop that change and report the exact blocker. Do not invent
   requirements or mark tasks complete to make it eligible.

## Implement one change

1. Announce the exact change name, schema, progress, context files, and why it was selected. Re-run its status and apply
   instructions immediately before editing.
2. Read the complete proposal, design, delta specifications, and task list. Trace each task to the affected Flutter
   layer before writing code.
3. Implement in the project's normal path: domain entity and serialization, datasource, repository mapping, use-case
   orchestration, DI/AppServices wiring, then page/widgets/navigation and localization as required. Follow existing
   conventions instead of creating parallel abstractions.
4. For every changed behavior, add or update tests under `test/`. Prefer focused use-case, repository, datasource, and
   widget tests that exercise the real dependency path. Generate Mockito output with
   `fvm dart run build_runner build --delete-conflicting-outputs` only when the change requires it.
5. Run the narrow checks required by the task, then the relevant project checks:

   ```text
   fvm dart format --line-length=120 <scoped paths>
   fvm flutter analyze <scoped paths>
   fvm flutter test --dart-define=platform=vm <scoped test paths>
   ```

   Run `fvm flutter pub get` after dependency changes, `fvm flutter gen-l10n` after ARB changes, and
   `fvm flutter build apk --release` for Android release, Gradle, manifest, asset, or F-Droid changes. Before
   completion, run `fvm dart format --line-length=120 .` when the change affects repository-wide formatting, plus
   `fvm flutter analyze` and `fvm flutter test`. Do not claim a manual, device, CI, or external-service check that was
   not actually performed.
6. Inspect the affected behavior and complete diff after each coherent batch. Run `git diff --check`. Do not edit
   generated localization output by hand, weaken tests, bypass DI, or move logic into pages merely to close a task.
7. Mark an OpenSpec task `- [x]` only after its implementation and required verification pass. Leave manual or external
   tasks unchecked when their evidence is unavailable and record the exact reason.

## Blocked or partial changes

- Exhaust safe, documented local setup and verification options before reporting a blocker.
- If a task needs human approval, a physical device, a remote workflow, F-Droid, or another external system that cannot
  be exercised here, leave it pending. Never fabricate evidence.
- Do not archive a partial change. If verified partial implementation must be preserved, create a scoped checkpoint
  commit with `OpenSpec-Status: partial`; otherwise leave no artificial commit.
- Do not carry a dirty partial change into an unrelated change. Rebuild the queue after a checkpoint and revisit blocked
  work when its prerequisite is complete.

## Complete and publish a change

Completion requires all of the following:

1. `openspec instructions apply --change "<name>" --json` reports every task done and the state is `all_done`.
2. Required Flutter, Android, documentation, and any explicitly requested external checks have actually passed.
3. `openspec validate --strict --no-interactive "<name>"` succeeds.
4. The complete scoped diff is reviewed for unrelated edits, secrets, generated junk, placeholders, and architecture
   violations.

Then:

1. Run `openspec archive -y "<name>"`. This repository's OpenSpec CLI updates the main specs during archive; there is no
   separate sync helper. Inspect the resulting `openspec/specs/` and archive changes before committing.
2. Stage only the selected change's implementation, tests, docs, generated outputs, and OpenSpec archive/spec updates.
   Inspect `git diff --cached`.
3. Create a Conventional Commit directly with Git and include:

   ```text
   OpenSpec-Change: <change-name>
   OpenSpec-Schema: <schema-name>
   OpenSpec-Status: complete
   OpenSpec-Tasks: <complete>/<total>
   ```

4. Fetch `origin/dev` again. If it advanced, rebase only the scoped local commit(s), resolve only understood conflicts,
   and rerun affected verification.
5. Push with `git push origin HEAD:dev`; never force-push. Confirm the local commit is the remote `dev` tip.
6. Rebuild the full OpenSpec queue after each archive or push because other work may have changed dependencies.

## Terminal report

Continue until no eligible or finalizable work remains, repository safety cannot be preserved, or the user interrupts.
Report:

- each complete or partial commit and its change name;
- Flutter/Dart, OpenSpec, Android, and other validations actually run;
- archived changes and publication result;
- remaining active changes;
- exact blocked task IDs and reasons; and
- confirmation that no human or external evidence was fabricated and no incomplete change was archived.
