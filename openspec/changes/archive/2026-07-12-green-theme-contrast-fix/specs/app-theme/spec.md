## ADDED Requirements

### Requirement: Green-based color palette
The app SHALL use a green-based primary color scheme across all themes. The seed color SHALL be `Color(0xFF2E7D32)` (Material Green 800) or another green tone that generates a harmonious light and dark color scheme via Material 3's `ColorScheme.fromSeed`.

#### Scenario: Light theme uses green primary
- **WHEN** the app renders in light mode
- **THEN** the primary color SHALL be a green tone derived from the seed color (e.g., Green 600-700 range)
- **AND** the color scheme SHALL provide sufficient contrast (WCAG AA ≥ 4.5:1) between `onPrimary` and `primary`

#### Scenario: Dark theme uses green-toned primary
- **WHEN** the app renders in dark mode
- **THEN** the primary color SHALL be a light green tone (e.g., Green 200-300 range) derived from the seed color
- **AND** the color scheme SHALL provide sufficient contrast (WCAG AA ≥ 4.5:1) between `onPrimary` and `primary`

### Requirement: Explicit Material 3 color slots
The app SHALL define all critical Material 3 color scheme slots explicitly for both light and dark modes, rather than relying on defaults. At minimum, the following slots MUST be defined:
- `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`
- `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`
- `tertiary`, `onTertiary`
- `surface`, `onSurface`, `surfaceVariant`, `onSurfaceVariant`
- `surfaceContainerLow`, `surfaceContainerHighest`
- `error`, `onError`, `errorContainer`, `onErrorContainer`
- `outline`, `outlineVariant`
- `shadow`

#### Scenario: All color slots resolve in light mode
- **WHEN** the light theme is active
- **THEN** accessing `Theme.of(context).colorScheme.{slot}` for every slot listed above SHALL return a non-null Color value

#### Scenario: All color slots resolve in dark mode
- **WHEN** the dark theme is active
- **THEN** accessing `Theme.of(context).colorScheme.{slot}` for every slot listed above SHALL return a non-null Color value

### Requirement: Widget colors use theme tokens
All widget files SHALL reference color values through `Theme.of(context)` or `colorScheme` lookups rather than using hardcoded `Color.fromRGBO(...)` literals for surface, text, and icon colors.

#### Scenario: Widget surfaces respect theme
- **WHEN** a widget renders a background or surface area
- **THEN** it SHALL use `colorScheme.surface`, `colorScheme.surfaceVariant`, or `colorScheme.surfaceContainerLow` instead of a hardcoded color literal
- **AND** the widget SHALL render correctly in both light and dark modes without brightness branching

#### Scenario: Widget text colors respect theme
- **WHEN** a widget renders text
- **THEN** it SHALL use `colorScheme.onSurface`, `colorScheme.onSurfaceVariant`, or a text theme style rather than a hardcoded color literal
- **AND** the text SHALL remain legible (≥ 4.5:1 contrast ratio against its background) in both light and dark modes

### Requirement: Navigation icon colors use theme tokens
The bottom navigation bar and side navigation bar SHALL use theme color scheme tokens for active and inactive icon colors instead of hardcoded values.

#### Scenario: Active nav icon is themed
- **WHEN** a nav item is selected
- **THEN** its icon color SHALL be `colorScheme.primary` (or a defined active token)
- **AND** the color SHALL be visible against the nav bar background in both light and dark modes

#### Scenario: Inactive nav icon is themed
- **WHEN** a nav item is not selected
- **THEN** its icon color SHALL be `colorScheme.onSurfaceVariant`
- **AND** the color SHALL be visibly dimmer than the active icon while remaining legible

### Requirement: Error messages use theme-aware colors
The error message widget SHALL use theme-aware colors for its icon and text instead of hardcoded `Colors.redAccent` and `Colors.white`.

#### Scenario: Error icon uses theme error color
- **WHEN** an error message is displayed
- **THEN** the error icon SHALL use `colorScheme.error`
- **AND** it SHALL be visible against the error container background

#### Scenario: Error text uses on-error color
- **WHEN** an error message is displayed
- **THEN** the error text SHALL use `colorScheme.onError` or `colorScheme.onErrorContainer`
- **AND** the text SHALL remain legible in both light and dark modes

### Requirement: Light and dark mode switching preserves readability
All pages and widgets SHALL respond correctly to live theme switching (System → Light → Dark) without requiring a restart. Every text-on-surface combination SHALL maintain WCAG AA contrast ratio (≥ 4.5:1 for normal text, ≥ 3:1 for large text).

#### Scenario: Switch from light to dark preserves legibility
- **WHEN** the user switches theme mode from Light to Dark
- **THEN** all visible text in the current view SHALL remain readable
- **AND** no text SHALL visually blend into its background

#### Scenario: Switch from dark to light preserves legibility
- **WHEN** the user switches theme mode from Dark to Light
- **THEN** all visible text in the current view SHALL remain readable
- **AND** no text SHALL visually blend into its background
