## Why

On the Today page, the entire body (header, quick action buttons, due tasks, overdue tasks, and plant collection) scrolls as one monolithic `CustomScrollView`. This means the action buttons (Identify, Add, Diagnose) and filter controls scroll off-screen when the user scrolls through their plant collection. Users lose quick access to primary actions while browsing plants.

## What Changes

- The top section (header, quick action strip, and filter controls) is pinned and does not scroll.
- Only the plant collection grid (`PlantGridSection`) scrolls vertically below the fixed header.
- The due-tasks and overdue-tasks sections remain part of the scrollable content alongside the plant grid (or are grouped with the fixed section if they serve as status indicators).

## Capabilities

### New Capabilities

- `fixed-dashboard-header`: Pins the Today page header, quick-action strip, and filter row so they remain visible while the plant collection scrolls independently.

### Modified Capabilities

- `unified-dashboard`: The layout structure of the Today page body changes from a single `CustomScrollView` to a fixed-header + scrollable-body arrangement.

## Impact

- **Code**: `lib/pages/today_dashboard/today_dashboard_page.dart` — `_buildBody` method and potentially `_QuickActionStrip` / `_buildHeader`.
- **Widgets affected**: `PlantGridSection`, `_QuickActionStrip`, `_buildHeader`, `_DueTasksSection`, `_OverdueTasksSection`.
- **No API or data-layer changes** — purely a UI layout restructuring.
- **No new dependencies**.
