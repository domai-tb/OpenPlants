## Context

The plant identification page is opened via `showModalBottomSheet` from the dashboard. Unlike the diagnosis flow (which has AppBars with close (X) buttons on both the form and result pages), the identification page has no AppBar, no back button, and no explicit close control. The only way to dismiss the modal is:

1. Swiping down on the sheet (not discoverable)
2. Tapping outside the sheet (not always possible — sheets can be full-screen via `isScrollControlled: true`)
3. Android hardware back button (inconsistent with modal bottom sheets)

The result screen doubles this problem: once users see their identification results, there is no button labeled "Close", "Done", or "Back to Dashboard" — only "Retake" (restart) and "View Details" (push a species detail page).

## Goals / Non-Goals

**Goals:**
- Add a close (X) button visible in every state of the identification page (idle, identifying, result, error)
- The button MUST call `Navigator.of(context).pop()` to dismiss the modal
- Maintain all existing functionality (Retake, View Details, camera/gallery capture)

**Non-Goals:**
- No change to the dashboard or any other page
- No change to the navigation architecture or routing
- No change to the species detail page or any other flow
- No change to the diagnosis pages (they already have close buttons)

## Decisions

### Decision 1: Close button placement — top-right of the title row

**Choice:** Add the close button as an `IconButton` with `Icons.close` aligned to the right end of the existing title row, replacing the current standalone `Text` widget with a `Row` containing the title + Spacer + close button.

**Rationale:**
- Consistent with the existing header pattern (the diagnosis page puts its X in the AppBar's leading position)
- Visible in all states since it's part of the Scaffold's body column, not inside the state-specific content
- A close icon is universally recognized for dismissing modals
- Adding a `Row` wrapper is the minimal structural change — it doesn't require converting the title to an AppBar

### Decision 2: Close button visibility — always visible

**Choice:** The close button is always rendered, regardless of the current identification state.

**Rationale:** The user might want to cancel at any point — while idle (decided not to take a photo), while identifying (changed their mind), or on the result screen (finished reviewing). There's no scenario where blocking the close action is beneficial.

### Decision 3: No confirmation dialog on close

**Choice:** Tapping X immediately pops the modal without a confirmation dialog.

**Rationale:** The identification process has no side effects (it doesn't save data to the user's collection). Closing and restarting is cheap. Adding a confirmation would be friction without benefit.

## Risks / Trade-offs

| Risk | Mitigation |
|---|---|
| **Close button overlaps with title on small screens** | The `Row` with `Spacer()` handles overflow naturally. Both title and button are in the same row with 20px horizontal padding. |
| **User accidentally closes mid-identification** | Classification takes ~1-2 seconds. If they close, they can simply re-open from the dashboard. No data loss. |
