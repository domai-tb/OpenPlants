## Why

OpenPlants currently shows a generic placeholder as its home tab (page1) — a list of random items with no connection to the user's actual plants or care tasks. Every time a user opens the app they are greeted by irrelevant content instead of actionable information about their plants. The home screen is the highest-visibility surface in the app and should be the launch point for the daily care loop: showing what needs attention **today**, surfacing recent activity, and offering one-tap access to the core actions (add plant, identify, diagnose).

## What Changes

- **Replace page1 (home tab) with a Today dashboard** — the default landing tab becomes an at-a-glance overview of the user's plant care status
- **Due/overdue task cards** — pull from the care schedule engine (page8) to show tasks that need attention today, grouped by "Due Today", "Overdue", and "Upcoming"
- **Plant health warnings** — surface plants with alerts: missed watering, overdue fertilizing, pest warnings
- **Recently updated plants** — carousel or grid of recently cared-for plants from the collection (page7)
- **Quick-action strip** — persistent row with "Add Plant", "Identify", "Diagnose" buttons that navigate to the relevant pages (page7 add flow, page3 camera, page3 classifier)
- **Empty-state onboarding** — when the user has no plants yet, show a friendly prompt with a guided path to add their first plant
- **Navigation update** — `PageItem.page1` is reassigned to the Today dashboard; the old page1 placeholder is deprecated/removed

## Capabilities

### New Capabilities

- `today-dashboard`: The home screen aggregating due tasks, plant health warnings, recent plant activity, and quick actions. Consumes data from `plant-inventory` and `care-schedule-engine` capabilities but owns its own UI composition and data-fetch orchestration.

### Modified Capabilities

*(No existing capability requirements are changing — the dashboard is a new consumer of existing capabilities.)*

## Impact

- **New files:** `lib/pages/page1/` is rewritten with the 5-file pattern (datasource, repository, usecases, entity, page) — replacing the placeholder entirely
- **Modified files:**
  - `lib/pages/home/page_navigator.dart` — `PageItem.page1` presentation updated (icon/title), routing unchanged (still page1)
  - `lib/pages/home/home_page.dart` — `PageItem.page1` already exists; no structural change needed
  - `lib/core/app_services.dart` — page1 use-cases already wired; update their type to new `Page1Usecases`
  - `lib/core/injection.dart` — re-register page1 datasource/repository/usecases with new implementations
  - `lib/l10n/` — add dashboard-specific strings (section headings, empty-state copy, quick-action labels)
  - `lib/widgets/` — may add shared dashboard card widgets if reusable beyond page1
- **Dependencies:** No new pub dependencies; consumes from existing `plant-collection` and `care-schedule-system` via `AppServices`
- **Deprecation:** The old placeholder page1 files (`page1_item_entity.dart`, etc.) are replaced entirely
