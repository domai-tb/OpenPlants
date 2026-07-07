# Scrollable Navigation Bar

## Purpose

Bottom navigation bar that scrolls horizontally to accommodate many pages, centering the active item and maintaining uniform spacing.

## Requirements

### Requirement: Scrollable navigation bar
The bottom navigation bar SHALL be horizontally scrollable when items overflow the available width. The active page item SHALL be centered in the visible area of the bar.

#### Scenario: Bar scrolls to center active item on selection
- **WHEN** the user taps a page item that is not currently centered
- **THEN** the bar scrolls horizontally to bring the selected item to the center of the visible area

#### Scenario: Bar scrolls to center active item on build
- **WHEN** the navigation bar is first rendered with an active page
- **THEN** the active page item is centered in the visible area

#### Scenario: Manual swipe reveals hidden items
- **WHEN** the user swipes horizontally on the navigation bar
- **THEN** the bar scrolls to reveal additional page items that were off-screen

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
