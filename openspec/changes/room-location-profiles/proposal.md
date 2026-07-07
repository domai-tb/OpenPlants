## Why

Plants have a `room` field, but it's just a plain string with no context. Users need to define rooms with environmental attributes (light levels, humidity, temperature notes) so plants can inherit context-aware care recommendations. A plant in a bright south-facing window needs different watering guidance than one in a dim bathroom.

## What Changes

- Add a `RoomEntity` data model with name, light level, humidity, and notes
- Create a dedicated rooms management page for creating/editing/deleting rooms
- Update the plant collection form to select from defined rooms (replacing free-text input)
- Enhance care schedule recommendations to factor in room environment
- Add room-based filtering to the plant collection view

## Capabilities

### New Capabilities
- `room-profiles`: Room/location management — CRUD operations for rooms with environmental metadata (light, humidity, notes)
- `room-aware-care`: Care schedule adjustments that factor in room environment when generating recommendations

### Modified Capabilities
- `plant-inventory`: Room field changes from free-text string to reference to RoomEntity; plant collection UI adds room selection and filtering
- `care-schedule-engine`: Accepts room environment context to adjust watering/fertilizing intervals

## Impact

- **Data**: New `rooms` table/collection; `PlantEntity.room` migrates from `String?` to `roomId` (String reference)
- **UI**: New rooms management page; updated plant form with room picker; room filter chips on collection page
- **Logic**: Care schedule engine gains environment-aware heuristics
- **Dependencies**: None new — builds on existing `shared_preferences` persistence
