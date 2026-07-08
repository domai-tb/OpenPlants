## Context

The OpenPlant app currently stores a `room` field on `PlantEntity` as a free-text string. This provides no environmental context for care recommendations. Users manually enter room names like "kitchen" or "balcony" with no associated metadata. The care schedule engine treats all plants identically regardless of location.

The app follows Clean Architecture: Page → UseCase → Repository → DataSource, with GetIt for DI and `shared_preferences` for persistence. Each feature module lives in `lib/pages/<feature>/` with a 5-file pattern.

## Goals / Non-Goals

**Goals:**
- Define rooms as first-class entities with environmental attributes (light, humidity, notes)
- Allow users to create, edit, and delete rooms via a dedicated management page
- Replace free-text room input in plant form with a room picker that references RoomEntity
- Filter plant collection by room
- Adjust care schedule recommendations based on room environment (e.g., high-light rooms = more frequent watering)

**Non-Goals:**
- GPS/location-based room detection
- IoT sensor integration for real-time environment monitoring
- Multi-home or multi-property support
- Shared room libraries between users
- Automatic room creation from photos

## Decisions

### 1. Room persistence: shared_preferences with JSON serialization

**Decision**: Store rooms as a JSON list in `shared_preferences`, same pattern as `SettingsController`.

**Rationale**: The app is Android-only with no backend. Adding SQLite (sqflite/hive) would increase complexity for a small dataset (typical user has 3-8 rooms). JSON serialization works well for small lists and matches the existing `SettingsController` pattern.

**Alternatives considered**:
- SQLite (sqflite): Overkill for <20 items; adds dependency and migration complexity
- Hive: NoSQL but still adds a dependency; same benefit as JSON for this scale

### 2. Room entity design: enum-based light/humidity levels

**Decision**: Use enums for `LightLevel` (low, medium, bright, directSun) and `HumidityLevel` (low, medium, high) rather than free-text or numeric values.

**Rationale**: Enums provide type safety, prevent invalid combinations, and make care logic simpler (if-else on enum values vs. parsing free-text). Users select from presets rather than entering arbitrary values.

**Alternatives considered**:
- Numeric sliders (0-100): Too precise for care heuristics; users can't meaningfully distinguish 65% from 70% humidity
- Free-text: No validation, impossible to build reliable care logic

### 3. Room-pick in plant form: dropdown with "Create new" option

**Decision**: Plant form shows a dropdown of existing rooms with a trailing "+ New Room" action that navigates to room creation.

**Rationale**: Keeps the workflow in-context. Users don't need to leave the plant form to create a room. After creation, the dropdown pre-selects the new room.

**Alternatives considered**:
- Separate room management only: Forces users to navigate away, breaking flow
- Inline room creation in dropdown: Complex widget; better to use existing page pattern

### 4. Care adjustment: multiplier-based heuristics

**Decision**: Room environment applies multipliers to base care intervals. Example: `directSun` light → 0.7x watering interval (more frequent), `low` humidity → 0.8x interval.

**Rationale**: Simple, predictable, and debuggable. Multipliers are applied on top of species-specific base intervals from the care-schedule-engine.

**Alternatives considered**:
- ML-based prediction: Requires training data we don't have; over-engineered
- Hard-coded per-species-per-room matrix: Doesn't scale

### 5. Migration: gradual, backward-compatible

**Decision**: `PlantEntity.room` remains a `String?` during transition. New `roomId` field added alongside. Old string rooms display as "Unassigned" in the room picker. No forced migration.

**Rationale**: Zero breakage. Users can migrate at their own pace. Old data remains accessible.

## Risks / Trade-offs

- **[Risk] Room list growth**: Power users might create many rooms → Mitigation: Cap at 20 rooms with a warning; unlikely given typical home size
- **[Risk] Stale room references**: Deleting a room leaves orphaned `roomId` values → Mitigation: On room deletion, clear `roomId` on affected plants; show confirmation dialog with count of affected plants
- **[Trade-off] Enum rigidity**: Cannot add custom light/humidity levels → Acceptable: The 4 light and 3 humidity levels cover common residential scenarios; extending enums is a minor code change later
- **[Trade-off] No sync**: Rooms are local-only, no cloud backup → Consistent with app's offline-first architecture; data persists in shared_preferences
