## Context

OpenPlants is a Flutter plant companion app using Clean Architecture (Page → UseCase → Repository → DataSource). Each feature follows a 5-file pattern: datasource, repository, usecases, entity, page.

The app currently tracks plant care schedules based on species defaults, room context, pot type, and seasonal modifiers. However, it has no mechanism to record or use light conditions — one of the most critical factors affecting plant health and watering needs.

Users need a way to log light levels for their plants, and the care schedule engine should eventually use this data to refine task intervals.

## Goals / Non-Goals

**Goals:**
- Let users manually select a light level (low, medium, bright indirect, direct) for any plant
- Persist light level as part of the plant's data profile
- Optionally provide a camera-based light estimation hint (guidance only, not precise)
- Integrate light level as an input to the care schedule engine for watering adjustments

**Non-Goals:**
- Precise lux measurement (the app is not a scientific instrument)
- Automatic continuous light monitoring in the background
- Real-time light alerts or notifications
- Light tracking history over time (single current-value model for now)

## Decisions

### 1. Light level as a plant-level attribute

**Decision**: Store `lightLevel` as an optional enum field on the plant entity, not as a separate time-series measurement.

**Rationale**: The current data model stores a single snapshot of plant state (pot type, room assignment). Light level fits this same pattern — users set it when they assess the plant's location. History can be added later without breaking the schema.

**Alternatives considered**:
- Time-series light log → rejected: adds complexity without clear MVP value; the care engine only needs the current level.

### 2. Four fixed light levels

**Decision**: Use an enum with four values: `low`, `medium`, `brightIndirect`, `direct`.

**Rationale**: Matches common horticultural terminology. More granular scales (1-10, lux ranges) add cognitive load without proportional benefit. Users can understand and map their plant's location to one of these categories.

**Alternatives considered**:
- Numeric scale (1-10) → rejected: harder for users to map to real-world conditions
- Continuous lux range → rejected: not a scientific tool; imprecise sensor data creates false confidence

### 3. Camera-based estimation as optional guidance

**Decision**: Provide a camera-based light estimation that reads ambient brightness from the viewfinder and maps it to the four-level scale. Display as a suggestion, not an auto-applied value.

**Rationale**: Gives users a starting point when they're unsure. Keeping it as a suggestion preserves user agency and avoids false precision.

**Alternatives considered**:
- Ambient light sensor (lux) → rejected: not available on all Android devices; camera is more universal
- Auto-detect from photo → rejected: still requires manual confirmation; adds ML complexity for minimal gain

### 4. Modifiers use light level directly

**Decision**: The care schedule engine applies a light-level multiplier to watering and misting intervals using the same pattern as room-context modifiers.

**Rationale**: Reuses existing modifier infrastructure. The engine already handles room sunlight as a modifier; light level on the plant is a more precise, user-confirmed version of the same signal.

**Alternatives considered**:
- Replace room sunlight with plant light level → rejected: room sunlight remains useful as a fallback when no plant-level assessment exists

## Risks / Trade-offs

- **Camera estimation may be inaccurate in unusual lighting** → Mitigation: Display as suggestion only; user always confirms. Label it as "estimated" in the UI.
- **Users may never set light level** → Mitigation: Care engine treats missing light level as neutral (1.0× modifier), same as missing room config. No degradation.
- **Adding field to plant entity requires migration** → Mitigation: Field is nullable; existing plants default to null (no modifier applied). No data migration needed.
- **Four levels may feel too coarse for advanced users** → Acceptable for MVP. Can add sub-levels or descriptive presets later.

## Open Questions

- Should light estimation use the device's ambient light sensor where available, or stick to camera for consistency?
- Should the light level selector appear inline on the plant detail page, or as a separate modal/page?
