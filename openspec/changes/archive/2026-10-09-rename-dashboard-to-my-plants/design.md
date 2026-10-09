## Context

See proposal.md Why. Current `TodayDashboardPage` mixes plant grid (`PlantGridSection`) with `_DueTasksSection` / `_OverdueTasksSection` fed by `TodayDashboardUsecases.getDashboardData()` (care schedule engine). Nav label and header both use `todayDashboardTitle` ("Today"). Care Schedule page already owns full task grouping.

## Goals / Non-Goals

**Goals:**
- Dashboard renders plant grid only, titled "My Plants".
- Zero task queries on dashboard path.
- l10n rename across locales without breaking other keys.

**Non-Goals:**
- No changes to care scheduling logic, notifications, or task completion flow.
- No new navigation structure; same 3 tabs.
- No visual redesign of plant grid.

## Decisions

- Delete `_DueTasksSection` / `_OverdueTasksSection` widgets and their call sites; keep `PlantGridSection` as sole sliver content. Alternative (hide behind flag): rejected, leaves dead query path.
- Simplify dashboard data load to plants only; shrink `DashboardData` / usecase if no other caller needs task fields. Alternative (leave usecase intact): rejected, keeps unused engine dependency.
- Rename via l10n value change (`todayDashboardTitle` → "My Plants") plus key rename to `myPlantsTitle` with old key removed, updated in `page_navigator.dart` and `today_dashboard_page.dart`. Alternative (value-only change): keeps misleading `today*` key name; key rename costs one extra ARB pass but matches Clean Architecture naming.
- Regenerate with `fvm flutter gen-l10n` and update all locale ARBs in same change to avoid missing-key fallback.

## Risks / Trade-offs

- [Risk] Other callers depend on `DashboardData.dueToday/overdue` → Mitigation: grep callers before shrinking; keep fields deprecated one release if shared.
- [Risk] Stale `todayDashboardTitle` key referenced in tests/golden → Mitigation: `rg todayDashboardTitle` across repo, update all.
- [Risk] Users miss tasks after removal → Mitigation: Care Schedule tab already surfaces them; no redirect banner (keeps diff minimal).

## Migration Plan

- Single release: land code + l10n + specs together. Rollback: revert commit; no data migration involved.

## Open Questions

- None.
