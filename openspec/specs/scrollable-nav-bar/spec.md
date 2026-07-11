# Navigation Bar

## Purpose

Bottom navigation bar with fixed item positions and uniform spacing, maintaining active item animation.

## Requirements

### Requirement: Symmetrical item spacing
All page items in the navigation bar SHALL have uniform horizontal spacing. No item SHALL have custom left/right padding that differs from other items.

#### Scenario: Uniform spacing between all items
- **WHEN** the navigation bar renders with multiple visible pages
- **THEN** each item has identical horizontal spacing between neighbors

### Requirement: Active item animation preserved
The active page item SHALL retain its existing animation behavior: vertical slide-up and label fade-in when selected.

#### Scenario: Active item animates on selection
- **WHEN** the user taps a page item
- **THEN** the item slides up vertically and its label fades in, matching current behavior
