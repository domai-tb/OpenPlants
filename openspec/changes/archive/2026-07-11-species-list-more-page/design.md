## Context

The OpenPlant app uses Clean Architecture with a fixed 5-file module pattern (datasource, repository, usecases, entity, page). The species library feature is already fully implemented at the data layer — `SpeciesLibraryUsecases` provides `getAllSpecies()`, `searchSpecies()`, and `filterSpecies()`. A detail page (`SpeciesDetailPage`) exists and is navigable from identification results. However, there is no browsable list page and no entry point in the More page.

The More page currently shows 5 hardcoded menu items via `MoreDataSource`. Each item has an `id`, `title`, and `subtitle`. Navigation is handled by a `switch` on `item.id` in `more_page.dart`.

## Goals / Non-Goals

**Goals:**
- Add a "Species List" entry to the More page that opens a searchable, scrollable list of all 24 species
- Reuse existing `SpeciesLibraryUsecases` for data access — no new data layer code
- Follow the app's existing patterns: `StatefulWidget`, `AppScope.of(context).services`, Material Design
- Support text search across scientific and common names
- Navigate to existing `SpeciesDetailPage` on tap

**Non-Goals:**
- Adding new species data or modifying the JSON asset
- Filtering by difficulty/humidity/water needs (future enhancement)
- Adding species to bottom navigation or dashboard
- Modifying the `SpeciesDetailPage` itself
- Localizing the species data content (names, descriptions remain in English)

## Decisions

### 1. New page file in species_library module

**Decision**: Create `lib/pages/species_library/species_library_page.dart` as the list page.

**Rationale**: The species library module already exists with its own directory. Adding the list page here keeps all species-related UI together. The page will be navigated to from the More page but belongs logically to the species library feature.

**Alternatives considered**:
- Creating it in `lib/pages/more/` — rejected because the page's primary concern is species browsing, not the More menu structure.

### 2. Search via existing usecases, no new repository methods

**Decision**: Use `SpeciesLibraryUsecases.getAllSpecies()` for the full list and `searchSpecies(query)` for search. Filter in-memory for difficulty chips.

**Rationale**: The usecases already expose exactly the methods needed. `searchSpecies` does fuzzy matching across common names, scientific name, and description. In-memory filtering for difficulty is trivial on a 24-item list.

**Alternatives considered**:
- Adding a new `getSpeciesList()` method — unnecessary, `getAllSpecies()` already exists.

### 3. Search as a TextField in the AppBar

**Decision**: Place a search `TextField` in the `AppBar` area, similar to how other apps handle in-page search. Show results inline as the user types (debounced ~300ms).

**Rationale**: Keeps the UI simple and familiar. The list is small (24 items) so instant filtering is fine.

**Alternatives considered**:
- A search icon that opens a separate search page — overkill for 24 items.

### 4. Localization for More page entry only

**Decision**: Add l10n keys for the More page menu item title/subtitle and the species list page title. Species names remain in English (scientific + common names from the JSON).

**Rationale**: The species data is botanical — translating scientific names is incorrect, and common names vary by region. The UI chrome (menu entry, page title, search hint) should be localized.

### 5. Difficulty badge as a colored chip

**Decision**: Show a small colored chip next to each species name indicating difficulty: green for easy, amber for moderate, red for challenging.

**Rationale**: Provides at-a-glance information without requiring the user to open the detail page. Matches the existing difficulty badge pattern in `SpeciesDetailPage`.

## Risks / Trade-offs

- **List item density**: 24 items is manageable but will grow. A simple `ListView.builder` is sufficient now; if the list exceeds ~50 items in the future, adding section headers (alphabetical) or category grouping would help. → Mitigation: structure the list to support future grouping without major refactoring.

- **No offline indicator**: The species data is bundled in the asset, so it's always available. No risk of network-dependent loading failures. → No mitigation needed.

- **Search debounce**: On low-end devices, filtering 24 items on every keystroke is negligible. The 300ms debounce is conservative. → No mitigation needed.
