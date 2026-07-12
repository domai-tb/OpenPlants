## Context

OpenPlant currently uses a monochrome palette (black primary in light mode, white primary in dark mode) with a blue accent (#3171EC) as the secondary color in dark mode. The theme definition in `lib/core/themes.dart` is minimal — it sets only `primary`, `secondary`, `surface` (dark only), `error`, and `cardColor`. All other Material 3 color slots (`primaryContainer`, `onPrimary`, `onSurface`, `surfaceVariant`, `outline`, `tertiary`, etc.) are left to Material defaults, which silently derive them from `primary` (black → grey tones, white → light tones).

Seven widget files hardcode specific `Color.fromRGBO()` values instead of using `Theme.of(context)` lookups. These hardcoded values (#F5F6FA, #222836, #B8BABF, etc.) appear 20+ times across the widget layer. The `brightness == Brightness.light` pattern is used in every widget to choose between hardcoded light/dark color pairs.

The result: changing the primary palette requires editing the theme AND all 7+ widget files separately. Some widget color choices may not align with the active theme at all, creating invisible-text bugs when a widget's hardcoded color doesn't contrast with the dynamic theme background.

## Goals / Non-Goals

**Goals:**
- Replace the blue accent with a green-based palette appropriate for a plant companion app
- Define all Material 3 color slots explicitly for both light and dark modes, ensuring predictable contrast
- Migrate all hardcoded widget colors to `Theme.of(context)` lookups so every element respects the active theme
- Remove the `brightness == Brightness.light` branching pattern in favor of semantic theme tokens
- Eliminate invisible-text contrast bugs across all existing pages

**Non-Goals:**
- No custom fonts or typography overhaul (text sizes/families stay as-is unless a contrast fix requires a color change)
- No page layout or structural changes — this is purely a visual/theme refactor
- No new widget system or design system components beyond the theme layer
- No changes to the care-status color semantics (green=healthy, orange=needs fertilizer, blue=needs water, red=attention) — these are semantic, not decorative

## Decisions

### Decision 1: Green seed color with Material 3 auto-generation via `ColorScheme.fromSeed`

**Choice:** Use `ColorScheme.fromSeed(seedColor: Color(0xFF2E7D32), brightness: ...)` for both light and dark modes, then override specific slots explicitly.

**Rationale:**
- `fromSeed` generates a full, harmonious 13-slot color scheme from a single seed, including `primaryContainer`, `onPrimary`, `primaryFixed`, `onPrimaryFixed`, `secondary`, `tertiary`, `surface`, `onSurface`, `surfaceVariant`, `outline`, etc.
- This gives us a cohesive green palette with complementary tones automatically.
- We then override specific slots (e.g., `surface` for dark mode, `secondary` for a complementary accent) where we need exact control.
- Compared to manually specifying every slot (error-prone, tedious) or keeping the current sparse definition (leaves contrast to chance), `fromSeed` is the right balance of control and automation.

**Seed color chosen:** `#2E7D32` (Material Green 800) — a rich, natural green that works as a primary for both light and dark themes. It's dark enough for light mode primary to be legible on white surfaces, and when inverted for dark mode the generated light-green tones provide good contrast on dark surfaces.

### Decision 2: Secondary color — complementary warm-green accent

**Choice:** Use the `fromSeed`-generated secondary rather than forcing a specific hue. For the green seed `#2E7D32`, `fromSeed` generates a warm-teal secondary that complements the primary green.

**Rationale:** The current secondary (#3171EC blue / #15003E dark purple) served as the accent — but in a green-based scheme, a warm secondary (teal/amber-leaning) looks more natural with green than blue would. The `fromSeed` algorithm picks this well for a green seed. We keep the generated value rather than forcing an unrelated hue.

**Override needed:** For dark mode specifically, we ensure the `onSecondary` and `secondaryContainer` slots have sufficient contrast (WCAG AA ≥ 4.5:1) against the dark surface.

### Decision 3: Explicit surface colors for dark mode

**Choice:** Keep the current dark surface (#0E1420) and card (#111926) values but wire them through `ColorScheme.dark(surface:, surfaceContainerHighest:, onSurface:)` instead of leaving them to defaults.

**Rationale:** These specific dark tones are already used across 7+ widget files and system UI overlay styles. Baking them into the `ColorScheme` means widgets can use `colorScheme.surfaceContainerHighest` or `colorScheme.surface` instead of hardcoding `#111926` and `#222836`. This eliminates the hardcoding cascade.

### Decision 4: Widget color migration strategy — semantic token mapping

**Choice:** For each hardcoded color in widget files, map it to the closest Material 3 color scheme token.

| Hardcoded Color | Usage | M3 Token |
|---|---|---|
| `#F5F6FA` (light widget bg) | Search bar bg, button bg, segmented control inactive, side nav bg | `colorScheme.surfaceContainerLow` or `colorScheme.surfaceVariant` |
| `#222836` (dark widget bg) | Dark mode variant of above | `colorScheme.surfaceContainerLow` (auto-resolves in dark) or `colorScheme.surfaceVariant` |
| `#B8BABF` (dark text/icon) | Dark mode secondary text, inactive icons | `colorScheme.onSurfaceVariant` |
| `Colors.black` (light text) | Light mode primary text | `colorScheme.onSurface` |
| `Colors.white` (light cards) | Cards, status bar | `colorScheme.surface` |
| `Colors.black12` shadow | Bottom nav / segmented control shadows | `Theme.of(context).shadowColor` or `colorScheme.shadow` |

**Rationale:** This mapping means the 7+ widget files can drop their `brightness == Brightness.light` branching entirely. Each color is resolved from the active `ThemeData`'s color scheme, which already reflects the current brightness. This is the key fix for contrast bugs — when a widget defers to the theme, it can never pick a color that clashes with the theme background.

### Decision 5: Text theme — keep structure, fix colors

**Choice:** Preserve all text style sizes, weights, and letter spacing from the current definition. Only update the `bodyMedium` and `labelMedium` color assignments to use color scheme tokens.

**Rationale:** The current font sizes and weights were chosen intentionally per the AGENTS.md guidelines. Changing them would require re-layout testing. The only contrast bugs come from color, not sizing. We change:
- Light `bodyMedium` color from `#818181` → `colorScheme.onSurfaceVariant` (still muted, but respects contrast)
- Dark `bodyMedium` / `labelMedium` color from `#B8BABF` → `colorScheme.onSurfaceVariant` (dynamically resolves)

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| **fromSeed may generate unexpected secondary/tertiary colors** | Preview the full scheme in a test before committing. If a generated slot has low contrast, override it explicitly in `themes.dart`. |
| **Widget migration misses a spot** | After migration, run visual regression: manually check every page in light and dark mode for invisible text. The affected files list is known (7 widgets + home_page + nav files), so we can verify them one by one. |
| **Care-status semantic colors (green/blue/orange/red) blend with new green theme** | These are semantic status indicators, not decorative. We keep them as explicit named colors (`Colors.green`, `Colors.blue`, etc.). Only the blue "needs water" might visually blend less with the new green theme — but that's acceptable since the status label + icon differentiate it. |
| **Existing archived changes that reference old theme** | Archived changes are historical. No migration needed — they reflect the state at the time. |
| **Text contrast changes subtly for existing users** | The old body text colors (`#818181` light, `#B8BABF` dark) were already low contrast. Moving to `onSurfaceVariant` will actually improve contrast in dark mode. Light mode `onSurfaceVariant` may be slightly darker (more legible) than `#818181`. This is strictly better for accessibility. |
