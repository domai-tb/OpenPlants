## Context

The Today dashboard (`today_dashboard_page.dart`) currently renders its entire body inside a single `CustomScrollView` with one `SliverList`. This includes the header greeting, quick-action strip (Identify / Add / Diagnose), due-tasks section, overdue-tasks section, and the `PlantGridSection` — all scrolling together. The `PlantGridSection` itself is a `Column` containing a section header, search bar, filter chips, and the plant grid.

Users need the action buttons and filter controls to remain visible at all times while browsing their plant collection. Currently they scroll off-screen.

## Goals / Non-Goals

**Goals:**
- Pin the header, quick-action strip, and plant-collection filter controls (search bar + filter chips) at the top of the viewport.
- Make only the plant grid scrollable in the remaining space.
- Maintain pull-to-refresh on the scrollable area.
- Keep all existing functionality intact (search, filter chips, task sections, empty state).

**Non-Goals:**
- Changing the visual design or styling of any widgets.
- Restructuring the data layer or use-cases.
- Adding new navigation or features.

## Decisions

### Decision 1: Use a `Column` with `Expanded` for the fixed + scrollable split

**Choice**: Replace the single `CustomScrollView` with a `Column` where the top section (header, quick actions, task summaries) is rendered in fixed children and the plant grid lives inside an `Expanded` > `RefreshIndicator` > `CustomScrollView`.

**Rationale**: Flutter's `Column` + `Expanded` is the standard pattern for fixed-header + scrollable-body layouts. It avoids nested `CustomScrollView` coordination issues and keeps the scroll physics simple.

**Alternatives considered**:
- `NestedScrollView`: More complex, designed for tab-based nested scrolling. Overkill here.
- `CustomScrollView` with `SliverPersistentHeader`: Possible but adds complexity for pinning multiple independent sections.

### Decision 2: Extract filter controls from `PlantGridSection` into the fixed area

**Choice**: Move the search bar and filter chip row out of `PlantGridSection`'s internal `Column` and render them in the parent's fixed section. `PlantGridSection` becomes a pure grid widget.

**Rationale**: Keeps the fixed section self-contained in the page widget. The filter state already lives in `PlantGridSectionState`, so it will need to be lifted or the section will need to accept filter state from outside.

**Alternatives considered**:
- Keep filters inside `PlantGridSection` and use `SliverPersistentHeader` to pin them: More complex, ties pinning logic to a child widget.

### Decision 3: Keep due/overdue task sections in the scrollable area

**Choice**: Move `_DueTasksSection` and `_OverdueTasksSection` into the scrollable area alongside the plant grid, since they are content that benefits from scrolling.

**Rationale**: Tasks are informational content, not persistent controls. Scrolling them with the plant grid is natural.

**Alternatives considered**:
- Pin them above the grid: Would reduce scrollable space and they aren't actions users need constant access to.

## Risks / Trade-offs

- **Risk**: Lifting filter state out of `PlantGridSection` may require passing more props or using a callback pattern. → Mitigate by keeping the state in `PlantGridSection` and using a ` GlobalKey` to control it from outside, or by lifting state to the page.
- **Risk**: The `RefreshIndicator` wrapping only the grid may feel different if users expect to pull-to-refresh from anywhere on the page. → Mitigate by keeping `RefreshIndicator` on the scrollable area only; this is standard UX.
- **Trade-off**: The fixed section takes up vertical space that reduces the visible grid area. On small screens this may be noticeable. → Acceptable since the fixed section contains essential controls.
