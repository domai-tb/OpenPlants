## Context

OpenPlant is a Flutter plant companion app with Clean Architecture (Page → UseCase → Repository → DataSource). Plants are stored locally using `shared_preferences` with JSON serialization. Each plant currently has a single optional photo for identification. Users have no way to track visual changes over time.

The app is Android-only (minSdk 26, no Play Services), uses GetIt for DI via `AppScope`, and follows a strict 5-file feature module pattern: `pageN_datasource.dart`, `pageN_repository.dart`, `pageN_usecases.dart`, `pageN_item_entity.dart`, `pageN_page.dart`.

## Goals / Non-Goals

**Goals:**
- Allow users to store multiple dated photos per plant
- Display photos in reverse-chronological order with date labels
- Provide full-screen photo viewing with swipe navigation
- Keep all data local (no cloud sync)
- Follow existing architecture patterns (5-file module, GetIt DI, AppScope)

**Non-Goals:**
- Cloud backup or sync of photos
- Photo editing or filtering
- Automatic photo reminders or scheduling
- Photo comparison side-by-side view (future enhancement)
- AI-based growth analysis from photos

## Decisions

### 1. Photo storage: app documents directory with metadata in JSON

**Decision**: Store photo files in `getApplicationDocumentsDirectory()` under a `plant_photos/{plantId}/` subdirectory. Store photo metadata (date, file path, caption) as a JSON list within the plant entity.

**Rationale**: 
- Documents directory survives app updates and is backed up by the system
- JSON metadata avoids adding a database dependency
- Per-plant subdirectory simplifies cleanup on plant deletion
- Consistent with existing `shared_preferences` + JSON approach

**Alternative considered**: SQLite via `sqflite` — rejected for simplicity since photo count per plant is expected to be small (<100).

### 2. Entity changes: add `photos` field to plant entity

**Decision**: Add a `List<PlantPhoto>` field to the existing plant entity, where `PlantPhoto` is a new value object with `id`, `date`, `filePath`, and optional `caption`.

**Rationale**:
- Keeps photo data co-located with the plant
- Serializes cleanly to JSON (existing pattern)
- No migration needed — new field defaults to empty list

**Alternative considered**: Separate photo collection keyed by plant ID — rejected as it fragments the data model without clear benefit at this scale.

### 3. Feature module: `plantPhotoTimeline` following 5-file pattern

**Decision**: Create `lib/pages/plantPhotoTimeline/` with datasource, repository, usecases, entity, and page files.

**Rationale**: Matches existing architecture. Use-cases handle photo addition, deletion, and retrieval. Datasource handles file I/O and metadata persistence.

### 4. UI: photo timeline section in plant detail + dedicated timeline page

**Decision**: Add a horizontal scrollable thumbnail strip in the plant detail page. Tapping it opens a dedicated full-screen timeline view with vertical scroll and swipe navigation.

**Rationale**:
- Horizontal strip gives quick access without leaving context
- Dedicated page provides immersive viewing experience
- Vertical scroll matches chronological reading pattern

## Risks / Trade-offs

- **[Risk]** Large photo files consume storage → **Mitigation**: Compress images to reasonable quality (80% JPEG) before saving. Show storage usage in settings (future).
- **[Risk]** Entity serialization grows with many photos → **Mitigation**: Photos stored as file references (paths), not embedded data. Metadata is lightweight.
- **[Risk]** No cloud backup means data loss on uninstall → **Mitigation**: Accepted for this phase. Cloud sync is a future capability.
- **[Trade-off]** JSON metadata vs SQLite → Gains simplicity, loses query flexibility for large photo sets. Acceptable given expected scale.
