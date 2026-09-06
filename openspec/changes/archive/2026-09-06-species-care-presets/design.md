## Context

The app has a species library (`SpeciesEntity`) with structured care characteristics: `WaterNeeds` (low/moderate/frequent), `LightNeeds` (low/medium/bright/direct), `HumidityPreference` (low/moderate/high), `repottingIntervalMonths`, and `soilType`. These drive text-only care plan guidance via `generateCarePlan()`.

Separately, the care schedule engine computes actionable task schedules from `CustomCareRuleEntity` records per plant. Currently, new plants start with zero custom rules — users must manually create every care rule.

The goal: when a plant is created with a known species, auto-populate care rules derived from species characteristics.

## Goals / Non-Goals

**Goals:**
- Map species characteristics to concrete interval values for all 8 built-in task types
- Auto-apply presets on plant creation when species is known
- Let users override/disable/delete any preset rule (presets are starting points, not constraints)
- Keep preset logic pure and testable (no side effects in the mapping function)

**Non-Goals:**
- Changing the care schedule engine itself (presets produce standard `CustomCareRuleEntity` records)
- Modifying existing plants' rules (presets only apply on creation)
- Supporting user-defined task type presets (only the 8 built-in types)
- UI for editing preset values before applying (apply defaults, let users tweak after)

## Decisions

### D1: Preset mapping as a pure function

**Decision**: Create a `speciesCarePresets(SpeciesEntity) → List<CustomCareRuleEntity>` function that returns a list of 8 care rule templates (one per built-in task type).

**Rationale**: Pure function is trivially testable, has no DI dependencies, and follows the project's functional style. The mapping is deterministic: same species → same presets.

**Alternatives considered**:
- JSON config file: Adds parsing complexity for no benefit — the mapping logic involves conditional intervals based on enum values, which is cleaner in Dart.
- Database-stored presets: Over-engineered for a static mapping. Species data doesn't change at runtime.

### D2: Interval values derived from enum combinations

**Decision**: Use a lookup table that maps `(WaterNeeds, LightNeeds, HumidityPreference)` tuples to base intervals. Example:

| Task Type | Logic |
|-----------|-------|
| watering | `WaterNeeds.frequent → 5d`, `.moderate → 7d`, `.low → 10d` |
| fertilizing | `WaterNeeds.frequent → 14d`, `.moderate → 21d`, `.low → 30d` |
| misting | `HumidityPreference.high → 3d`, `.moderate → 5d`, `.low → 0` (skip) |
| pruning | Fixed 30d (most species) |
| rotating | Fixed 14d |
| repotting | From `species.repottingIntervalMonths × 30` |
| leaf cleaning | Fixed 14d |
| pest inspection | Fixed 21d |

**Rationale**: Simple conditional logic, easy to tune per-species later. The 8 task types are already defined by the engine.

### D3: Presets applied in PlantCollectionRepository.addPlant

**Decision**: After creating the `PlantEntity`, call the preset function and persist the generated rules via `CustomCareRuleRepository.createCustomCareRule()`.

**Rationale**: Repository layer is where plant creation happens. Adding a species lookup + preset generation here keeps the form page unchanged and follows the existing DI pattern. The `speciesName` on `PlantEntity` is the lookup key — if it matches a known species, apply presets.

**Alternatives considered**:
- Form page: Couples UI to business logic. The form already delegates to usecases.
- Use-case layer: Would require threading species lookup through, adding complexity. Repository already has access to the data layer.

### D4: No UI changes needed

**Decision**: Presets are applied silently on creation. Users see the care rules appear in the care schedule for their new plant.

**Rationale**: The care rules section already displays and allows editing/disabling rules. No new UI is needed — the rules just exist from the start.

## Risks / Trade-offs

- **Risk**: Preset intervals may not match every species perfectly → **Mitigation**: Users can override any rule. Presets are defaults, not constraints. We can tune intervals based on feedback.
- **Risk**: Species lookup by `scientificName` may fail for user-entered free-text species → **Mitigation**: Only apply presets when species name matches a known species in the library. Free-text entries get no presets (existing behavior).
- **Trade-off**: 8 rules created at once may feel like clutter → **Mitigation**: Users can disable rules they don't need. The care schedule already groups and prioritizes tasks.
