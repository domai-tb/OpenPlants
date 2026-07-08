## Why

OpenPlants currently shows a generic placeholder as its home tab (today_dashboard) — a list of random items with no connection to the user's actual plants or care tasks. Every time a user opens the app they are greeted by irrelevant content instead of actionable information about their plants. The home screen is the highest-visibility surface in the app and should be the launch point for the daily care loop: showing what needs attention **today**, surfacing recent activity, and offering one-tap access to the core actions (add plant, identify, diagnose).

## What Changes

- **Replace the home tab with a Today dashboard** — the default landing tab becomes an at-a-glance overview of the user's plant care status
- **Due/overdue task cards** — pull from the care schedule engine (care_schedule) to show tasks that need attention today, grouped by "Due Today", "Overdue", and "Upcoming"
- **Plant health warnings** — surface plants with alerts: missed watering, overdue fertilizing, pest warnings
- **Recently updated plants** — carousel or grid of recently cared-for plants from the collection (plant_collection)
- **Quick-action strip** — persistent row with "Add Plant", "Identify", "Diagnose" buttons that navigate to the relevant pages (plant_collection add flow, plant_identification camera, plant_identification classifier)
- **Empty-state onboarding** — when the user has no plants yet, show a friendly prompt with a guided path to add their first plant
- **Navigation update** — `PageItem.todayDashboard` is reassigned to the Today dashboard; the old page1 placeholder is deprecated/removed

## Capabilities

### New Capabilities

- `today-dashboard`: The home screen aggregating due tasks, plant health warnings, recent plant activity, and quick actions. Consumes data from `plant-inventory` and `care-schedule-engine` capabilities but owns its own UI composition and data-fetch orchestration.

### Modified Capabilities

*(No existing capability requirements are changing — the dashboard is a new consumer of existing capabilities.)*

## Impact

- **New files:** `lib/pages/today_dashboard/` is rewritten with the 5-file pattern (datasource, repository, usecases, entity, page) — replacing the placeholder entirely
- **Modified files:**
  - `lib/pages/home/page_navigator.dart` — `PageItem.todayDashboard` presentation updated (icon/title), routing unchanged
  - `lib/pages/home/home_page.dart` — `PageItem.todayDashboard` already exists; no structural change needed
  - `lib/core/app_services.dart` — today_dashboard use-cases already wired; update their type to new `TodayDashboardUsecases`
  - `lib/core/injection.dart` — re-register today_dashboard datasource/repository/usecases with new implementations
  - `lib/l10n/` — add dashboard-specific strings (section headings, empty-state copy, quick-action labels)
  - `lib/widgets/` — may add shared dashboard card widgets if reusable beyond the dashboard
- **Dependencies:** No new pub dependencies; consumes from existing `plant-collection` and `care-schedule-system` via `AppServices`
- **Deprecation:** The old placeholder today_dashboard files are replaced entirely
