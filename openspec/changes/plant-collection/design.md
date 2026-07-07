## Context

OpenPlants uses Clean Architecture with a 5-file feature pattern (datasource → repository → usecases → entity → page) and GetIt DI. The app is Android-only, offline-first, with no remote backend. Settings persist via `shared_preferences` JSON serialization. Six placeholder pages (page1–page6) exist; the plant collection will be the plant inventory.

The plant collection is the central feature that unifies the app — users identify species via the classifier (plant_identification) and manage their plants here (plant_collection). Every other feature (care reminders, notes, stats) builds on top of this inventory.

## Goals / Non-Goals

**Goals:**
- Fully offline plant inventory with CRUD operations
- Photo capture/import stored to local filesystem
- Species linking (optional) from classifier results
- Room tagging with free-form room names
- Care status tracking (needs_water, needs_fertilizer, happy)
- Follow existing Clean Architecture + GetIt patterns
- Navigation as a new bottom-nav tab (PageItem.plantCollection)

**Non-Goals:**
- Cloud sync or backup (future consideration)
- Push notifications for care reminders (requires platform channels)
- Automatic species recognition from collection photos (scope of plant_identification classifier)
- Multi-user or sharing features
- Barcode/PLU scanning
- Import/export of collection data
- iCloud backup on iOS (iOS builds exist but are untested)

## Decisions

### Decision 1: JSON-over-SharedPreferences for persistence (matching existing pattern)
The existing `SettingsController` pattern (JSON-serialized → `shared_preferences`) already works and is proven. A dedicated database (Drift/Hive/Isar) would add a dependency and migration complexity for what is fundamentally a personal collection of modest size (< 500 plants expected). The plant data JSON will be stored under a dedicated `prefs` key separate from settings.

- **Alternative considered:** Drift (SQLite) — overkill for the data volume; adds migration tooling and codegen.
- **Alternative considered:** Hive — lightweight but unmaintained (last release 2022); community has moved to Isar.
- **Alternative considered:** Isar — excellent but introduces a new dependency; not worth it until sync or complex queries are needed.

### Decision 2: Photos stored as file paths, not base64
Each plant photo will be copied to the app's documents directory (`path_provider`). The entity stores the file path string. `Image.file()` loads it naturally. This avoids bloating the JSON blob with base64 data and keeps `shared_preferences` fast.

- **Alternative considered:** Base64 inline in JSON — simple but bloats prefs storage; photos > 1 MB would degrade load time.
- **path_provider note:** Not currently a dependency; will be added to pubspec.yaml.

### Decision 3: Free-form room names (not enum)
Rooms are free-form strings rather than a fixed enum so users aren't constrained to a preset list. A future enhancement could suggest previously used room names.

### Decision 4: Care status as simple enum with optional timestamps
Care status is a tri-state: `happy`, `needs_water`, `needs_fertilizer`. Optional `lastWateredAt` and `lastFertilizedAt` timestamps enable future reminder logic. No cron/scheduling engine — just data the UI can surface.

### Decision 5: Plant entity uses UUID strings for IDs
`uuid` package generates unique IDs on creation. This avoids auto-increment issues with local storage and prepares for potential future sync. The entity uses `String id` consistency with existing patterns.

- **uuid note:** Not currently a dependency; will be added to pubspec.yaml.

## Risks / Trade-offs

- **Risk: SharedPreferences size limits** → Plant collection with many photos could exceed practical prefs size. **Mitigation:** Only metadata (name, species, room, timestamps) goes in the JSON; photos are file paths on disk. Even 500 plants with modest note sizes would stay under 1 MB of JSON.
- **Risk: Photo cleanup on delete** → Deleting a plant leaves orphaned photo files. **Mitigation:** The delete use-case removes the photo file from the filesystem before removing the entity from storage.
- **Risk: No sync means data loss on app uninstall** → `shared_preferences` and app documents directory are both cleared on uninstall. **Mitigation:** Accept as a trade-off for simplicity. Document in user-facing help. A future cloud backup feature can address this.
- **Trade-off: No full-text search** → Filtering is limited to in-memory name/species substring matching. Acceptable for expected collection sizes (< 500).
