## Context

OpenPlants uses Clean Architecture with GetIt DI, `shared_preferences` JSON persistence, and a 5-file feature pattern (datasource → repository → usecases → entity → page). The existing `plant-collection` change introduced a plant inventory with basic care status tracking (happy/needs_water/needs_fertilizer + lastWateredAt/lastFertilizedAt timestamps).

The care schedule system introduces an intelligent scheduling engine that builds on this foundation. It replaces the simple tri-state model with a task-driven approach: 8 built-in task types plus custom tasks, each with configurable intervals modulated by room, season, pot type, and completion history.

## Goals / Non-Goals

**Goals:**
- Pure Dart scheduling engine — no cron, no platform channels, no background isolates
- Deterministic schedule computation: given the same inputs, produce the same task feed
- 8 built-in task types: watering, fertilizing, misting, pruning, rotating, repotting, leaf cleaning, pest inspection
- Custom user-defined task types with name and interval
- Per-plant schedule config with species-default intervals and user overrides
- Room attributes (sunlight, humidity, temperature) that modulate watering/misting frequency
- Seasonal adjustments (e.g., reduced watering in winter for dormant species)
- Pot-type modifiers (terracotta = faster drying, plastic = slower, self-watering)
- History-aware: completing a task resets its timer; overdue items escalate
- Follow existing Clean Architecture + GetIt patterns
- New page (page8) — care schedule dashboard

**Non-Goals:**
- Push notifications for due tasks (requires platform channels — future)
- Background sync or cloud backup
- Automatic species recognition (scope of page3 classifier)
- Multi-user or sharing features
- Recurring task patterns beyond fixed-interval + modifiers (e.g., "every other Tuesday" — future)

## Decisions

### Decision 1: Scheduling engine is a pure function — no state machine

The engine is a stateless pure function: `computeSchedule(plant, config, room, season, history, today) → List<CareTask>`. It reads inputs and produces a deterministic output. No mutable state, no side effects. This makes it trivially testable and safe to call on every page load.

- **Alternative considered:** Stateful engine with a background timer — adds complexity and platform-channel dependency for no benefit; the user opens the schedule page to see tasks, so on-demand computation is the right model.
- **Alternative considered:** Pre-compute and persist tasks — creates a stale-data problem when config changes; on-demand computation always returns current data.

### Decision 2: Schedule config merged from species defaults → user overrides

A three-layer config model:
1. **Species defaults:** Hardcoded baseline intervals per species (e.g., succulent → water every 14 days, fern → water every 3 days)
2. **User overrides:** Per-plant overrides stored in the plant's schedule config (null = use species default)
3. **Computed schedule:** Engine merges the two, applies modifiers (room, season, pot), and produces the effective interval

- **Alternative considered:** Single flat config per plant — simpler but forces the user to configure every interval from scratch.
- **Alternative considered:** Only species defaults — no flexibility for individual plant needs.

### Decision 3: Room attributes stored as a separate entity

Rooms are free-form strings on plants (from plant-collection), but the schedule engine needs room-level attributes (sunlight, humidity, temperature) to modulate schedules. A separate `RoomConfig` entity is stored keyed by room name, created the first time a user references a room.

- **Alternative considered:** Room attributes on each plant — wasteful duplication when multiple plants share a room.
- **Alternative considered:** Fixed room presets — too restrictive; users have unique spaces.

### Decision 4: Seasonal adjustments via monthly modifier table

Each task type has a 12-entry table of monthly multipliers (1.0 = baseline). For example, watering for a tropical plant in winter: monthlyMultiplier[12] = 0.5 (half frequency). The engine multiplies the base interval by the current month's factor.

- No alternative considered — this is the simplest correct design for annual cycles.

### Decision 5: Task history stored as a flat event log

Each task completion is an event: `{taskType, plantId, completedAt, notes?}`. The engine sorts by plantId + taskType, finds the most recent completion, and uses it as the "last done" anchor for computing next-due dates.

- **Alternative considered:** Running "next due" timestamp on the plant — fragile when config changes (changing the interval invalidates the old timestamp).
- **Alternative considered:** Only the latest completion per task type — sufficient for the current model; unnecessary to keep full history beyond the latest for scheduling purposes (but we keep full history for the UI log).

### Decision 6: Overdue tasks are identified by the engine, not stored

A task is "overdue" when `now - lastCompleted > effectiveInterval × 1.2`. The engine flags this at computation time. This keeps the data model clean — no boolean flags to go stale.

### Decision 7: Page8 follows the same 5-file pattern

New page at `lib/pages/page8/` with the standard structure: datasource, repository, usecases, entity, page_widget. The same DI registration pattern applies.

## Risks / Trade-offs

- **Risk: Schedule engine complexity from multiple modulating factors** → The pure-function design keeps the logic encapsulated and testable. Each modifier (room, season, pot) is a separate, independently-testable function.
- **Risk: Species-defaults data entry burden** → Initially hardcoded for common houseplants with a fallback "general" profile. A future update can load from an external dataset or allow community contributions.
- **Risk: Room attributes may be too many knobs for users** → Room attributes are optional — the engine uses a neutral baseline (1.0x) for all factors if room config is missing. Users only tune if they want more accurate scheduling.
- **Trade-off: No background notifications** → The user must open the app to see the schedule. Acceptable for v1; push notifications can be added as a separate change.
- **Trade-off: On-demand computation means no widget/badge counts** → The app cannot show a "3 tasks due" badge on the icon without a background mechanism. Acceptable for v1.
