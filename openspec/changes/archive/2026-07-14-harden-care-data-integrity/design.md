## Context

OpenPlants stores care history and most feature collections as JSON in SharedPreferences, stores plant photos and ONNX assets on the local filesystem, and composes behavior through Page → UseCase → Repository → DataSource. Several reviewed paths currently cross those boundaries incorrectly: widgets coordinate partial plant deletion, snooze and skip reuse the completion model, collection readers collapse any decode failure into an empty list, and the classifier trusts any non-empty cached files.

The change crosses care scheduling, plant ownership, persistence, and inference infrastructure. It must preserve existing readable data, remain Android/offline compatible, and require no new runtime package.

## Goals / Non-Goals

**Goals:**

- Preserve the semantic distinction between completed care and schedule-only actions.
- Make snooze duration and skip cadence deterministic and testable.
- Define one application-layer owner for deleting a plant and all plant-owned records and files.
- Prevent malformed local data from being interpreted and later persisted as an empty collection.
- Clean up replaced and cleared main-photo files using persisted prior state.
- Refresh both ONNX model files when their bundled model identity changes.
- Add behavior-focused regression tests for every reviewed failure mode.

**Non-Goals:**

- Reclassifying historical `TaskCompletion` records that may have originated from snooze or skip; those records contain no discriminator.
- Replacing SharedPreferences with a database or introducing a general transaction framework.
- Adding cloud synchronization, backup, or user-facing data-repair screens.
- Redesigning care-task UI beyond the state needed to display the corrected schedule.
- Changing model preprocessing, labels, inference ranking, or the ONNX runtime package.

## Decisions

### Decision 1: Persist active schedule overrides separately from completion history

Introduce a schedule-only record keyed by plant and task type. It records the action (`snooze` or `skip`), when it was requested, the schedule occurrence it applies to, and the overridden due date. Only one active override is required per plant/task pair.

- Snooze sets the due date to the action time plus the selected positive day count.
- Skip advances the current occurrence's due date by one effective interval, preserving cadence rather than anchoring to the action time.
- Marking a task done records a genuine `TaskCompletion` and clears any active override for that plant/task.
- The schedule engine applies an override only to the occurrence it identifies; stale overrides are ignored and removed during the next write path.
- Snooze and skip never update care status, create journal entries, enter completion history, or produce `justCompleted` status.

This keeps the completion event log truthful while allowing the engine to remain deterministic from explicit inputs. Adding an action discriminator to `TaskCompletion` was rejected because it would keep non-care events in APIs and UI that promise completion history. Recomputing snooze only in memory was rejected because app restarts would lose the action.

### Decision 2: Put plant deletion in a use-case-owned, idempotent cascade

`PlantCollectionUsecases.deletePlant` becomes the orchestration boundary. It receives explicit repository/use-case dependencies for every plant-owned collection: journal entries, growth photos, symptoms, diagnoses, care completions, care schedule overrides/configuration, custom rules, and drafts. Widgets request deletion once and do not call individual data sources.

Child metadata and files are removed before the plant record. The plant is deleted last so a mid-cascade failure leaves an owning plant that can be retried rather than creating records that reference an absent plant. Each child deletion is idempotent: an already-missing record or file is treated as complete, while unexpected I/O or persistence failures are surfaced. This is not a true cross-store transaction, but it provides deterministic retry semantics with the current storage stack.

A generic global cascade registry was rejected as unnecessary indirection for the current fixed set of owners. Keeping orchestration in the detail page was rejected because navigation and disposal can interrupt it and because the page cannot enforce data ownership.

### Decision 3: Use persisted prior state for safe main-photo transitions

The repository loads the stored plant before deciding file operations.

- For replacement, save the new file, persist the new path, then delete the old file.
- For clearing, persist a null path, then delete the old file.
- For unchanged paths, perform no file operation.
- If entity persistence fails, retain the old file and delete any newly staged replacement.
- If post-persistence cleanup fails, surface a classified cleanup failure so the operation can be retried; the persisted entity remains authoritative.

Deleting the old file before saving the updated entity was rejected because a write failure would leave the plant pointing to a missing file.

### Decision 4: Centralize collection decoding and block writes after corruption

SharedPreferences-backed data sources use a common typed decode boundary that distinguishes:

1. missing key — valid empty collection;
2. valid JSON list with valid records — decoded collection;
3. known older schema — migrated collection;
4. malformed JSON, wrong top-level type, or invalid record — classified persistence failure.

The decoder may identify the failing record index for diagnostics, but it does not return a partial writable collection. Raw SharedPreferences content is left untouched, and callers cannot save through a failed load path. This prevents a later add/update from replacing recoverable raw data with only the records that happened to decode.

Returning valid records while skipping malformed ones was rejected because the next full-list save would silently erase skipped records. Continuing to catch all exceptions and return `[]` was rejected because it makes absence and corruption indistinguishable.

### Decision 5: Treat the ONNX model and external data file as one versioned cache unit

Bundle a model identity value alongside the classifier assets and persist the installed identity in the cache directory. Cache validation requires all three conditions: model file exists and is non-empty, external data file exists and is non-empty, and cached identity equals bundled identity.

On mismatch, copy both assets to temporary files, flush them, replace the cached pair, and write the identity marker last. A missing marker causes a one-time refresh for existing installations. The identity is a release-controlled version/fingerprint that must change whenever either model asset or its tensor/label contract changes.

Checking only existence or file length was rejected because stale but valid files pass. Hashing large assets on every startup was rejected because a trusted bundled identity gives deterministic invalidation without repeated model-size I/O or a new hashing dependency.

### Decision 6: Test contracts at their owning layer

- Schedule-engine/use-case tests cover exact snooze dates, skip cadence, restart persistence, override clearing, and absence from completion history and `justCompleted` state.
- Repository/use-case tests cover every plant-owned collection, deletion ordering, idempotent retry, and main-photo replacement/clear failure paths.
- Data-source tests cover missing keys, malformed JSON, wrong top-level types, invalid records, known migrations, raw-value preservation, and blocked writes.
- Classifier cache tests use temporary files and injected asset/cache adapters to cover valid reuse, legacy cache refresh, version mismatch, incomplete copy recovery, and identity-marker ordering.

Tests use deterministic clocks and filesystem/storage fakes rather than waiting on wall-clock time or exercising third-party internals.

## Risks / Trade-offs

- **Historical false completions remain in history** → Do not guess; document the limitation and ensure only future actions use schedule overrides.
- **The deletion cascade is not atomic across SharedPreferences and files** → Delete children before the plant, make every step idempotent, and propagate failures for retry.
- **A classified persistence failure can block a feature until data is repaired** → Preserve raw data and provide precise collection/key and record-index context; never trade availability for silent data loss.
- **A model update can omit the required identity bump** → Keep identity metadata next to model assets and add a release/test check that the expected identity is installed with the pair.
- **Temporary ONNX files can remain after interruption** → Ignore or remove stale temporary files before staging the next refresh; write the identity marker only after both final files are valid.
- **More use-case dependencies increase injection wiring** → Aggregate deletion dependencies behind a focused plant-data cleanup collaborator if constructor growth becomes excessive, while keeping explicit ownership.

## Migration Plan

1. Add schedule-override persistence with an empty default; keep existing completion JSON readable without schema changes.
2. Route new snooze and skip actions to overrides. Do not migrate ambiguous historical completion records.
3. Introduce typed decoding per collection while preserving existing valid JSON formats and known default migrations.
4. Move plant deletion orchestration to the use-case layer and update dependency injection before removing page-level cleanup calls.
5. Add the bundled ONNX identity. Existing caches without an identity marker refresh once on first classifier use.
6. Rollback remains possible because existing entity formats are retained. Schedule overrides and cache identity metadata are additive and can be ignored by older builds; no destructive data migration runs at startup.

## Open Questions

None. Implementation may choose concrete class names, but the behavioral boundaries and failure semantics above are fixed.
