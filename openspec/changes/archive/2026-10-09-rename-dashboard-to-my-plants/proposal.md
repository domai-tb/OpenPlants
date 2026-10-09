## Why

Care tasks appear in two places (Dashboard + Care Schedule), causing confusion about where to act. Dashboard should be plants-only for browsing; tasks belong in Care Schedule.

## What Changes

- Remove Due Today section from Dashboard (TodayDashboardPage).
- Remove Overdue section from Dashboard.
- Rename Dashboard page header and bottom-nav label from "Today" to "My Plants" via l10n.
- Keep plant grid, search, room/status filters unchanged on Dashboard.
- No change to Care Schedule page; it remains sole home for Due Today / Overdue / Upcoming / Completed Early.

## Capabilities

### New Capabilities

- None.

### Modified Capabilities

- `unified-dashboard`: remove due/overdue task sections, dashboard becomes plant grid only, title becomes "My Plants".
- `today-dashboard`: remove due/overdue task sections, title becomes "My Plants".

## Impact

- `lib/pages/today_dashboard/today_dashboard_page.dart`: delete `_DueTasksSection` / `_OverdueTasksSection` usage, simplify `DashboardData` consumption to plant grid only.
- `lib/pages/today_dashboard/today_dashboard_*` (usecases/repository/datasource/entity): stop querying care schedule engine for dashboard if unused elsewhere.
- `lib/pages/home/page_navigator.dart`: nav label switches to new l10n key automatically.
- `assets/l10n/l10n_en.arb` (+ other locales): `todayDashboardTitle` value "Today" → "My Plants" (or new key + deprecate old).
- Specs: `today-dashboard`, `unified-dashboard` updated; `care-tasks-ui` unchanged.
