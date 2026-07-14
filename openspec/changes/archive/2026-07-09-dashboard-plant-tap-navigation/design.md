## Context

The Today Dashboard displays a horizontal carousel of recent plants (`_RecentPlantsCarousel`) and care-task cards (`_CareTaskCard`). Both show plant names but neither navigates to the plant's detail page on tap.

The existing navigation architecture uses a **nested Navigator pattern**: each bottom-nav tab has its own `Navigator` stack. Cross-tab navigation uses callbacks passed from `home_page.dart` through `page_navigator.dart` to child pages. The established precedent is `onNavigateToAddPlant`, which switches to the Plant Collection tab and pushes the add-plant form.

The detail page `PlantCollectionDetailPage` expects a full `PlantEntity` object. The today dashboard only holds `PlantSummary` (id, name, photoPath, updatedAt) — insufficient for the detail page.

## Goals / Non-Goals

**Goals:**
- Tapping a plant in the recent-plants carousel opens `PlantCollectionDetailPage` for that plant
- Tapping a care-task card opens the detail page for the associated plant
- Follow the existing callback pattern (`onNavigateToAddPlant`) for consistency
- Keep the today dashboard decoupled from plant collection internals

**Non-Goals:**
- Redesigning the carousel layout or tap targets
- Adding new detail views specific to the dashboard
- Changing how `PlantCollectionDetailPage` works
- Navigating from care tasks to a "complete task" flow (that's a separate concern)

## Decisions

### Decision 1: Callback with plant ID, lookup in plant collection tab

The today dashboard will call `onNavigateToPlantDetail(String plantId)`. The plant collection tab handles fetching the full `PlantEntity` and pushing the detail page.

**Why over alternatives:**

| Approach | Pros | Cons |
|----------|------|------|
| Callback with ID (chosen) | Today dashboard stays lightweight; no new usecase needed; follows `onNavigateToAddPlant` pattern | plant collection tab needs a public lookup method |
| Today dashboard fetches full entity | Self-contained | Couples today dashboard to `PlantEntity`; adds datasource/repository/usecase methods to today_dashboard feature |
| Push route by ID with `onGenerateRoute` | Standard Flutter routing | Breaks nested navigator pattern; would need route handler to fetch entity async |

The callback approach wins because it matches the existing architecture exactly. The plant collection tab already has the data access layer — it just needs a method to look up a single plant by ID.

### Decision 2: Plant collection tab owns the lookup and navigation

`home_page.dart` will implement the callback by:
1. Switching to the Plant Collection tab
2. Looking up the `PlantEntity` by ID via `PlantCollectionUsecases`
3. Pushing `PlantCollectionDetailPage(plant: entity)` onto the plant collection tab's navigator

This mirrors how `onNavigateToAddPlant` works: switch tab → push page.

### Decision 3: Care-task cards also navigate to plant detail

Care tasks have a `plantName` but no plant ID. The today dashboard datasource will need to include the plant ID in care tasks returned to the dashboard. This requires a small change to `CareTask` to include `plantId`.

Alternatively, care-task cards could remain non-navigable for now and only the carousel gets wired up. This is the simpler path and can be done first.

**Recommendation:** Wire the carousel now (minimal change). Wire care-task cards as a follow-up if desired, since it requires adding `plantId` to `CareTask`.

### Decision 4: No loading indicator needed for the lookup

The plant collection tab's data is already loaded in memory (it's the active data source). The lookup is a local search, not a network call. No spinner or skeleton needed.

## Risks / Trade-offs

- **[Risk] Plant not found** → If the plant was deleted between dashboard load and tap, the lookup returns null. Mitigation: show a snackbar "Plant not found" and stay on the current page.

- **[Risk] Callback threading** → Adding another callback through `page_navigator.dart` increases the parameter list. Mitigation: this is the established pattern; the alternative (service locator or event bus) would be a larger architectural change.

- **[Trade-off] Care tasks not wired** → Care-task cards won't navigate to plant detail in this change. This is acceptable because the carousel is the primary navigation surface for plants on the dashboard.
