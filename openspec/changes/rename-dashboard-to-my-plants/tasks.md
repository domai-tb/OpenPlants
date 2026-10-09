## 1. Dashboard task-section removal

- [ ] 1.1 Remove `_DueTasksSection` and `_OverdueTasksSection` usage from `today_dashboard_page.dart`, keep `PlantGridSection` as sole content
- [ ] 1.2 Simplify `TodayDashboardUsecases.getDashboardData()` / `DashboardData` to plants-only; grep callers first
- [ ] 1.3 Delete now-unused task-section widgets and imports

## 2. Rename to My Plants

- [ ] 2.1 Rename l10n key `todayDashboardTitle` → `myPlantsTitle` ("My Plants") in `l10n_en.arb` and all locale ARBs
- [ ] 2.2 Update `page_navigator.dart` nav label and `today_dashboard_page.dart` header to new key
- [ ] 2.3 Run `fvm flutter gen-l10n` and `rg todayDashboardTitle` to confirm zero stragglers

## 3. Verify

- [ ] 3.1 `fvm flutter analyze` clean
- [ ] 3.2 `fvm flutter test` passes; dashboard with due/overdue tasks shows grid only, Care Schedule still shows all four sections
- [ ] 3.3 `openspec validate --change rename-dashboard-to-my-plants --strict` passes
