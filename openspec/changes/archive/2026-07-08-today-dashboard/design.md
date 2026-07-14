## Context

OpenPlants uses Clean Architecture with the 5-file feature pattern (datasource → repository → usecases → entity → page), GetIt DI, and `shared_preferences` JSON persistence. The app has 6 placeholder pages (page1–page6), plus two in-progress features:

- **plant-collection (plant_collection):** Plant inventory with CRUD, photos, species linking, room assignment, and care status tracking.
- **care-schedule-system (care_schedule):** Rule-driven scheduling engine with 8 task types, seasonal adjustments, per-plant config, and a task-completion history.

The current home tab is a generic placeholder with randomly generated items — irrelevant to the user's plants. The **today dashboard** replaces it as the app's landing surface, designed to make the daily care loop fast and practical.

**Key constraints:**
- Android-only, offline-first, no remote backend
- All data access goes through `AppScope.of(context).services`
- Navigation uses `mainNavigatorKey` (global) for cross-tab routes and tab-internal navigators for detail pages
- The dashboard is a **consumer only** — it reads from plant-collection and care-schedule but does not manage their data directly

## Goals / Non-Goals

**Goals:**
- Replace the current placeholder content with a today-focused dashboard
- Surface due/overdue care tasks prominently (from care-schedule-engine)
- Show plant health warnings (missed care, overdue tasks)
- Display recently updated plants in a carousel/grid (from plant-inventory)
- Provide one-tap quick actions: Add Plant, Identify, Diagnose
- Show an onboarding empty-state when the user has no plants
- Follow the existing Clean Architecture pattern and DI wiring

**Non-Goals:**
- Plant CRUD (handled by plant-collection feature on plant_collection)
- Schedule engine or task creation (handled by care-schedule-system on care_schedule)
- Push notifications or background task alerts
- Drag-to-reorder dashboard sections or user-configurable layout
- Weather integration or outdoor plant data
- Analytics or usage tracking

## Decisions

### Decision 1: The today dashboard replaces the placeholder in-place

The today dashboard is the default home tab (first in `PageItem.todayDashboard`, the bottom nav, and the nav bar ordering). Rather than adding a new page, this change rewrites `lib/pages/today_dashboard/` entirely — keeping the same `PageItem.todayDashboard` enum entry. This avoids:
- Changing the default tab index everywhere
- Adding dead code from a deprecated page
- Confusion about which tab is "home"

The old placeholder files (datasource/repository/usecases) are replaced with dashboard-specific implementations.

### Decision 2: Dashboard use-cases orchestrate across downstream capabilities

The `TodayDashboardUsecases` class does not own plant or task data — it holds references to the relevant downstream use-cases via constructor injection. The dashboard's `getDashboardData()` method calls:
1. `PlantCollectionUsecases.getAllPlants()` (or equivalent from plant_collection)
2. `CareScheduleUsecases.getTasksDueToday()` (or equivalent from care_schedule)
3. `CareScheduleUsecases.getOverdueTasks()`
4. Optionally: a health-check aggregate

The results are composed into a `DashboardData` entity that the page widget renders. This keeps the dashboard thin — it's a viewer, not a data owner.

**Alternative considered:** Event bus / stream-based updates where the dashboard subscribes to changes. Rejected as over-engineering — the simple call-aggregate pattern works for an app of this scale and keeps data flow explicit.

### Decision 3: Scrollable vertical list with section cards

The dashboard layout is a `CustomScrollView` with `SliverList` sections:
1. **Quick-action strip** — `Row` of icon+label buttons (Add Plant, Identify, Diagnose). Non-scrolling hero area at the top.
2. **Due Today section** — Task cards showing plant name, task type, and due time. Red/amber urgency indicators.
3. **Overdue section** — Same card style, stronger urgency styling, shown only when >0 overdue tasks.
4. **Health warnings section** — Compact cards listing plants needing attention (simplified: overdue tasks act as warnings).
5. **Recent Plants section** — Horizontal `ListView.builder` carousel showing plant thumbnails + name.
6. **Empty-state** — Full-screen friendly illustration + text + "Add your first plant" CTA, shown when collection is empty.

This avoids a rigid grid and adapts naturally to varying amounts of data.

### Decision 4: Navigation via mainNavigatorKey for cross-tab routing

Quick actions navigate to other tabs via the app's `mainNavigatorKey`:
- **Add Plant** → Navigate to plant_collection (plant-collection) add-flow
- **Identify** → Navigate to plant_identification (classifier) camera page
- **Diagnose** → Navigate to care_schedule (care-schedule) or plant_identification depending on context

This reuses the existing navigation architecture — no new routing mechanism needed.

### Decision 5: Dashboard is rebuilt on tab focus (no persistent state)

The dashboard fetches fresh data each time it becomes visible (via `AutomaticKeepAliveClientMixin` or a focus listener). Since the data volume is small (a few dozen plants, a handful of tasks), re-fetching is negligible and ensures the dashboard always reflects the latest state after the user adds a plant or completes a task on another tab.

**Alternative considered:** Stream-based reactive updates from a shared state container. Rejected: the current architecture has no such container, and introducing one for a single consumer is disproportionate.

## Risks / Trade-offs

- **Risk: Dashboard depends on features not yet built** → The today dashboard calls `PlantCollectionUsecases` and `CareScheduleUsecases` which are being built in parallel changes. **Mitigation:** The `TodayDashboardUsecases` interface accepts nullable downstream use-cases or graceful fallbacks — if a capability isn't wired yet, the relevant section is hidden.
- **Risk: Re-fetching on every focus is wasteful if data hasn't changed** → **Mitigation:** Accept for now; the data volume is tiny (< 50 KB total). Add a simple staleness cache (5-second TTL) if profiling shows unnecessary work.
- **Trade-off: No pull-to-refresh on dashboard** → The dashboard refreshes on focus, which covers the vast majority of use cases. Pull-to-refresh can be added as a follow-up.
- **Trade-off: Static section order** → Users cannot reorder dashboard sections. This keeps the implementation simple and matches behavior of most gardening apps.
