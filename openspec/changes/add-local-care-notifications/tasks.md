## 1. Foundation and platform wiring

- [x] 1.1 Add `flutter_local_notifications`, `timezone`, and `flutter_timezone` (or `flutter_native_timezone`) dependencies compatible with Flutter 3.41.x, minSdk 26, iOS 13, and run `fvm flutter pub get`
- [x] 1.2 Configure Android: `POST_NOTIFICATIONS` (API 33+), `RECEIVE_BOOT_COMPLETED`, notification channel `care_reminders`, and boot receiver; configure iOS: `UNUserNotificationCenterDelegate`, foreground presentation, and permission strings; verify `fvm flutter analyze` passes for platform config
- [x] 1.3 Create notification module skeleton `lib/pages/notifications/` with datasource, repository, entity/payload helpers, and use cases following `Page → UseCase → Repository → DataSource`
- [x] 1.4 Initialize `timezone` data from device zone on startup and handle zone-change reconciliation hook

## 2. Global notification settings and permission service

- [x] 2.1 Extend `Settings` with `notificationsEnabled` master flag and `notifyDueTasks` / `notifyOverdueTasks` category flags, with additive `fromJson`/`toJson` defaults true and no migration for existing stored JSON
- [x] 2.2 Add failing unit tests for settings decode defaults, master-off cancellation, and per-category filtering
- [x] 2.3 Implement `SettingsController` persistence for new flags until settings tests pass
- [x] 2.4 Add notification permission helper (check/request/open OS settings) behind repository, with iOS `requestPermissions` and Android `POST_NOTIFICATIONS` handling

## 3. Scheduling, reconciliation, and lifecycle

- [x] 3.1 Add failing unit tests for next-occurrence computation from `reminderTime`/`reminderDays` + interval + schedule anchor, stable integer ID mapping, and stale-cancel behavior
- [x] 3.2 Implement `NotificationRepository` ID mapping, payload encoding (`plantId`/`ruleId`/taskType), and `zonedSchedule`/`cancel` calls using one stable channel
- [x] 3.3 Implement `NotificationUsecases.reconcileAll()` that reads plants/rules/settings/schedule, applies global toggles and permission state, computes next occurrence per eligible rule, schedules or updates, and cancels stale requests
- [x] 3.4 Wire startup reconciliation after `SettingsController.load()` and `init()` in `lib/main.dart`; wire Android boot restoration via plugin receiver and verify no always-running background service is introduced
- [~] 3.5 Wire reconciliation triggers into care-rule mutations, care-task completion/snooze/skip, plant deletion cleanup, schedule-config changes, global setting toggles, and time-zone/DST change handling

## 4. Notification settings UI and routing

- [ ] 4.1 Add failing widget tests for notification settings page: master toggle, category toggles, permission state, request/open-settings affordances, and `l10n` keys
- [ ] 4.2 Implement notification settings page reachable from app settings/More, bound to `SettingsController` and permission status, with localized copy and accessible labels
- [ ] 4.3 Add notification tap handler that opens care schedule and focuses the referenced plant/task when payload present; gracefully falls back when plant/rule no longer exists
- [ ] 4.4 Register notification tap callback during plugin initialization and handle both foreground and terminated-launch delivery

## 5. Firebase removal and privacy hardening

- [ ] 5.1 Remove or guard `FirebaseApp.configure()` from `ios/Runner/AppDelegate.swift` and verify no Firebase dependency remains required for reminders
- [ ] 5.2 Verify app builds and notifications schedule without network access; remove any leftover Firebase-related iOS pod or config if present

## 6. Localization and theming

- [ ] 6.1 Add English and German ARB keys for notification titles, bodies, settings labels, permission guidance, and status messages
- [ ] 6.2 Run `fvm flutter gen-l10n` and replace any new literals with generated accessors; verify no hard-coded user-facing strings remain for notification surfaces

## 7. Wiring and integration

- [ ] 7.1 Register notification datasource/repository/usecases in `lib/core/injection.dart` and expose through `lib/core/app_services.dart` behind `AppScope`
- [ ] 7.2 Verify existing reminder UI on custom care rules continues to work and now drives real schedules via the new reconciliation path

## 8. Verification

- [ ] 8.1 Run focused notification, settings, care-rule, and schedule tests; add coverage for permission denied, master-off, category-off, invalid time/days, restart/reboot, and zone/DST cases
- [ ] 8.2 Run `fvm dart format --line-length=120 .`
- [ ] 8.3 Run `fvm flutter analyze` and stop/report before any corrective change if failures occur
- [ ] 8.4 Run `fvm flutter test` and stop/report before any corrective change if failures occur
- [ ] 8.5 Manually verify on Android: permission grant/deny, master and category toggles, rule create/edit/delete/disable/enable, mark done/snooze/skip, app restart, device reboot, time-zone change, DST transition, tap routing, offline delivery, and plant deletion
