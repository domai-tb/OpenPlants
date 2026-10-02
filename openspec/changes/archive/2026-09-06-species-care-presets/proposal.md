## Why

When a user adds a new plant with a known species, they must manually create every care rule from scratch — watering interval, fertilizing schedule, misting, pruning, etc. This is tedious and error-prone, especially for beginners who don't know species-specific intervals. The species library already stores rich care characteristics (`waterNeeds`, `lightNeeds`, `humidityPreference`, `repottingIntervalMonths`) but this data is only used for care plan text guidance, not for pre-populating actionable care rules. Bridging this gap lets users start with sensible defaults and customize from there.

## What Changes

- **New capability**: Species care presets — a mapping layer that translates species characteristics into default care rule templates (task type + interval + reminder config) for each of the 8 built-in task types.
- **Modified capability**: `custom-care-rules` — plants created with a known species now auto-populate with species-derived default care rules instead of starting empty. Users can still override, disable, or delete any preset rule.

## Capabilities

### New Capabilities
- `species-care-presets`: Defines preset care rule templates derived from species characteristics, mapping `WaterNeeds`/`LightNeeds`/`HumidityPreference`/`repottingIntervalMonths` to concrete interval values for each built-in task type.

### Modified Capabilities
- `custom-care-rules`: Plant creation with a known species triggers auto-population of default care rules from species presets. Plants without a known species start with an empty rule list (existing behavior).

## Impact

- **Code**: `lib/pages/care_schedule/` (new preset mapping + use-case for applying presets), `lib/pages/plant_identification/` or plant creation flow (trigger preset application on species selection).
- **Data**: New care rules created automatically on plant creation — no schema change, reuses existing `CustomCareRuleEntity`.
- **No breaking changes**: Existing plants with manual rules are unaffected. Presets are only applied on creation.
