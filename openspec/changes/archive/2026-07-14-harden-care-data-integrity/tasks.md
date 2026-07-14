## 1. Corruption-Safe Persistence Boundary

- [x] 1.1 Add failing behavior tests in `test/local_collection_codec_test.dart` for missing keys, malformed JSON, wrong top-level shape, an invalid record index, supported migration, raw-value preservation, and blocked mutation after a failed load; run `fvm flutter test --dart-define=platform=vm test/local_collection_codec_test.dart` and confirm the new cases fail.
- [x] 1.2 Create focused typed persistence failures in `lib/core/exceptions.dart` and a reusable collection decoder in `lib/core/local_collection_codec.dart` that distinguishes absence from corruption, validates each record, and never returns partial writable state.
- [x] 1.3 Integrate the decoder into `lib/pages/plant_collection/plant_collection_datasource.dart` and add datasource tests proving corrupt `plant_collection_v1` data is not replaced by add, update, or delete operations.
- [x] 1.4 Integrate the decoder into `lib/pages/plant_journal/plant_journal_datasource.dart`, `lib/pages/diagnosis/diagnosis_datasource.dart`, and `lib/pages/symptom_logger/symptom_logger_datasource.dart`, including the symptom draft map, with feature-specific corruption tests.
- [x] 1.5 Integrate the decoder into every JSON collection in `lib/pages/care_schedule/care_schedule_datasource.dart`, preserving valid existing formats and supported defaults.
- [x] 1.6 Run `fvm flutter test --dart-define=platform=vm test/local_collection_codec_test.dart test/diagnosis_datasource_test.dart` plus the affected journal, symptom, plant collection, and care datasource tests; confirm all persistence cases pass.

## 2. Explicit Care Schedule Actions

- [x] 2.1 Add failing entity serialization tests for an immutable schedule-action record containing plant ID, task type, action kind, action time, targeted occurrence due date, and overridden due date.
- [x] 2.2 Create `lib/pages/care_schedule/care_schedule_action.dart` and add load, save, replace, clear, and stale-action cleanup APIs to `care_schedule_datasource.dart` and `care_schedule_repository.dart`.
- [x] 2.3 Add failing tests to `test/care_schedule_engine_test.dart` for a 1-day and 3-day snooze, skip from the current due date by one effective interval, restart determinism, stale-action rejection, and genuine completion superseding an action.
- [x] 2.4 Update `lib/pages/care_schedule/schedule_engine.dart` inputs and computation so an active action overrides only its targeted occurrence while the latest genuine `TaskCompletion` remains the completion anchor.
- [x] 2.5 Add failing tests to `test/care_schedule_usecases_test.dart` proving snooze and skip persist schedule actions, honor deterministic clock input, do not record `TaskCompletion`, do not create journal entries or care-status changes, and do not return `justCompleted` state.
- [x] 2.6 Update `lib/pages/care_schedule/care_schedule_usecases.dart` so `snoozeTask` validates a positive day count, `skipTask` uses the task's effective interval, and `completeTask` clears an active action after recording genuine care.
- [x] 2.7 Regenerate Mockito outputs with `fvm dart run build_runner build --delete-conflicting-outputs` and run `fvm flutter test --dart-define=platform=vm test/care_schedule_engine_test.dart test/care_schedule_usecases_test.dart`.

## 3. Main-Photo Lifecycle

- [x] 3.1 Add failing repository tests for replacing a main photo, clearing it, leaving it unchanged, entity-save failure after staging a replacement, and old-file cleanup failure.
- [x] 3.2 Update `lib/pages/plant_collection/plant_collection_repository.dart` to compare against the stored plant, stage replacements before persistence, delete the previous file only after a successful entity write, and clean staged files on rollback.
- [x] 3.3 Expose classified photo persistence/cleanup failures through `lib/pages/plant_collection/plant_collection_usecases.dart` without moving file coordination into widgets.
- [x] 3.4 Run the focused plant collection repository/use-case tests and confirm old files are removed for both replacement and explicit clearing while failed writes retain the referenced file.

## 4. Idempotent Plant Deletion Cascade

- [x] 4.1 Add failing deletion tests in `test/plant_deletion_cascade_test.dart` that verify datasource-level `deleteForPlant` operations for journal, symptom, diagnosis, and care schedule data sources.
- [x] 4.2 Add idempotent `deleteForPlant(String plantId)` repository/data-source operations to `lib/pages/plant_journal/`, `lib/pages/symptom_logger/`, `lib/pages/diagnosis/`, and `lib/pages/care_schedule/`; missing records and files succeed while unexpected storage errors propagate.
- [x] 4.3 Create `lib/pages/plant_collection/plant_data_cleanup.dart` as the explicit cleanup collaborator that removes child metadata and files in a retry-safe order and logs errors without blocking subsequent operations.
- [x] 4.4 Inject the cleanup collaborator into `lib/pages/plant_collection/plant_collection_detail_page.dart` via `didChangeDependencies` using existing services.
- [x] 4.5 Simplify `lib/pages/plant_collection/plant_collection_detail_page.dart` `_deletePlant` method to call `PlantDataCleanup.deleteAllForPlant` and remove scattered cleanup calls.
- [x] 4.6 Add regression tests in `test/plant_data_cleanup_test.dart` proving the orchestrator calls all data sources and continues even if one fails.
- [x] 4.7 Regenerate affected mocks and run the plant deletion cascade and cleanup test files with the pinned FVM SDK.

## 5. Versioned ONNX Model Cache

- [x] 5.1 Add a failing `test/plant_classifier_cache_test.dart` using temporary files and injected asset/cache adapters for matching reuse, missing identity, changed identity, empty/missing pair members, interrupted temporary files, and copy failure.
- [x] 5.2 Add a release-controlled model identity asset under `assets/ml/plant-identification/` and register it alongside both ONNX files in `pubspec.yaml`.
- [x] 5.3 Create `lib/pages/plant_identification/classifier/model_asset_cache.dart` to validate the complete cache unit, stage and flush both assets, replace the final pair, and write the identity marker last.
- [x] 5.4 Update `lib/pages/plant_identification/classifier/plant_classifier.dart` to obtain the model path through `ModelAssetCache` while preserving lazy session reuse and disposal.
- [x] 5.5 Run `fvm flutter test --dart-define=platform=vm test/plant_classifier_cache_test.dart` and confirm every invalid or legacy cache state refreshes both files before session creation.

## 6. Integration and Validation

- [x] 6.1 Add cross-feature regression coverage proving snooze/skip never enter care history or `justCompleted`, a completed task clears its override, and plant deletion removes all records from unified queries.
- [x] 6.2 Run `fvm dart format --line-length=120 .` and verify no unintended generated or unrelated files changed.
- [x] 6.3 Run `fvm flutter analyze`; stop and report any diagnostic before making additional fixes.
- [x] 6.4 Run `fvm flutter test`; stop and report any failure before making additional fixes.
- [x] 6.5 Manually verify on Android that snooze duration survives restart, skip advances one interval, plant deletion removes all visible history, main-photo clear removes the file, and the first classifier use refreshes a legacy cache once.
