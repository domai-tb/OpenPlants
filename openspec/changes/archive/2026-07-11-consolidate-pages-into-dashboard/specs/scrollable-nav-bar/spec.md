## REMOVED Requirements

### Requirement: Scrollable navigation bar
**Reason**: With the reduction from 6 to 3 navigation items (Dashboard, Care, More), the nav bar no longer overflows on any phone width. Horizontal scrolling is no longer needed. The nav bar items fit without scrolling on all supported screen widths.

**Migration**: Remove the scrollable nav bar behavior. The `BottomNavBar` widget renders 3 fixed items with uniform spacing. The `ScrollController`, scroll physics, and centering logic associated with the scrollable bar are removed. The `ScrollableNavBar` widget is replaced with a simpler fixed-layout nav bar.

### Requirement: Active item animation preserved
**Reason**: The active item animation (vertical slide-up, label fade-in) behavior is unchanged. This requirement is preserved in the new nav bar implementation, not removed.

**Migration**: The animation behavior is preserved. The fixed 3-item nav bar SHALL retain the existing slide-up and fade-in animation for the active item.

## MODIFIED Requirements

### Requirement: Symmetrical item spacing
All page items in the navigation bar SHALL have uniform horizontal spacing. With 3 items, the spacing SHALL distribute items evenly across the available width. Each item SHALL occupy equal width.

#### Scenario: Uniform spacing with 3 items
- **WHEN** the navigation bar renders with Dashboard, Care, and More
- **THEN** each item has identical spacing and the items are distributed evenly

### Requirement: Active item animation preserved
The active page item SHALL retain its existing animation behavior: vertical slide-up and label fade-in when selected.

#### Scenario: Active item animates on selection
- **WHEN** the user taps a page item
- **THEN** the item slides up vertically and its label fades in, matching current behavior
