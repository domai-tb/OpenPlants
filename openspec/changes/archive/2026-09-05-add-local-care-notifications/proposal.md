## Why

OpenPlants computes care tasks and stores per-rule reminder preferences, but does not deliver reminders when app closed. Users miss watering and other care. Need privacy-preserving, on-device local notifications without Firebase, accounts, or internet.

## What Changes

- Add local notification delivery for due and overdue care tasks derived from care schedule engine.
- Reuse each custom care rule's `reminderEnabled`, `reminderTime`, `reminderDays`, and `isEnabled`; reschedule or cancel notifications whenever plants, rules, completions, snoozes, skips, or schedule settings change.
- Add persisted global notification settings with master switch and independent toggles for notification categories such as due-care and overdue-care reminders.
- Add in-app notification settings surface and OS permission flow, including clear fallback when OS notification permission denied or unavailable.
- Use OS-managed scheduled notifications, not always-running Flutter background service. Android restores schedules after reboot via notification receiver; iOS delivers scheduled local notifications while backgrounded or terminated.
- Keep all data and delivery local. No Firebase, push messaging, accounts, analytics, or network services.
- Support Android and iOS platform configuration; treat Android as primary tested platform because OpenPlants targets Android operationally.
- Add localized titles, bodies, settings labels, permission guidance, accessibility text.
- Add behavior-focused tests for scheduling, cancellation, global filters, permission states, restart/reboot recovery, time zones, daylight-saving transitions.

## Capabilities

### New Capabilities

- `local-care-notifications`: Schedule, cancel, restore, and configure on-device care reminders across Android and iOS without network services.

### Modified Capabilities

- `custom-care-rules`: Existing reminder fields now drive real local notification schedules and are reconciled after rule changes or care completion.
- `care-tasks-ui`: Add in-app notification settings and permission/status feedback while preserving per-rule reminder configuration.

## Impact

- New notification domain/service module behind Clean Architecture boundaries, plus GetIt/AppServices wiring and startup synchronization.
- Extensions to `Settings` persistence, More/settings navigation, care-rule mutation and schedule refresh flows, plant deletion cleanup, and notification tap routing to care schedule.
- New Flutter dependency for local notifications and time-zone-aware scheduling; Android manifest/channel/boot-receiver configuration and iOS notification delegate/permission configuration.
- New English and German localization keys and generated output.
- Existing local JSON/SharedPreferences data remains compatible; notification state derived from persisted plants/rules/settings and stale OS requests canceled during reconciliation.
