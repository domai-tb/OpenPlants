## Context

See `proposal.md` for motivation. OpenPlants uses feature-local Clean Architecture (`Page → UseCase → Repository → DataSource`), GetIt wiring exposed to widgets through `AppScope`, and JSON collections in SharedPreferences. Plant detail already opens per-plant journal and assessment pages. Care scheduling already supports per-plant custom rules and persisted task completions. No chart package is installed.

This change crosses plant inventory, custom rules, schedule computation, task completion, persistence, localization, and UI. Existing stored plants, rules, and completions must remain readable. The active `modify-care-rules` change also touches custom-rule presentation, so metric linkage must remain an additive optional extension rather than redefining its unified rule-list behavior.

## Goals / Non-Goals

**Goals:**

- Keep metric definitions, values, evaluation, and history inside one focused feature boundary.
- Make alert and scheduling calculations deterministic and independently testable.
- Reuse current care-rule and care-task infrastructure rather than create a second reminder system.
- Preserve existing data and corruption-safety behavior with additive storage.
- Render all supported value types accessibly without adding a chart dependency.

**Non-Goals:**

- Sensor, Bluetooth, cloud, account, import, export, or cross-device synchronization.
- Statistical forecasting, trend recommendations, aggregation, or AI analysis.
- Multiple values in one measurement, formulas between metrics, or unit conversion.
- Global metric templates or sharing metric definitions across plants.
- Push-notification delivery changes.

## Decisions

### Decision: Use a dedicated plant-metrics feature instead of plant fields or journal entries

**Choice:** Add a `plant_metrics` feature containing metric definitions, measurements, a pure evaluator, persistence, use cases, and pages/widgets. Definitions and measurements are separate immutable entities joined by metric ID and plant ID.

**Rationale:** Definitions change rarely while measurements form growing time series. Separate entities avoid rewriting plant records for every sample and keep graph/rule logic out of the general journal. They also support deleting or disabling one metric without changing unrelated plant data.

**Alternatives considered:**

1. Add fixed water/nutrient fields to each plant → rejected because users require arbitrary metrics and history.
2. Store measurements as journal entries → rejected because freeform journal records do not own typed units, category options, targets, or measurement-specific rules.
3. Build a generic application-wide statistics engine → rejected as speculative; metrics are plant-owned in this scope.

### Decision: Store a discriminated primitive measurement value

**Choice:** A definition stores `valueType` (`numeric`, `boolean`, or `categorical`). A measurement stores one JSON primitive payload plus definition and plant identifiers. Use cases validate payload type, finite numeric values, and configured category membership before persistence. Numeric type is the default for older or minimal records.

**Rationale:** One measurement entity and collection keep persistence/query code small while the definition supplies validation and presentation context. Runtime validation at repository/use-case boundaries prevents invalid payloads from reaching evaluation or graph rendering.

**Alternatives considered:**

1. Three measurement entity classes and repositories → stronger compile-time variants but triples routine storage and list handling.
2. Store every value as text → simplest persistence but loses numeric fidelity and shifts parsing ambiguity into every consumer.
3. Assign numbers to categories → rejected because users selected named alert options and should not manage artificial scores.

### Decision: Keep alert configuration on metric definitions

**Choice:** Numeric definitions hold nullable lower/upper bounds. Boolean and categorical definitions hold an optional set of alert values. Definitions also hold `alertResponse`, defaulting to warning-only. The pure evaluator consumes a definition and ordered measurements and returns current state plus alert-episode identity.

An alert episode begins at the first alerting measurement after no data or a normal measurement. Its stable identity uses metric ID plus that first measurement ID. Consecutive alerting values retain the same episode identity. A normal value closes the episode. Care-task response maps an uncompleted active episode to one deterministic alert task; completion for that episode suppresses reappearance until recovery starts a future episode.

**Rationale:** Alert criteria describe meaning of collected data, not reminder cadence. Deriving state avoids another mutable alert-state collection. Stable episode identity supports task deduplication and completion using existing completion history.

**Alternatives considered:**

1. Persist mutable active-alert records → unnecessary duplicate state that can drift from measurement history.
2. Create one task per alerting measurement → noisy and violates deduplication.
3. Put target criteria on custom care rules → couples warnings to reminder existence even though users may track and evaluate without reminders.

### Decision: Extend custom care rules only for measurement reminders

**Choice:** Add nullable metric linkage and a measurement-required flag to custom care rules. Existing rules have no metric linkage and preserve current behavior. A linked rule must reference an enabled metric owned by the same plant. Reminder due dates use newest measurement time, falling back to rule creation time. Recording from either Metrics page or task flow resets cadence.

**Rationale:** Custom care rules already own per-plant interval scheduling, enabled state, and task generation. Optional linkage reuses that machinery while keeping alert evaluation independent. It also composes with the active care-rule UI change.

**Alternatives considered:**

1. Create a separate metric reminder scheduler → duplicates intervals, filters, completion, and dashboard integration.
2. Encode metric IDs in task-type strings only → fragile identity and poor validation.
3. Require every metric to have a reminder → rejected because users may want passive logging only.

### Decision: Required measurement persistence precedes completion

**Choice:** For a required measurement task, UI collects and validates a value, persists the measurement, then records normal task completion/journal effects and refreshes schedule. If measurement persistence fails, completion does not run. If later completion persistence fails, the saved measurement remains, an error is shown, and reminder cadence still advances from that measurement. Optional tasks retain direct completion and offer value entry as a second path.

**Rationale:** Never claim a required measurement happened before durable data exists. Measurement is the reminder cadence source of truth, so partial failure cannot immediately recreate the due reminder.

**Alternatives considered:**

1. Complete first, then save measurement → risks losing required data while hiding the task.
2. Add a transactional database solely for two writes → disproportionate dependency and migration cost for current local architecture.

### Decision: Use additive SharedPreferences collections

**Choice:** Store definitions and measurements under separate versioned keys using existing corruption-safe collection codec patterns. Add optional care-rule fields with decoding defaults. Build per-plant indexes in memory during a load rather than persist derived indexes or alert state.

**Rationale:** This matches current architecture, requires no package, and is sufficient for expected personal-device history. Separate keys limit rewrite scope between definitions and measurements.

**Alternatives considered:**

1. Add SQLite → better for very large histories but introduces a dependency and migration system before measured need.
2. Embed measurements in plant records → rewrites unrelated inventory data on every sample.
3. One collection per metric → creates unbounded preference keys and complicates cleanup.

### Decision: Render bounded native graphs plus textual history

**Choice:** Use a small `CustomPainter`-based graph fed by immutable display points. Numeric metrics use a line plot with optional bound lines/band. Boolean metrics use two labeled states; categorical metrics use labeled state rows and chronological points/segments. Every graph has a readable history list and semantic labels. Initially render the newest bounded window and allow users to request older history without loading every point into one frame.

**Rationale:** Three simple plots do not justify a chart dependency. Bounded rendering protects frame time and the textual list satisfies accessibility and precise-value inspection.

**Alternatives considered:**

1. Add a chart package → faster advanced interactions but unnecessary for static v1 history and adds maintenance surface.
2. Render only a table → accessible but does not satisfy trend visualization.
3. Force category scores into a numeric line → misleading and contradicts selected categorical behavior.

### Decision: Add Metrics to plant-detail overflow navigation

**Choice:** Add a localized Metrics entry to the plant-detail action submenu/overflow and push a plant-scoped page using existing `Navigator` patterns. Do not add a bottom-navigation destination. Metric summary, definition management, data entry, and history stay within that page flow.

**Rationale:** Plant ownership remains explicit and global navigation stays unchanged. This mirrors existing per-plant journal navigation while meeting submenu requirement.

## Risks / Trade-offs

- **[Risk] SharedPreferences rewrites slow down with very large histories** → Keep measurements in a separate collection, paginate/bound UI reads, and move behind the repository to SQLite only if profiling shows a real ceiling.
- **[Risk] Editing a definition can invalidate old category values** → Preserve historical values for display, prevent removal of options still referenced unless user confirms, and validate only new/edited entries against current options.
- **[Risk] Metric deletion can leave linked rules or completions** → Centralize idempotent cleanup in plant-metrics use cases and invoke it from plant cleanup before deleting the plant.
- **[Risk] Required measurement and completion use separate writes** → Persist measurement first, retain it on later failure, surface classified errors, and derive next reminder from measurement time.
- **[Risk] Active `modify-care-rules` work changes the same form/list** → Keep new entity fields optional and implement metric controls as an additive rule mode after that change is integrated.
- **[Trade-off] Native graphs provide fewer gestures and decorations** → v1 prioritizes readable trends, target markers, semantic labels, and textual history; add a package only when a specified interaction cannot be met natively.

## Migration Plan

1. Add versioned empty definition and measurement collections; absence means no configured metrics.
2. Add nullable metric linkage to custom-rule decoding; existing records decode as ordinary unlinked rules.
3. Register plant-metrics dependencies and cleanup before exposing UI navigation.
4. Enable metric definition/entry UI, then linked reminder and alert-task integrations.
5. On rollback, older builds ignore unused metric collections and extra custom-rule JSON fields; no existing plant or care records require destructive migration.
