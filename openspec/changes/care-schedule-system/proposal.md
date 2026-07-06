## Why

OpenPlants currently tracks basic care status (happy / needs_water / needs_fertilizer) with optional last-watered and last-fertilized timestamps, but has no scheduling engine to tell users *when* to water, fertilize, mist, prune, or repot each plant. Without proactive task generation, users must remember care schedules themselves — defeating the app's role as an active plant-care companion. A rule-driven schedule engine that factors in species defaults, room conditions, season, pot type, and task history transforms the app from a passive log into a proactive caretaker.

## What Changes

- **Schedule engine core:** A computation engine that generates a list of due or upcoming care tasks for each plant, considering species defaults, user overrides, room microclimate, current season, pot type, and past completion patterns
- **Task types expanded:** Replace the simple tri-state with 8 built-in task types (watering, fertilizing, misting, pruning, rotating, repotting, leaf cleaning, pest inspection) plus custom user-defined task types
- **Per-plant schedule configuration:** Each plant gains a schedule profile with configurable intervals per task type, adjustable from species defaults
- **Room context influence:** Room attributes (sunlight level, humidity, temperature) modulate the base schedule — e.g., a plant in a south-facing dry room may need more frequent watering
- **Seasonal adjustments:** Schedule intervals shift based on the current season (e.g., reduced watering in winter dormancy)
- **Pot-type modifiers:** Terracotta, plastic, and self-watering pots affect watering frequency
- **History-aware rescheduling:** Completing a task resets its timer; overdue tasks are escalated
- **New page (page8):** Care schedule view showing today's tasks, upcoming tasks, and overdue items — filterable by plant, task type, and priority

## Capabilities

### New Capabilities

- `care-schedule-engine`: Core scheduling engine — computes due dates and generates task lists per plant based on species defaults, user overrides, room context, season, pot type, and completion history. Produces a deterministic task feed consumable by the UI.
- `care-tasks-ui`: Care schedule page (page8) — displays today's tasks, upcoming tasks, and overdue items with filtering by plant, task type, and status. Supports completing, snoozing, and skipping tasks.
- `schedule-config`: Per-plant and global schedule configuration — species-default intervals, per-plant overrides, season profiles, pot-type modifiers, and room attributes. Stored alongside plant data.
- `care-task-history`: Task completion log — records when each task was completed, by whom, and any notes. Used by the engine to recalculate next-due dates.

### Modified Capabilities

- `care-tracking` (from plant-collection change): The existing simple tri-state care status (`happy`, `needs_water`, `needs_fertilizer`) will be enriched by the schedule engine. The legacy status field is superseded by the new task-based system but kept as a backward-compatible summary derived from the task state.

## Impact

- **New files:** `lib/pages/page8/` directory with the 5-file pattern (datasource, repository, usecases, entity, page)
- **Modified files:**
  - `lib/core/app_services.dart` — add `page8` use-cases field
  - `lib/core/injection.dart` — register page8 datasource, repository, usecases
  - `lib/pages/home/home_page.dart` — add page8 navigator entry
  - `lib/core/app_scope.dart` — add page8 services
  - `lib/l10n/` — add schedule-related strings
- **No new external dependencies required:** The scheduling engine is pure Dart logic (no cron, no background worker); `shared_preferences` already handles persistence
- **Existing `care-tracking` spec affected:** The tri-state model is enriched/partially superseded by the schedule engine — no breaking removal, but the schedule becomes the source of truth for care recommendations
