## 1. Dashboard Data Entity

- [x] 1.1 Create `DashboardData` entity at `lib/pages/today_dashboard/today_dashboard_entity.dart` — a plain data class aggregating: `List<CareTask> dueToday`, `List<CareTask> overdue`, `List<PlantSummary> recentPlants`, and `int totalPlantCount`
- [x] 1.2 Create `CareTask` sub-entity with fields: plantName, taskType (enum: water/fertilize/mist/prune/rotate/repot/clean/inspect), dueDate, daysOverdue (int, 0 if not overdue)
- [x] 1.3 Create `PlantSummary` sub-entity with fields: id (String), name (String), photoPath (String?), updatedAt (DateTime)

## 2. Data Source & Repository

- [x] 2.1 Create `TodayDashboardDataSource` at `lib/pages/today_dashboard/today_dashboard_datasource.dart` — receives downstream use-cases via constructor injection; delegates plant queries to `PlantCollectionUsecases` and task queries to `CareScheduleUsecases` (nullable with graceful fallback when downstream is not wired)
- [x] 2.2 Implement `fetchDashboardData()` — orchestrates parallel calls to downstream data sources and composes into `DashboardData`, handling cases where downstream capabilities return empty or null
- [x] 2.3 Create `TodayDashboardRepository` at `lib/pages/today_dashboard/today_dashboard_repository.dart` — maps data source fetch to domain operations, no transformations needed (thin pass-through)

## 3. Business Logic — Use Cases

- [x] 3.1 Create `TodayDashboardUsecases` at `lib/pages/today_dashboard/today_dashboard_usecases.dart` with method `getDashboardData()` that calls `repository.fetchDashboardData()` and returns `DashboardData`
- [x] 3.2 Implement automatic empty-state detection — if `totalPlantCount == 0`, signal to UI that onboarding empty state should be shown instead of regular dashboard sections

## 4. Dependency Injection Wiring

- [x] 4.1 Re-register `TodayDashboardDataSource`, `TodayDashboardRepository`, `TodayDashboardUsecases` in `lib/core/injection.dart` — replace old placeholder registrations with new implementations; wire plant_collection and care_schedule use-cases as constructor dependencies (nullable via Optional/Maybe type)
- [x] 4.2 Update `AppServices.todayDashboard` type if `TodayDashboardUsecases` signature changed — ensure `AppScope` exposes the new use-cases

## 5. UI — Dashboard Sections

- [x] 5.1 Create `_QuickActionStrip` widget — horizontal row of three styled buttons (Add Plant, Identify, Diagnose) with icons and labels; tap handlers call navigation via `mainNavigatorKey`
- [x] 5.2 Create `_DueTasksSection` widget — renders a titled list of `CareTaskCard` widgets for tasks due today; hidden when empty
- [x] 5.3 Create `_OverdueTasksSection` widget — same card style with red urgency background, shows days overdue badge; hidden when empty
- [x] 5.4 Create `_RecentPlantsCarousel` widget — horizontal `ListView.builder` showing plant photo thumbnails and names; tap navigates to plant detail on plant_collection; hidden when empty
- [x] 5.5 Create `_OnboardingEmptyState` widget — centered column with illustration area, encouragement text, and "Add your first plant" CTA button

## 6. UI — Dashboard Page

- [x] 6.1 Rewrite `TodayDashboardPage` at `lib/pages/today_dashboard/today_dashboard_page.dart` — `StatefulWidget` with `AutomaticKeepAliveClientMixin`, fetches `DashboardData` in `initState`/on focus, renders `CustomScrollView` with sliver sections:
      - Quick action strip (non-scrolling header)
      - Onboarding empty state (when collection empty)
      - Due Today section
      - Overdue section
      - Recent Plants carousel
- [x] 6.2 Implement pull-to-refresh using `RefreshIndicator` wrapping the scroll view
- [x] 6.3 Add loading state — show shimmer/skeleton placeholders while dashboard data is being fetched

## 7. Navigation Integration

- [x] 7.1 Update `PageItemPresentation` for `PageItem.todayDashboard` in `lib/pages/home/page_navigator.dart` — change icon to `Icons.today` / `Icons.dashboard` with appropriate label from l10n
- [x] 7.2 Ensure `NavBarNavigator._routeBuilders()` case `PageItem.todayDashboard` routes to `TodayDashboardPage`

## 8. L10n & Cleanup

- [x] 8.1 Add l10n strings to asset ARB files: `todayDashboardTitle` (update to "Today"), `dueToday`, `overdue`, `recentPlants`, `noPlantsYet`, `addYourFirstPlant`, `quickAddPlant`, `quickIdentify`, `quickDiagnose`, `daysOverdue`, `taskDueToday`
- [x] 8.2 Run `fvm flutter gen-l10n` to regenerate localizations
- [x] 8.3 Remove old placeholder files: `lib/pages/today_dashboard/today_dashboard_item_entity.dart` (if unused) — no such file exists

## 9. Verification

- [x] 9.1 Run `fvm flutter analyze` and resolve any lint issues (especially `always_use_package_imports`, `prefer_const_constructors`, `require_trailing_commas`)
- [x] 9.2 Run `fvm flutter test` to verify existing tests still pass
- [ ] 9.3 Manual smoke test: verify dashboard loads with empty state when no plants, verify quick actions navigate correctly, verify sections appear/hide based on data availability
