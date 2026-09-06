## Why

OpenPlants records care events, symptoms, and journal notes, but cannot capture precise per-plant measurements or show how they change over time. Users need configurable local tracking for values such as water level and nutrient concentration, plus reminders and optional responses when measurements indicate a problem.

## What Changes

- Add per-plant metric definitions with required name and unit, a numeric, boolean, or categorical value type, and optional notes and entry instructions.
- Allow optional numeric minimum/maximum targets and user-selected alert values for boolean or categorical metrics.
- Record timestamped measurements and let users correct or delete their own entries.
- Add a per-plant Metrics page, reached from a submenu on plant detail, with metric summaries, history, data-entry controls, and time-series visualization.
- Extend custom care rules so a rule can schedule measurement reminders for one metric and optionally require a saved value before task completion.
- Let each metric choose warning-only or care-task behavior when a value is outside its configured target or matches an alert value; metrics without alert criteria only produce measurement reminders.
- Keep definitions, measurements, and generated state local; remove them during plant deletion.
- Add localized UI copy and behavior-focused unit/widget tests.

## Capabilities

### New Capabilities

- `plant-metrics`: Define per-plant metrics, record typed measurements, evaluate optional alert criteria, and visualize measurement history.

### Modified Capabilities

- `custom-care-rules`: Allow a custom rule to reference a plant metric and configure whether completing its measurement task requires a newly saved value.
- `care-schedule-engine`: Schedule linked measurement tasks and surface deduplicated care tasks created by metric alert evaluation.
- `care-tasks-ui`: Collect a linked metric value during measurement-task completion when required and navigate users to metric entry when appropriate.
- `plant-inventory`: Expose Metrics through the plant-detail submenu and include metric-owned data in plant deletion cleanup.

## Impact

- New Clean Architecture feature module under `lib/pages/plant_metrics/` for entities, persistence, rules, use cases, and UI.
- Extensions to care-rule, schedule, task-completion, plant-detail navigation, plant cleanup, dependency injection, and `AppServices` wiring.
- New SharedPreferences-backed collections with corruption-safe decoding and schema migration consistent with existing local storage.
- New localization keys and generated localization output.
- No cloud service or account data; measurements stay on device.
- No chart dependency is required by the specification; implementation may use Flutter drawing primitives for the bounded v1 graph.
