## 1. Metric Domain Model and Evaluation

- [ ] 1.1 Add failing unit tests for metric-definition validation, numeric/boolean/categorical measurement validation, defaults, and JSON round trips
- [ ] 1.2 Implement immutable metric-definition and measurement entities with value-type discrimination, optional alert criteria, notes, and entry instructions
- [ ] 1.3 Add failing unit tests for one-sided/two-sided numeric bounds, boolean/category alert values, warning-only behavior, stable alert episodes, deduplication, recovery, edits, and deletions
- [ ] 1.4 Implement pure metric validation and alert-evaluation functions until domain tests pass

## 2. Local Persistence and Use Cases

- [ ] 2.1 Add failing data-source tests for absent collections, successful round trips, malformed JSON preservation, unsupported records, and blocked mutation after decode failure
- [ ] 2.2 Implement separate versioned SharedPreferences collections for metric definitions and measurements using existing corruption-safe codec patterns
- [ ] 2.3 Add failing repository/use-case tests for per-plant queries, create/edit/disable/delete definition flows, typed measurement CRUD, status recalculation, and cross-plant rejection
- [ ] 2.4 Implement metric repository and use cases, including confirmed metric cleanup of measurements, linked rule, and active episode references
- [ ] 2.5 Add bounded/paginated history retrieval needed by graph and textual-history views

## 3. Care Rule and Schedule Integration

- [ ] 3.1 Add failing custom-rule entity and use-case tests for optional metric linkage, same-plant validation, default required measurement, optional completion, and unchanged legacy-rule decoding
- [ ] 3.2 Extend custom care rules and management UI with additive metric-reminder fields and controls compatible with the active `modify-care-rules` change
- [ ] 3.3 Add failing schedule-engine tests for rule-creation fallback, newest-measurement anchoring, manual-entry cadence reset, disabled metrics, warning-only exclusion, stable alert-task identity, completed-episode suppression, and recovery
- [ ] 3.4 Extend schedule inputs and pure computation to emit measurement reminders and one care task per uncompleted active alert episode
- [ ] 3.5 Update repository/use-case orchestration to load metric context and completion history before schedule computation

## 4. Metrics Page and Graphs

- [ ] 4.1 Add widget tests for localized empty states, per-plant scoping, latest-value summaries, active warnings, typed entry controls, and accessible textual history
- [ ] 4.2 Implement plant-scoped metric list, definition form, typed measurement form, correction/deletion flows, and history page using `AppScope` services
- [ ] 4.3 Add painter/unit tests for numeric coordinates and bounds, boolean state transitions, categorical state placement, empty/single-value histories, and bounded rendering
- [ ] 4.4 Implement dependency-free numeric, boolean, and categorical history graphs with semantic labels and matching textual entries
- [ ] 4.5 Add a localized Metrics action to the plant-detail overflow submenu and verify push/back navigation retains plant context

## 5. Care Task Completion and Plant Cleanup

- [ ] 5.1 Add widget/use-case tests for required measurement entry, canceled/invalid/failed entry, optional direct completion, partial completion failure, and alert-task metric navigation
- [ ] 5.2 Update care-task cards and completion flow to collect and persist linked values before required task completion and to open metric context from alert tasks
- [ ] 5.3 Add deletion-cascade tests proving plant removal deletes definitions, measurements, linked measurement rules, and metric alert references idempotently
- [ ] 5.4 Extend plant cleanup orchestration to remove all metric-owned records before deleting the plant record

## 6. Wiring and Localization

- [ ] 6.1 Register metric data source, repository, use cases, evaluator dependencies, and cleanup integration in injection and `AppServices`
- [ ] 6.2 Add English and German ARB strings for metric management, value types, alerts, reminders, graphs, validation, empty states, and navigation
- [ ] 6.3 Run `fvm flutter gen-l10n` and replace all new user-facing literals with generated localization accessors

## 7. Verification

- [ ] 7.1 Run focused metric, schedule, care-rule, task-UI, navigation, persistence, and deletion-cascade tests
- [ ] 7.2 Run `fvm dart format --line-length=120 .`
- [ ] 7.3 Run `fvm flutter analyze` and resolve no diagnostics without approval if failures occur
- [ ] 7.4 Run `fvm flutter test` and stop/report before any corrective change if failures occur
- [ ] 7.5 Manually verify numeric, boolean, and categorical tracking; graph accessibility; warning-only and care-task alerts; required/optional reminders; restart persistence; and plant deletion
