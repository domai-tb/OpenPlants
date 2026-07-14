## Why

The species library feature has a fully implemented data layer (entity, datasource, repository, usecases) and a detail page, but no way for users to discover or browse the species catalog. The More page is the natural home for this — it already hosts secondary features like Rooms, Diagnosis, and Settings. Adding a "Species List" entry gives users a clear path to explore all 24 bundled species without needing to identify a plant first.

## What Changes

- Add a "Species List" menu item to the More page, positioned above "Rooms"
- Create a new `SpeciesLibraryPage` that displays all species in a scrollable, searchable list
- Each list item shows: scientific name, common names (primary), difficulty badge, and toxicity icon if applicable
- Tapping a species opens the existing `SpeciesDetailPage`
- Search/filter functionality: filter by name (scientific or common) and difficulty level
- Localization: new strings for the More page entry and the species list page

## Capabilities

### New Capabilities

- `species-list-browse`: A browsable, searchable list of all species accessible from the More page. Covers the list page UI, search/filter controls, and navigation entry point.

### Modified Capabilities

- `species-browse`: The existing spec covers the detail page only. No requirements change — the list page is a new entry point that navigates to the existing detail page.

## Impact

- **New file**: `lib/pages/species_library/species_library_page.dart` — the list page widget
- **Modified file**: `lib/pages/more/more_datasource.dart` — add species list item to hardcoded menu
- **Modified file**: `lib/pages/more/more_page.dart` — add navigation case for species list
- **Modified file**: `assets/l10n/l10n_en.arb` (and other locale files) — new localization keys
- **No new dependencies**: the species library usecases are already wired in `injection.dart` and `app_services.dart`
- **No API changes**: purely a UI/navigation addition using existing data layer
