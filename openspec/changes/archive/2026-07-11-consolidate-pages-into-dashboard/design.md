## Context

Currently OpenPlants has 6 top-level pages managed by `PageItem` enum (`todayDashboard`, `careSchedule`, `plantIdentification`, `more`, `plantCollection`, `speciesLibrary`). The `HomePage` builds either a `PageView` (phone) or `Offstage` stack (tablet) of `NavBarNavigator` widgets, each wrapping a feature page in its own `Navigator`.

Three of these pages overlap in function:

- **Today Dashboard** shows a header, quick-action strip, due/overdue tasks, and a carousel of 3 recent plants. When the collection is empty it shows an onboarding prompt.
- **Plant Collection** shows ALL plants as cards with search, room/status filters, journal counts. This is the real plant browser.
- **Plant Identification** is a camera → classifier → results flow better suited as a modal action.
- **Species Library** is a browsable encyclopedia whose data is consumed behind-the-scenes by the care schedule engine, identification matching, and plant detail pages.

The bottom navigation is configurable (order + hidden items via settings), which adds complexity. Consolidating to 3 fixed tabs eliminates this configuration surface entirely.

## Goals / Non-Goals

**Goals:**
- Merge `TodayDashboardPage` and `PlantCollectionPage` into a single unified dashboard page that spans the full plant management surface (quick actions + tasks + full plant grid with search/filter)
- Remove `PlantIdentificationPage` as a top-level tab; make camera capture + classification a modal/sheet triggered from dashboard quick actions or FAB
- Remove `SpeciesLibraryPage` from navigation; species data continues to power identification results, care plans, and plant detail pages invisibly
- Reduce `PageItem` enum to 3 values: `dashboard`, `careSchedule`, `more`
- Remove the nav bar ordering/hiding settings (no longer needed with 3 fixed tabs)
- Keep `PlantCollectionDetailPage` reachable from the dashboard's own navigator stack
- Keep `SpeciesDetailPage` reachable from identification results (tapping a species match) and plant detail (viewing care info)

**Non-Goals:**
- Not changing the plant detail page content or layout
- Not changing the care schedule page
- Not changing the More page content (absorbs existing entries unchanged)
- Not changing the identification classifier, ONNX pipeline, or species data (SpeciesEntity)
- Not changing data models, persistence, or JSON schemas
- Not changing the tablet layout pattern (Offstage navigators still work with 3 items)

## Decisions

### Decision 1: Unified dashboard absorbs plant collection as a section, not a tab switch
**Rationale**: The simplest merge — the dashboard's `CustomScrollView` gains a new sliver section for the full plant grid after the existing tasks/carousel sections. The plant grid brings its search bar and filter chips inline. No new page, no tab switch, no additional navigation state.

**Layout order** (top to bottom):
1. Header ("My Plants")
2. Quick-action strip (Add Plant, Identify, Diagnose)
3. Due Today section (if any)
4. Overdue section (if any)
5. Search bar + filter chips (care status, room)
6. Full plant grid (scrollable, from existing plant collection page)
7. Onboarding empty state replaces everything when collection is empty

**Alternatives considered**: Keep both as separate sections with a segmented control → adds UI chrome. Merge at the navigator level → over-engineered.

### Decision 2: Identification becomes a full-screen modal route
**Rationale**: The identification flow (camera → inference → results → action) is a self-contained interaction. A full-screen modal preserves the camera preview area and green-dot animation without competing with the dashboard layout. The modal is triggered from:
- Quick-action "Identify" button on the dashboard
- A FAB on the dashboard (optional, can be added later)

The existing `PlantIdentificationPage` widget is reused with minimal changes — just remove its wrapping `AnimatedEntry`/`AnimatedExit` and the `NavBarNavigator` scaffolding.

**Alternatives considered**: Bottom sheet → too constrained for camera preview + results. Inline section on dashboard → adds complexity when camera is active. Keep as a tab → contradicts the consolidation goal.

### Decision 3: 3 fixed tabs, no configurable ordering
**Rationale**: With only 3 tabs (Dashboard, Care, More), the existing settings-based ordering and hiding features become unnecessary complexity. Dashboard is always first (the home), Care is second, More is the overflow. The settings UI for nav bar customization is removed.

The 3 tabs fit comfortably on screen without scrolling on any phone width, so the scrollable nav bar behavior becomes unnecessary.

**Alternatives considered**: Keep 6 tabs and hide 3 via settings → adds maintenance for a transitional state. Keep ordering configurable → over-engineering for 3 items.

### Decision 4: Species library list page removed, detail page kept
**Rationale**: The `SpeciesLibraryPage` (browsable list with search/filters) is the only component removed. The `SpeciesDetailPage` (individual species view with care plan) stays reachable from:
- Identification results: tapping a matched species opens detail
- Plant detail page: tapping a plant's species name opens detail
- Direct link from a care plan widget

The `SpeciesLibraryUsecases` and `SpeciesLibraryRepository` remain unchanged. The `SpeciesLibraryDatasource` (bundled JSON) stays.

**Alternatives considered**: Keep species browsing but move to More tab → still a full page. Remove entirely → users lose ability to discover new species. This keeps discovery via identification (scan a plant → learn about it).

### Decision 5: Nav bar settings simplified
**Rationale**: The settings currently store `navBarItemOrder` (ordered list of PageItem IDs) and `hiddenNavBarItems` (set of hidden IDs). With 3 fixed tabs, these settings are no longer meaningful. On migration:
- Any existing setting values are ignored (no crash, no read)
- The settings UI for nav bar customization is removed from `MoreSettingsPage`
- `orderedPageItemsFromSettings` and `hiddenPageItemsFromSettings` functions are removed
- The nav bar always shows Dashboard, Care, More in that order

**Alternatives considered**: Keep settings but limit to 3 items → maintenance burden for no user value. Keep settings as-is with only 3 visible → confusing (why can't I hide Dashboard?).

## Risks / Trade-offs

- **[Risk] Users with heavily customized nav layouts lose their configuration** → Mitigation: no migration needed — settings are simply ignored. The 3 tabs are a strict superset of useful pages. No user data is lost.
- **[Risk] Identification results that previously showed "View species" open species detail via the app's root navigator** → The `onViewSpeciesLibrary` callback on `PlantIdentificationPage` currently triggers a tab switch to the species library tab. With that tab removed, the callback opens species detail as a pushed route on the root navigator instead (same destination, no tab switch).
- **[Trade-off] Dashboard may become long on phones** — The unified page shows tasks + search + filters + grid. Mitigation: the CustomScrollView handles scrolling naturally. The search bar can be collapsed by default.
- **[Trade-off] Users lose the ability to browse species by difficulty/toxicity** — The species library list page is the only place to discover "what easy, non-toxic plants exist?" without scanning one. Mitigation: this is a power-user feature. Adding a "Discover plants" entry in More could restore it later if needed.
- **[Risk] `PageItem` enum removal is breaking for settings serialization** — Existing settings files may reference `plantCollection`, `plantIdentification`, or `speciesLibrary` in `navBarItemOrder`/`hiddenNavBarItems`. Mitigation: on first launch after upgrade, the settings reader silently ignores unrecognized enum values. No crash, no data loss.
- **[Risk] Plant collection page tests need updating** — Tests that create `PlantCollectionPage` directly or test its widget behavior need to be retargeted to the unified dashboard. Mitigation: the grid/search/filter logic is extracted into a reusable widget that both old and new pages can share during migration.

### Layout Structure

```
┌─────────────────────────────────────┐
│  Header: "My Plants"                │
├─────────────────────────────────────┤
│  [➕ Add] [📷 Identify] [🩺 Diagnose]│  ← Quick action strip
├─────────────────────────────────────┤
│  💧 Pothos — water today            │  ← Due tasks (conditional)
│  🌿 Fern — fertilize today          │
├─────────────────────────────────────┤
│  ⚠️ Monstera — water 2d overdue     │  ← Overdue tasks (conditional)
├─────────────────────────────────────┤
│  [🔍 Search plants...]              │  ← Search bar
│  [All] [💧] [🧪] [🚨]  [Room ▼]    │  ← Filter chips
├─────────────────────────────────────┤
│  ┌──────┐ ┌──────┐ ┌──────┐       │
│  │Pothos│ │Fern  │ │Monst│       │  ← Plant grid (full collection)
│  │ 💧  │ │ 😊  │ │ 🚨  │       │
│  └──────┘ └──────┘ └──────┘       │
│  ┌──────┐ ┌──────┐                │
│  │Aloe  │ │Cactus│                │
│  │ 😊  │ │ 😊  │                │
│  └──────┘ └──────┘                │
├─────────────────────────────────────┤
│  🏠 Dashboard  📅 Care  ⚙️ More    │  ← Bottom nav (3 tabs)
└─────────────────────────────────────┘
```

### Navigation Flows After Consolidation

```
Dashboard ──tap plant──→ PlantCollectionDetailPage  (dashboard's navigator stack)
  │
  ├── tap "Identify" ──→ IdentificationModal (full-screen)
  │                        └── tap species → SpeciesDetailPage (root navigator)
  │                        └── "Add to collection" → PlantCollectionFormPage
  │
  ├── tap "Add Plant" ──→ PlantCollectionFormPage  (dashboard's navigator stack)
  │
  └── tap "Diagnose" ──→ DiagnosisPage             (More's flow, or root navigator)

Care ──tap task──→ PlantCollectionDetailPage (care's navigator stack)
  │
  └── tap plant name → PlantCollectionDetailPage

More ──tap item──→ Rooms / Log Symptom / Diagnosis / Settings / About
```
