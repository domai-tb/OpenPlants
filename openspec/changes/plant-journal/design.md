## Context

OpenPlant is a Flutter plant companion app using Clean Architecture (Page → UseCase → Repository → DataSource). The app currently supports plant identification, care scheduling, and task tracking, but lacks a way to record qualitative observations about plant health over time.

Users need a journaling feature to:
- Log what they did (watering, repotting, fertilizing)
- Record what they observe (growth, pests, yellowing leaves)
- Track outcomes (did the treatment work? how fast is it growing?)
- Attach photos for visual comparison

The journal feature fits naturally alongside existing care-tracking capabilities but operates on a different data model (timestamped freeform entries vs. scheduled recurring tasks).

## Goals / Non-Goals

**Goals:**
- Enable users to create timestamped journal entries per plant
- Support multiple entry types (text, photo, task completion, growth update, repotting, pest observation, diagnosis)
- Display entries in a chronological timeline view
- Keep all data local (no cloud sync)
- Follow the existing 5-file module pattern
- Integrate with plant inventory (entries reference plant ID)

**Non-Goals:**
- Cloud sync or backup (future consideration)
- Photo comparison tools (side-by-side views)
- AI-powered journal analysis or insights
- Export/import journal data
- Multi-user or shared journals
- Push notifications for journal reminders

## Decisions

### 1. Data Model: Single `JournalEntry` Entity with Type Discriminator

**Choice**: One entity class with a `type` field (enum) and optional fields per type.

**Rationale**: Simpler schema, easier to query and display in a single timeline. Each entry has a common base (id, plantId, timestamp, notes) plus type-specific fields (photoPath for photos, pestType for observations, etc.).

**Alternatives considered**:
- Separate entity per type → rejected: Creates N tables/classes, complicates timeline rendering
- Discriminated union with sealed classes → possible but adds complexity without clear benefit for local-only storage

### 2. Storage: SQLite via sqflite

**Choice**: Use sqflite for local persistence.

**Rationale**: Already common in Flutter ecosystem, supports structured queries (filter by type, date range), handles photo path references well. The app already has offline-storage as an existing capability.

**Alternatives considered**:
- Hive/Isar → possible but sqflite is more mature for relational queries
- JSON file storage → rejected: poor query performance, no indexing
- shared_preferences → rejected: not designed for structured lists

### 3. Photo Handling: File-based Storage with image_picker

**Choice**: Store photos in app documents directory, save file path in database.

**Rationale**: Photos are referenced by path, not embedded in DB. Keeps DB small and fast. image_picker is the standard Flutter approach for camera/gallery access.

**Alternatives considered**:
- Base64 in DB → rejected: bloats DB, slow reads
- Cloud storage → rejected: out of scope, adds complexity

### 4. UI Pattern: ListView with Type-Specific Cards

**Choice**: Single timeline view using ListView.builder, each entry rendered as a card tailored to its type.

**Rationale**: Simple, performant for typical journal sizes (dozens to hundreds of entries). Type-specific cards let us highlight relevant info (photo thumbnail for photo entries, checkbox for task entries, etc.).

**Alternatives considered**:
- Calendar view → possible future enhancement, but timeline is simpler for v1
- Sectioned by month → adds complexity without clear user benefit initially

### 5. Integration Point: Plant Detail Page

**Choice**: Add journal access from the existing plant detail page (new tab or button).

**Rationale**: Journal is per-plant, so the plant detail page is the natural entry point. Avoids cluttering the main navigation.

**Alternatives considered**:
- Standalone journal page in nav → rejected: loses plant context
- Floating action button on plant detail → possible, but tab is cleaner

## Risks / Trade-offs

- **Risk**: Photo storage could fill device storage → Mitigation: No automatic cleanup for v1, but we can add storage warnings or limits later
- **Risk**: Large journal histories could slow timeline rendering → Mitigation: Use ListView.builder with lazy loading, paginate queries
- **Risk**: Data model changes after launch could require migration → Mitigation: Design schema carefully upfront, use sqflite migration support
- **Risk**: Entry type enum could grow unwieldy → Mitigation: Keep initial set small, design for extensibility
- **Trade-off**: Local-only storage means no backup → Accepted: aligns with app's privacy-first approach, cloud sync can be added later
- **Trade-off**: No photo comparison in v1 → Accepted: keeps scope manageable, can be added incrementally
