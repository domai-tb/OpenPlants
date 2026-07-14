## Why

Several local workflows currently blur user intent or can silently leave stale, orphaned, or unrecoverable data. Care deferrals are recorded as completed care, plant deletion is only partially cascaded, malformed persistence can be overwritten as an empty collection, photo replacement leaks files, and model updates can continue using stale cached ONNX assets.

## What Changes

- Represent snooze and skip as scheduling actions rather than `TaskCompletion` records.
- Honor the selected snooze duration and advance skipped tasks by one effective interval without adding completion history or `justCompleted` state.
- Move plant deletion orchestration into the application/domain layers and remove every plant-owned record and file.
- Delete superseded or explicitly cleared main-photo files using the previously persisted plant state.
- Distinguish a missing persistence key from malformed persisted data, preserve undecodable raw values, and surface classified failures instead of returning an empty collection.
- Validate cached ONNX model assets against a bundled version or fingerprint and refresh the model plus external data file as one unit when they differ.
- Add regression coverage for scheduling semantics, history integrity, cascade deletion, persistence corruption, photo cleanup, and model cache invalidation.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `care-schedule-engine`: Scheduling anchors will account for explicit snooze and skip state without treating those actions as completed care.
- `care-tracking`: Snooze and skip will no longer create task completions, journal entries, care-status updates, or completion feedback.
- `care-task-history`: Completion history will contain only genuine care events recorded by marking a task done or manually adding history.
- `plant-inventory`: Plant deletion will remove all plant-owned records and files through use-case orchestration, and editing will clean up replaced or cleared main photos.
- `offline-storage`: Missing collections will remain valid empty state while malformed collections produce classified failures and are protected from implicit overwrite.
- `plant-classifier`: Cached ONNX model files will be validated against bundled model identity and atomically refreshed when stale or incomplete.
- `plant-photo-timeline`: Deleting a plant will remove its growth-photo metadata and files as part of the ownership cascade.

## Impact

- Care schedule entities, engine inputs, repository/data-source persistence, use cases, and regression tests.
- Plant collection deletion and update flows plus symptom, diagnosis, journal, care, custom-rule, draft, and photo repositories/data sources.
- SharedPreferences-backed collection readers and writers across plant, journal, symptom, diagnosis, and care features.
- ONNX classifier cache metadata and file-copy lifecycle.
- Existing persisted completion records remain readable; no automatic attempt will reinterpret historical snooze/skip records because they are indistinguishable from genuine completions.
- No new runtime package is required; Flutter and Dart validation remains pinned through FVM.
