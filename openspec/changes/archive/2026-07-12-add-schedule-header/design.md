## Context

The three main tab pages (Today, Schedule, More) each display their title header differently, creating visual inconsistency across tabs. The user wants all three to share one consistent pattern with centered alignment.

Current state:

| Page | Mechanism | Alignment | Code Location |
|------|-----------|-----------|---------------|
| Today | `_buildHeader()` — `Padding > Text(displayMedium)` | Left (`EdgeInsets.only(left: 20)`) | `today_dashboard_page.dart:229` |
| Schedule | `Scaffold.appBar` with `AppBar(title: ...)` | Centered (AppBar default) | `care_schedule_page.dart:123` |
| More | `Padding > Text(displayMedium)` inline in `Column` | Left (`EdgeInsets.only(left: 20)`) | `more_page.dart:215` |

## Goals / Non-Goals

**Goals:**
- All 3 tab pages use the **same** header widget pattern
- All headers are **centered** (`TextAlign.center`)
- Maintain all existing functionality, scrolling, and animation behavior

**Non-Goals:**
- No changes to sub-pages (settings, about, species library, etc.) — those use standard `AppBar` which is the expected pattern for pushed routes
- No functional or data changes
- No localization changes
- No shared/reusable widget extraction (out of scope — keep changes minimal)

## Decisions

**Decision 1: Centered inline `displayMedium` header — all 3 pages**

The target pattern is:
```dart
Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
  child: Text(
    title,
    style: theme.textTheme.displayMedium,
    textAlign: TextAlign.center,
  ),
)
```

This replaces the current header mechanism on each page:

1. **Today** (`today_dashboard_page.dart:229`): Add `textAlign: TextAlign.center` to the existing `Text`. The `_buildHeader` method signature and call site stay the same.

2. **More** (`more_page.dart:215`): Add `textAlign: TextAlign.center` to the existing inline `Text`. No structural change.

3. **Schedule** (`care_schedule_page.dart:123`): Remove `Scaffold.appBar`. Add the inline header as the first child of the `Column` in `_buildContent` — before `_buildFilters`. The existing `_buildContent` already returns a `Column`, so the change is minimal.

**Decision 2: `EdgeInsets.symmetric(horizontal: 20, vertical: 10)`**

Using `EdgeInsets.symmetric` simplifies the current `EdgeInsets.only(left: 20, right: 20, top: 10)` — behavior is identical, just more concise.

**Decision 3: No shared widget extracted**

Creating a shared `PageHeader` widget would be the cleanest long-term approach but adds unnecessary complexity for such a small, contained change. If the pattern needs to be reused elsewhere later, extraction is a trivial refactor.

## Risks / Trade-offs

- **Schedule page layout shift**: Removing the `AppBar` shifts content ~56px upward. This is the desired visual alignment, but `_buildFilters` needs to still stack correctly below the new inline header. The existing `Column` layout in `_buildContent` already handles this — the header just becomes a new first child.
- **Today page `_buildHeader` reuse**: The `_buildHeader` method is also called in `_buildLoadingState` (line 414) and `_buildBody`. Both call sites will inherit the centered alignment automatically since the method body is the only thing changing.
- **KeepAlive compatibility**: All 3 pages use `AutomaticKeepAliveClientMixin`. No widget key changes are needed, so KeepAlive behavior is preserved.
