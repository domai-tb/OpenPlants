## Context

OpenPlants is a Flutter app with Clean Architecture, DI via GetIt, and no state-management packages. Each feature module lives in `lib/pages/pageN/` with a datasource → repository → use-cases → entity → page stack. The app already has offline image classification (ONNX-based plant identification) and bundled local assets. There is no existing species library or external API for plant care data — all species information must be shipped with the app.

The species library must work fully offline, integrate with the existing identification results, and follow the existing page architecture pattern exactly.

## Goals / Non-Goals

**Goals:**
- Provide a searchable, browsable library of ~100+ plant species with care information bundled as a JSON asset.
- Display a species detail page with care defaults (difficulty, light, water, humidity, soil, repotting, toxicity).
- Generate a structured care plan from a species entity (watering schedule, light positioning, repotting timeline).
- Allow users to navigate from a plant identification result to the corresponding species detail page.
- Follow the existing Clean Architecture pattern exactly (datasource → repository → usecases → entity → page).
- Work completely offline — no network calls for species data or care plans.

**Non-Goals:**
- User-editable species data (read-only bundled asset).
- Cloud-synced or user-contributed species data.
- Favoriting or saving species to a personal collection (out of scope for this change).
- Watering reminders or push notifications (covered by a future calendar/reminder feature).
- Camera-based identification within the species library page itself (already exists in plant_identification page).

## Decisions

### Decision 1: Bundled JSON asset as data source (not SQLite, not API)
**Rationale**: The species data is read-only, small (~100-200 KB for 100+ species), and changes infrequently. A bundled JSON asset is simpler than setting up SQLite (no sqflite dependency, no migration management) and works offline by definition. Loading into memory at startup is acceptable at this data size. If the catalog grows beyond 500+ species, migrating to a shipped SQLite database can be done later without changing the repository API.

**Alternatives considered**:
- *SQLite database (sqflite)*: Adds a dependency, migration overhead, and complexity for read-only data. Not justified at this scale.
- *Remote API*: Requires internet, server costs, and eliminates offline use — defeats the app's companion purpose.
- *Dart model classes with manual data*: Maintainable only at very small scale (<20 species).

### Decision 2: Species entity as a single sealed class (not a hierarchy)
**Rationale**: All species share the same fields (name, care data, toxicity). There's no behavior differentiation that warrants subclasses. A single `SpeciesEntity` with required named fields keeps things simple and matches the existing `Page1ItemEntity` pattern. The entity is immutable (`const` constructor, `final` fields).

### Decision 3: Species library gets its own page with a dedicated nav tab
**Rationale**: The species library is a top-level feature (like page1, plant_identification) that users access frequently — browsing plants, looking up care info. A dedicated nav tab with an appropriate icon (e.g., `menu_book` or `local_florist`) gives it equal prominence. An alternative would be a sub-page within another tab, but that adds navigation depth and hides discoverability.

### Decision 4: Care plan is a use-case, not a separate page
**Rationale**: Care plans are derived from species data (watering intervals, light needs, humidity targets). They are best exposed as a method on `SpeciesLibraryUsecases` that takes a `SpeciesEntity` and returns a `CarePlan` value object. The species detail page can then display the care plan inline. This avoids an extra page in the navigation stack while keeping the logic testable.

### Decision 5: Identification lookup via match on scientific name
**Rationale**: The plant classifier already produces a scientific name string as its classification result. The species library indexes species by scientific name. A simple lookup use-case (`speciesForScientificName(String name)`) bridges the two. This requires no changes to the classifier's output format. If name normalization is needed (e.g., case differences), the use-case handles it.

## Risks / Trade-offs

- **Bundled data staleness**: Species data is fixed at build time. If the user wants updated care information, they must update the app. *Mitigation*: The JSON schema is versioned; future changes can add a data-update mechanism without changing the entity model.
- **JSON parse failure at startup**: A malformed asset JSON crashes the species data source. *Mitigation*: The data source validates JSON structure on first load and returns a `Failure` — the page handles the error state gracefully.
- **Asset size growth**: Adding hundreds of species with detailed care data could bloat the APK. *Mitigation*: Each species entry is ~1-2 KB of JSON. At 500 species this is ~1 MB, acceptable for a mobile app. If growth exceeds 5 MB, consider data compression or on-demand loading.
- **Scientific name mismatch**: The classifier output may not exactly match the species database key (subspecies, synonym, typo). *Mitigation*: The lookup use-case performs case-insensitive comparison and optionally fuzzy matching (Levenshtein distance ≤ 2) for close matches.
