## 1. Core Theme Definition

- [ ] 1.1 Add green seed color constant and generate full Material 3 color scheme in `lib/core/themes.dart` using `ColorScheme.fromSeed(seedColor: Color(0xFF2E7D32))` for both light and dark modes
- [ ] 1.2 Define all explicit M3 color slots in light theme: `primary`, `onPrimary`, `primaryContainer`, `onPrimaryContainer`, `secondary`, `onSecondary`, `secondaryContainer`, `onSecondaryContainer`, `tertiary`, `onTertiary`, `surface`, `onSurface`, `surfaceVariant`, `onSurfaceVariant`, `surfaceContainerLow`, `surfaceContainerHighest`, `error`, `onError`, `errorContainer`, `onErrorContainer`, `outline`, `outlineVariant`, `shadow`
- [ ] 1.3 Define all explicit M3 color slots in dark theme with surface colors (#0E1420 surface, #111926 card) and light-green primary derived from seed
- [ ] 1.4 Update text theme colors to use `onSurfaceVariant` instead of hardcoded `#818181` (light) and `#B8BABF` (dark)
- [ ] 1.5 Run `fvm flutter analyze` to verify no theme-related compilation errors

## 2. Widget Hardcoded Color Migration

- [ ] 2.1 **`app_button.dart`**: Replace `Color.fromRGBO(245, 246, 250, 1)` (light bg) with `colorScheme.surfaceVariant`, replace `Color.fromRGBO(34, 40, 54, 1)` (dark bg) with `colorScheme.surfaceVariant`, replace inline text colors with theme text style, remove `isLight` branching
- [ ] 2.2 **`app_icon_button.dart`**: Replace `Color.fromRGBO(245, 246, 250, 1)` with `colorScheme.surfaceVariant`, replace `Color.fromRGBO(34, 40, 54, 1)` with `colorScheme.surfaceVariant`, replace icon color (`Colors.black` / `Color.fromRGBO(184, 186, 191, 1)`) with `colorScheme.onSurfaceVariant`, remove `isLight` branching
- [ ] 2.3 **`app_search_bar.dart`**: Replace container background color branch with `colorScheme.surfaceVariant`, replace icon button background colors, replace text color branch, remove `isLight` branching
- [ ] 2.4 **`app_segmented_triple_control.dart`**: Replace background colors (`#F5F6FA` / `surface`) with `colorScheme.surfaceVariant`, replace selection indicator color (`Colors.white` / `#222836`) with `colorScheme.surface`, replace `Colors.black12` shadow with `colorScheme.shadow`, replace text colors with theme text style, remove `isLight` branching
- [ ] 2.5 **`scroll_to_top_button.dart`**: Replace icon color (`Colors.black` / `#B8BABF`) with `colorScheme.onSurfaceVariant`, remove `isLight` branching

## 3. Error Message Fix

- [ ] 3.1 **`error_message.dart`**: Replace `Colors.redAccent` icon with `colorScheme.error`, replace `Colors.white` text with `colorScheme.onErrorContainer`, wrap in a Container with `colorScheme.errorContainer` background to ensure text always has a contrasting backdrop

## 4. Navigation Bar Theme Colors

- [ ] 4.1 **`bottom_nav_bar_item.dart`**: Replace inactive icon color (`Colors.black` / `#B8BABF`) with `colorScheme.onSurfaceVariant`, remove `isLight` branching
- [ ] 4.2 **`side_nav_bar_item.dart`**: Replace inactive icon color (`Colors.black` / `#B8BABF`) with `colorScheme.onSurfaceVariant`, remove `isLight` branching
- [ ] 4.3 **`side_nav_bar.dart`**: Replace background color (`#F5F6FA` / `cardColor`) with `colorScheme.surfaceVariant` for light, replace `isLight` branching
- [ ] 4.4 **`bottom_nav_bar.dart`**: Replace `Colors.black12` shadow with `colorScheme.shadow`

## 5. System UI Overlay Styles

- [ ] 5.1 **`home_page.dart`**: Update `lightSystemUiStyle` status bar / nav bar colors from `Colors.white` and `#F5F6FA` to the new green-appropriate light surface colors from the color scheme
- [ ] 5.2 **`home_page.dart`**: Update `darkSystemUiStyle` / `darkTabletSystemUiStyle` to use the new dark surface colors derived from the color scheme

## 6. Verification

- [ ] 6.1 Run `fvm flutter analyze` and fix any lint issues (ensure `always_use_package_imports`, `prefer_const_constructors`, `require_trailing_commas`, and all other lint rules pass)
- [ ] 6.2 Launch app on emulator and visually verify every page in light mode — no invisible text, green palette is applied correctly
- [ ] 6.3 Switch to dark mode and visually verify every page — no invisible text, all text legible
- [ ] 6.4 Switch theme mode through all three states (System → Light → Dark) without restart and verify no contrast regressions
