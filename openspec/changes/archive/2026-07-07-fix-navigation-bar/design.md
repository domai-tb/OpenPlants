## Context

The bottom navigation bar (`BottomNavBar`) currently uses a `Row` with `MainAxisAlignment.spaceEvenly` inside a `SingleChildScrollView` with `NeverScrollableScrollPhysics`. This layout doesn't handle overflow well when many pages are visible (up to 9 possible tabs). Additionally, each `PageItem` has custom `iconPaddingLeft`/`iconPaddingRight` values that create asymmetric spacing.

The current architecture:
- `BottomNavBar` → `Row` of `BottomNavBarItem` widgets
- `BottomNavBarItem` → `Column` with icon + animated label
- Items use per-item padding overrides (`iconPaddingLeft`, `iconPaddingRight`)

## Goals / Non-Goals

**Goals:**
- Make the navigation bar horizontally scrollable when items overflow
- Center the active item in the visible area
- Remove per-item asymmetric padding for uniform spacing
- Preserve existing active-item animation (slide up + label fade)
- Maintain the same widget API (`BottomNavBar(currentPage, pages, onSelectedPage)`)

**Non-Goals:**
- Changing the tablet `SideNavBar` layout
- Adding new navigation features (e.g., badges, indicators)
- Changing the `PageItem` enum or page routing logic

## Decisions

### Decision 1: Use `PageView` for scrollable centering

**Choice**: Replace `Row` + `SingleChildScrollView` with a `PageView.builder` that snaps to items.

**Why**: `PageView` naturally handles:
- Horizontal scrolling with snap-to-item behavior
- Centering the current page in the viewport
- Efficient rendering of off-screen items via lazy building

**Alternatives considered**:
- `ListView.builder` + `ScrollController.animateTo`: Requires manual scroll-to-center logic and doesn't snap cleanly
- `SingleChildScrollView` + `Row` + `ScrollController`: Same manual scroll problem, no snap

### Decision 2: Fixed-width items with `PageView`

**Choice**: Each `BottomNavBarItem` gets a fixed width (e.g., 64-72px) so `PageView` can calculate page offsets precisely.

**Why**: Fixed widths let `PageView` center items mathematically. Variable-width items would require custom `PageController` physics.

### Decision 3: Remove per-item padding overrides

**Choice**: Remove `iconPaddingLeft`/`iconPaddingRight` from `PageItemPresentation` and `BottomNavBarItem`. Use uniform padding instead.

**Why**: Uniform spacing is required for symmetrical centering. The per-item padding was a workaround for visual alignment that the scrollable layout solves naturally.

### Decision 4: Keep `NeverScrollableScrollPhysics` approach for tablet

**Choice**: The `BottomNavBar` widget stays phone-only. Tablet uses `SideNavBar` unchanged.

**Why**: No scope creep. The overflow problem only manifests on phones with many visible tabs.

## Risks / Trade-offs

- **[Risk] PageView snap feel** → Use `PageScrollPhysics` for natural snap behavior. Tune `viewportFraction` if needed to show partial adjacent items.
- **[Risk] Animation disruption** → The slide-up animation in `BottomNavBarItem` must work within `PageView`'s layout. Test that `AnimatedPadding` still functions correctly inside `PageView` children.
- **[Trade-off] Partial item visibility** → `PageView` may show partial adjacent items (like iOS tab bar). This is desirable for discoverability but changes the visual from the current "all items visible" layout.

## Migration Plan

1. Modify `BottomNavBar` to use `PageView.builder` instead of `Row`
2. Update `BottomNavBarItem` to accept a fixed width parameter
3. Remove `iconPaddingLeft`/`iconPaddingRight` from `PageItemPresentation`
4. Remove `iconPaddingLeft`/`iconPaddingRight` from `BottomNavBarItem`
5. Update `pageItemPresentation()` to stop setting custom padding
6. Test with maximum visible pages (9) to verify no overflow
7. Test with minimum visible pages (3) to verify centering still works

## Open Questions

- Should adjacent items be partially visible (iOS-style) or hidden completely? → Recommend partial visibility for discoverability.
- What `viewportFraction` value works best? → Start with `0.2` (showing ~5 items) and adjust.
