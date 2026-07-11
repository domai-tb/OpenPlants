## Why

The plant identification page is displayed as a modal bottom sheet with no close button, AppBar, or any visible way to return to the dashboard. Users who reach the result screen have no discoverable way to dismiss the modal — swipe-down gesture is the only escape, and it is not obvious. This creates a dead-end UX where users feel stuck.

## What Changes

- Add a close (X) icon button at the top-right of the plant identification page, visible in all states (idle, identifying, result, error)
- The close button calls `Navigator.of(context).pop()` to dismiss the modal and return to the dashboard
- No other navigation changes — the existing "Retake" and "View Details" buttons remain functional

## Capabilities

### New Capabilities

No new capabilities — this is a UX improvement to an existing page, not a new feature.

### Modified Capabilities

No existing specs have requirement changes. The identification UI behavior changes (close button added) but the underlying capability of identifying plants is unchanged.

## Impact

| Area | Impact |
|---|---|
| `lib/pages/plant_identification/plant_identification_page.dart` | Add close button in the Scaffold's header area; wrap title row with a Row containing title + close button |
| No new dependencies | No packages added or removed |
| No API changes | No datasource, repository, or usecase changes |
