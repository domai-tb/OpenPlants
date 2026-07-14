## 1. Restructure page layout

- [x] 1.1 Replace the single `CustomScrollView` in `_buildBody` with a `Column` containing fixed header children and an `Expanded` scrollable area for the plant grid
- [x] 1.2 Move `_buildHeader` and `_QuickActionStrip` into the fixed (non-scrolling) section of the `Column`
- [x] 1.3 Move `_DueTasksSection` and `_OverdueTasksSection` into the scrollable area above the plant grid

## 2. Extract filter controls from PlantGridSection

- [x] 2.1 Refactor `PlantGridSection` to separate the search bar + filter chips from the grid widget, exposing the grid as a standalone scrollable widget
- [x] 2.2 Move the search bar and filter chip row into the fixed section of the page layout, above the scrollable grid area
- [x] 2.3 Ensure filter state communication works between the fixed filter controls and the grid widget (lift state or use callbacks)

## 3. Wire up scroll and refresh

- [x] 3.1 Wrap the scrollable area (plant grid + task sections) in a `RefreshIndicator` and attach the existing `_scrollController`
- [x] 3.2 Verify pull-to-refresh works correctly on the scrollable area only

## 4. Verify empty and loading states

- [x] 4.1 Ensure the `_OnboardingEmptyState` still renders correctly when there are no plants
- [x] 4.2 Ensure `_buildLoadingState` and `_buildErrorState` still render correctly within the new layout structure
- [x] 4.3 Run `fvm flutter analyze` and fix any lint violations
