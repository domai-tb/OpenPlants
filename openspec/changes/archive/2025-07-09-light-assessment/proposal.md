## Why

Plants need specific light conditions to thrive, but users currently have no way to record or track the light levels their plants receive. Without this data, care recommendations (watering frequency, placement advice) can't account for one of the most critical environmental factors. Adding light assessment closes this gap and gives users actionable insight into whether their plant's location meets its needs.

## What Changes

- Users can manually tag a plant's light level: low, medium, bright indirect, or direct.
- The light assessment is stored as part of the plant's environmental profile.
- Optionally, the app can estimate light level using the device camera or ambient light sensor as a **guidance hint** (not a precise measurement).
- Light level data can later inform care schedule adjustments (e.g., plants in lower light need less frequent watering).

## Capabilities

### New Capabilities

- `light-assessment`: Manually record and optionally estimate light conditions for a plant. Covers the UI selector, optional camera/sensor estimation, and persistence of light level data.

### Modified Capabilities

- `care-schedule-engine`: Light level data becomes an input factor for watering and care frequency adjustments.

## Impact

- **Code**: New feature module under `lib/pages/lightAssessment/` following the 5-file pattern. Minor changes to `care-schedule-engine` to consume light level data.
- **Dependencies**: Potential use of `camera` plugin for light estimation (optional). No new mandatory dependencies.
- **Data model**: `PlantEntity` (or equivalent) gains a `lightLevel` field.
- **UI**: New page accessible from plant detail view; light level displayed alongside other plant info.
