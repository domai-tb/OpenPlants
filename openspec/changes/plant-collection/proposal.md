## Why

OpenPlants currently lacks a plant inventory system — users can identify plants via the classifier (page 3) and view placeholder content on other pages, but there is no way to maintain a personal collection of owned plants with photos, species information, and care tracking. This is the central feature that transforms the app from a passive reference tool into an active companion for plant owners.

## What Changes

- **New page (page7):** Plant collection list view — the user's inventory of all their plants
- **Plant CRUD:** Add, edit, delete plants with name, photo(s), species, room assignment, and notes
- **Photo capture & storage:** Camera roll import via `image_picker` (already a dependency) with local file storage
- **Offline-first persistence:** Full local storage using `shared_preferences` for JSON-serialized plant data (matching the existing `SettingsController` pattern); no remote backend required
- **Species linking:** Plants can optionally link to a species identified via the classifier
- **Room assignment:** Users can tag plants with a room name (e.g., "Living Room", "Bedroom")
- **Care status tracking:** Simple care status field (needs_water, needs_fertilizer, happy) with optional last-watered / last-fertilized timestamps
- **Navigation integration:** New tab added to the bottom nav bar in the `PageItem` enum

## Capabilities

### New Capabilities

- `plant-inventory`: Core CRUD for the plant collection — add, view, edit, delete plants with photos, species, room, and notes. This is the central inventory of the app.
- `offline-storage`: Local persistence layer for plant data and photos using `shared_preferences` JSON serialization and local file system for images. Fully offline with no remote dependency.
- `care-tracking`: Care status management — track watering/fertilizing schedules, set care status per plant, and surface plants needing attention.

### Modified Capabilities

*(No existing capability requirements are changing — this is a new feature addition.)*

## Impact

- **New files:** `lib/pages/page7/` directory with the 5-file pattern (datasource, repository, usecases, entity, page)
- **Modified files:**
  - `lib/core/app_services.dart` — add `page7` use-cases field
  - `lib/core/injection.dart` — register page7 datasource, repository, usecases
  - `lib/pages/home/page_navigator.dart` — add `PageItem.page7` case, presentation, and routing
  - `lib/pages/home/home_page.dart` — add page7 navigator keys
  - `lib/core/settings.dart` — update default nav bar order to include page7
  - `lib/l10n/l10n_en.dart` / `l10n_de.dart` — add page7 title and collection-related strings
- **Asset impact:** Plant photos stored in app's local documents directory (no new bundled assets)
- **Dependencies:** No new pub dependencies required (`image_picker`, `shared_preferences`, `intl` already declared)
