## 1. Data Models & Entities

- [x] 1.1 Create `CareTaskType` sealed class with 8 built-in types (watering, fertilizing, misting, pruning, rotating, repotting, leaf cleaning, pest inspection) plus custom type factory
- [x] 1.2 Create `ScheduleConfig` entity — per-task-type interval overrides (Map<String, int?>), pot type enum (terracotta/plastic/self-watering), species profile ID
- [x] 1.3 Create `RoomConfig` entity — room name, sunlight level enum, humidity level enum, temperature label
- [x] 1.4 Create `TaskCompletion` entity — task type, plant UUID, completedAt timestamp, optional note
- [x] 1.5 Create `CareTask` entity — task type, plant name + UUID, due date, status enum (overdue/due-today/upcoming), effective interval
- [x] 1.6 Create `SpeciesCareProfile` model — default intervals for all 8 task types, monthly modifier tables per task type

## 2. Scheduling Engine (Pure Dart)

- [x] 2.1 Implement `EffectiveIntervalCalculator` — merges species default → user override, applies seasonal monthly multiplier
- [x] 2.2 Implement `RoomModifier` — applies sunlight/humidity/temperature multipliers to watering and misting intervals
- [x] 2.3 Implement `PotTypeModifier` — returns interval multiplier per pot type (terracotta 0.8x, plastic 1.0x, self-watering 1.5x)
- [x] 2.4 Implement `OverdueDetector` — flags tasks where elapsed time > 1.2× effective interval
- [x] 2.5 Implement `ScheduleEngine` — pure function combining all modifiers, sorting by urgency, producing the task feed
- [x] 2.6 Add unit tests for engine with various input combinations (season, room, pot, history)

## 3. Persistence Layer

- [x] 3.1 Create `care_schedule_datasource.dart` — SharedPreferences JSON read/write for schedule config, room configs, and task completion log
- [x] 3.2 Create `care_schedule_repository.dart` — wraps datasource, provides typed getters/setters for config and history
- [x] 3.3 Implement migration handling — default values for new keys on first access

## 4. Use Cases

- [x] 4.1 Implement `GetScheduleUseCase` — calls engine for each plant, merges results into sorted unified feed
- [x] 4.2 Implement `CompleteTaskUseCase` — records completion event, returns updated schedule
- [x] 4.3 Implement `SnoozeTaskUseCase` — defers task by chosen duration
- [x] 4.4 Implement `SkipTaskUseCase` — resets anchor to today without recording completion
- [x] 4.5 Implement `UpdateScheduleConfigUseCase` — saves per-plant config overrides
- [x] 4.6 Implement `UpdateRoomConfigUseCase` — saves/updates room attributes
- [x] 4.7 Implement `GetTaskHistoryUseCase` — retrieves completion log filtered by plant/task type

## 5. Care Schedule UI

- [x] 5.1 Create `care_schedule_page.dart` — StatefulWidget with three-section layout (Overdue / Due Today / Upcoming)
- [x] 5.2 Build task card widget — icon + label, plant name, due-status badge, "Mark done" / Snooze / Skip actions
- [x] 5.3 Build plant filter dropdown — populates from collection, "All plants" default
- [x] 5.4 Build task-type filter chips — 8 built-in types + "All" default
- [x] 5.5 Build empty state widget — "Add plants to see care tasks" with navigation to collection page
- [x] 5.6 Add task history section on plant detail page (from plant-collection plant_collection)

## 6. Species Care Profiles

- [x] 6.1 Define hardcoded species-default intervals for common houseplants (pothos, snake plant, monstera, succulent, fern, etc.)
- [x] 6.2 Implement "general" fallback profile with conservative defaults
- [x] 6.3 Implement monthly seasonal modifier tables for common species profiles

## 7. Integration & DI

- [x] 7.1 Register care_schedule datasource, repository, and all use-cases in `lib/core/injection.dart`
- [x] 7.2 Add `care_schedule` use-cases field to `AppServices` in `lib/core/app_services.dart`
- [x] 7.3 Add `care_schedule` case to navigation in `lib/pages/home/home_page.dart`
- [x] 7.4 Add care-schedule-related strings to l10n ARB files
- [x] 7.5 Run `fvm flutter analyze` and fix any lint violations
- [x] 7.6 Run `fvm flutter test` and verify all tests pass
