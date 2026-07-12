## Why

The three main tab pages (Today, Schedule, More) each use a different header treatment, creating visual inconsistency when switching between tabs:

| Page | Current Header | Alignment |
|------|---------------|-----------|
| Today | Inline `displayMedium` text | Left-aligned |
| Schedule | Material `AppBar` | Centered (via AppBar) |
| More | Inline `displayMedium` text | Left-aligned |

The Schedule page stands out with an elevated AppBar, while Today and More have left-aligned inline text. None match. All three should use a **consistent, centered** inline header pattern for a cohesive navigation experience across tabs.

## What Changes

- **Schedule page**: Replace the `AppBar` with a centered inline `displayMedium` title header
- **Today page**: Change the existing header from left-aligned to centered (`TextAlign.center`)
- **More page**: Change the existing header from left-aligned to centered (`TextAlign.center`)
- All three headers will share the same style: `displayMedium` text, centered, with consistent padding and placement inside the `SafeArea` body
- No functional changes — only UI alignment

## Capabilities

### New Capabilities

*(None — this is a visual consistency fix across existing pages, not introducing new capabilities.)*

### Modified Capabilities

*(None — no spec-level requirements are changing, only the visual presentation of page titles.)*

## Impact

- **3 files affected**:
  - `lib/pages/care_schedule/care_schedule_page.dart` — replace `AppBar` with inline centered header
  - `lib/pages/today_dashboard/today_dashboard_page.dart` — center the existing header
  - `lib/pages/more/more_page.dart` — center the existing header
- No API, data layer, or use-case changes
- No dependency changes
- No localization changes needed
