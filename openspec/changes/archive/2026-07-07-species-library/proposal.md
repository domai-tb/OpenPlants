## Why

OpenPlants can identify plants via image classification, but the result is just a species name — there's no way to look up care information, toxicity, or detailed species data within the app. Adding a local species library bridges the gap between "what plant is this?" and "how do I care for it?", making the app a true plant-companion tool. A built-in species database also means the app works offline and doesn't rely on an external API for basic care information.

## What Changes

- **New `species_library` page** — a full feature module (data source, repository, use-cases, entity, page) following the existing Clean Architecture pattern.
- **Local species JSON asset** — bundled species data (scientific name, common name, difficulty, light/water/humidity needs, soil, repotting, toxicity) shipped with the app.
- **Species data source** — loads and queries the bundled JSON asset; supports search and filter by field.
- **Species detail page** — read-only view of a single species with all its care information.
- **Species search** — search by scientific name, common name, or keyword.
- **Care-plan generation** — use-case that takes a species entity and generates a structured care plan (watering schedule, light requirements, repotting timeline).
- **Identification integration** — the plant identification result page links to the species detail page for the identified species.
- **Navigation entry** — new `speciesLibrary` entry in `PageItem` enum with a dedicated tab in the bottom/side nav bar.

## Capabilities

### New Capabilities
- `species-data`: Bundled JSON species database with load, search, and query operations. Covers scientific name, common names, care defaults, difficulty, light/water/humidity preferences, soil recommendations, repotting advice, and toxicity flags.
- `species-browse`: Browse and search the species library. Includes a list view with filters (difficulty, light needs, toxicity) and a species detail page showing all care information.
- `care-plan`: Generate structured care plans from species data. Produces watering intervals, light positioning advice, humidity targets, soil recommendations, and repotting schedules.
- `identification-lookup`: Integration with the existing plant identification feature. After classification, the user can tap through to the species detail page for the identified plant.

### Modified Capabilities
*(None — no existing specs are changing.)*

## Impact

- **New feature page**: `lib/pages/species_library/` with the standard 5-file pattern plus a bundled JSON asset.
- **Asset bundle**: A new `assets/species/` directory with `species.json` containing the full species catalog.
- **DI registration**: New species-library data source, repository, and use-cases registered in `lib/core/injection.dart`.
- **AppServices**: New field for `SpeciesLibraryUsecases` in `AppServices`.
- **Navigation**: New `PageItem.speciesLibrary` entry in `page_navigator.dart`, new tab icon and label.
- **HomePage**: New navigator key and animation keys for the species library page.
- **L10n**: New localizations for species-related strings (page title, care labels, search placeholder).
- **No external dependencies** — all data is local/bundled. No new pub packages needed.
