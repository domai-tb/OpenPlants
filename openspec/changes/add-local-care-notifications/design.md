## Context

See `proposal.md` for motivation. OpenPlants uses feature-local Clean Architecture (`Page → UseCase → Repository → DataSource`), GetIt wiring exposed through `AppScope`, JSON collections in `SharedPreferences`, and a pure schedule engine that computes due dates from completions, custom rules, room and pot modifiers, and snooze/skip actions. Existing reminder fields already exist on `CustomCareRuleEntity` but have no delivery. Android is the operational target (minSdk 26); iOS is maintained but not actively tested. Privacy model forbids Firebase, accounts, and network services for reminders.

## Goals / Non-Goals

**Goals:**

- Deliver on-device reminders for due/overdue care without network services or an always-running background service.
- Reuse existing reminder configuration and schedule computation rather than create a second reminder system.
- Make scheduling deterministic and testable, with global category filters and OS permission handling.
- Restore schedules after app restart and Android reboot, and preserve local wall-clock time across time-zone and DST changes.
- Keep startup, settings persistence, and plant deletion flows local and offline.

**Non-Goals:**

- Remote push, Firebase Cloud Messaging, or any server-side scheduling.
- Cross-device sync, export/import of notification state, or notification history timeline.
- Rich notification actions beyond open-to-care-schedule (no inline snooze/complete from the notification in v1).
- Chatty per-day batching or daily digest; v1 schedules one pending request per eligible rule occurrence.

## Decisions

### Decision: Use `flutter_local_notifications` with `timezone` for wall-clock scheduling

**Choice:** Add `flutter_local_notifications` (current 22.x) plus `timezone` for `zonedSchedule`. Use one stable Android notification channel and inexact scheduling by default; request exact alarm only if product requires minute-exact delivery, with inexact fallback otherwise.

**Rationale:** This is the maintained Flutter local-notification package with Android 13 `POST_NOTIFICATIONS` handling, Android 12/14 exact-alarm guidance, reboot `RECEIVE_BOOT_COMPLETED` receiver, and iOS `UNUserNotificationCenter` delegation. `timezone` preserves configured local time across time-zone and DST changes. Reusing an already-installed plugin model would not exist.

**Alternatives considered:**

1. Always-running foreground service with timers → unnecessary battery, notification trampoline restrictions, and not needed because OS can deliver scheduled notifications while app is terminated.
2. `workmanager` / `android_alarm_manager_plus` → heavier native setup and less direct control of notification channels/permissions than scheduling directly.
3. Exact alarms everywhere → rejected as default because Android 14 generally denies `SCHEDULE_EXACT_ALARM` for fresh installs targeting API 33+ unless qualifying as alarm/calendar app; inexact scheduling satisfies plant-care reminders.

### Decision: No persistent background service; derive notifications from persisted state

**Choice:** Treat pending OS notifications as derived state. Recompute them from persisted plants, custom rules, `Settings`, and schedule computation on startup, after rule/completion/schedule changes, after time-zone changes, and after reboot.

**Rationale:** Keeps source of truth in existing collections, avoids a separate notification store that can drift, and matches the already pure schedule engine.

**Alternatives considered:**

1. Separate notification store with its own IDs → duplicate state that can desync after import/migration failures.
2. Persist only “last scheduled” timestamps → not needed because full reconciliation is cheap for personal-device rule counts.

### Decision: Notification domain owns scheduling; care-rule and schedule flows trigger reconciliation

**Choice:** Add a small notification module (`datasource` owns plugin/channel/permission/timezone init; `repository` owns ID mapping and payload encoding; `usecases`/service owns `reconcileAll()` and `cancelAll()`). Mutations in `CustomCareRuleUsecases`, `CareScheduleUsecases` (completion/snooze/skip), plant deletion, `SettingsController`, and startup call the notification service; the service queries current rules and schedule to compute `nextOccurrence` for each eligible rule and issues `cancel`/`zonedSchedule` calls.

**Rationale:** Keeps Clean Architecture boundaries intact and confines platform code to one module.

**Alternatives considered:**

1. Put scheduling entirely inside `CareScheduleDataSource` → mixes scheduling side effects into a currently pure engine boundary.
2. Let pages call the plugin directly → leaks platform concerns into UI and complicates testing.

### Decision: Stable notification IDs and payload routing

**Choice:** Map each eligible `(plantId, ruleId)` to a stable integer notification ID (for example UUID hash). Encode `plantId`, `ruleId`, and task type in the notification payload for tap routing to the care schedule page.

**Rationale:** Stable IDs allow cancel/replace without leaking duplicates; payload routing keeps navigation decoupled from OS state.

### Decision: Settings extension for global filters

**Choice:** Extend `Settings` with `notificationsEnabled` master flag plus `notifyDueTasks` and `notifyOverdueTasks` category flags, persisted via existing `SettingsController` JSON key with defaults true. In-app notification settings page reads these flags plus OS permission status.

**Rationale:** Reuses existing settings persistence and avoids a new preferences key.

**Alternatives considered:**

1. New preferences key for notification settings → unnecessary fragmentation.
2. Per-plant master switches only → does not satisfy requirement for system settings with category toggles.

### Decision: Platform configuration keeps Android primary, iOS correct

**Choice:** Android: declare `POST_NOTIFICATIONS` (API 33+), `RECEIVE_BOOT_COMPLETED`, `USE_EXACT_ALARM` only if exact alarms are used; create one channel (for example `care_reminders`) with importance default. iOS: request alert/sound/badge at an appropriate in-app moment and set `UNUserNotificationCenterDelegate` for foreground presentation; no extra background modes for v1.

**Rationale:** Matches Android 8+ channels, Android 13 runtime permission, and iOS local-notification delivery while backgrounded/terminated.

## Risks / Trade-offs

- **[Risk] Android 14 exact-alarm denial** → Default to inexact scheduling; if exact timing becomes required, request `SCHEDULE_EXACT_ALARM` contextually and fall back to inexact with user-visible explanation.
- **[Risk] OEM battery optimizations suppress delivery** → Use standard AlarmManager-backed scheduling, avoid exact where not needed, and document that aggressive battery savers can still delay plant reminders.
- **[Risk] iOS 64 pending request limit** → Schedule only the next occurrence per eligible rule (not a long rolling window) so personal-device rule counts stay well under the limit.
- **[Risk] Channel immutability after creation** → Fix channel ID/importance/sound before first release; changing it later requires channel versioning or user clears app data.
- **[Risk] Time-zone data not initialized** → Initialize `timezone` from device zone on startup and reconcile after zone changes; without this, wall-clock times can drift.
- **[Risk] Existing `AppDelegate.swift` Firebase call** → Remove or guard Firebase usage as part of this change because new capability forbids Firebase/third-party services (`ios/Runner/AppDelegate.swift` currently calls `FirebaseApp.configure()`).
- **[Trade-off] Single reminder time per rule vs per-weekday times** → v1 preserves existing `reminderTime` + `reminderDays` model; per-weekday times would require a data-model change and can be added later if requested.

## Migration Plan

1. Add `flutter_local_notifications`, `timezone`, and `flutter_native_timezone` (or equivalent) dependencies; update Android manifest, channel, and boot receiver; update iOS delegate and permission strings.
2. Extend `Settings` with notification flags using additive JSON decoding defaults; unchanged on-device JSON remains readable.
3. Register notification data source, repository, and use cases in `injection.dart` and expose through `AppServices`; add startup reconcile after `SettingsController.load()`.
4. Wire reconciliation calls into care-rule mutations, care-task completion/snooze/skip, plant deletion, global setting toggles, and time-zone change handling.
5. Add notification settings page, permission flow, localized strings, and tap routing to care schedule.
6. On rollback, pending OS notifications can be canceled; older builds ignore new settings JSON fields and new OS requests.

## Open Questions

- **Exact vs inexact as default:** Confirm minute-exact reminders are not required for v1; if required, decide whether to request `SCHEDULE_EXACT_ALARM` contextually or accept OS throttling.
- **Category granularity for global toggles:** Due vs overdue is the v1 baseline; confirm whether a third category (for example weekly summary) should ever be added.
- **Notification tap depth:** Confirm whether tapping should filter the care schedule to the specific plant/task or just open the care schedule page.
