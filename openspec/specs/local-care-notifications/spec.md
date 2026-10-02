## Purpose

Deliver privacy-preserving, on-device care reminders for watering and other plant tasks without Firebase, accounts, or internet access.

## Requirements

### Requirement: Local care notifications are scheduled from enabled care rules

The system SHALL derive scheduled local notifications from enabled custom care rules that have reminders enabled, using each rule's interval, reminder time, and selected weekdays. Only rules where `isEnabled` and `reminderEnabled` are true and where the global notification master switch and the matching category toggle allow delivery SHALL result in a pending OS notification.

#### Scenario: Enabled reminder with valid time and days schedules notification

- **WHEN** a plant has an enabled custom care rule for watering with interval 7 days, reminder at 09:00 on monday and thursday, and global notifications are enabled
- **THEN** the system schedules a local notification for the next matching occurrence for that rule

#### Scenario: Disabled rule or disabled reminder does not schedule

- **WHEN** a rule has `isEnabled` false or `reminderEnabled` false
- **THEN** the system does not keep a pending notification for that rule and cancels any previously scheduled one

#### Scenario: Reminder with missing time or days is ignored

- **WHEN** a rule has `reminderEnabled` true but `reminderTime` or `reminderDays` is null or invalid
- **THEN** the system does not schedule a notification for that rule and reports no pending notification for it

### Requirement: Global notification settings filter delivery by category

The system SHALL persist global notification settings containing a master enabled flag and independent category toggles for notification types such as due-care reminders and overdue-care reminders. The system SHALL enforce these toggles during scheduling, rescheduling, and delivery decisions.

#### Scenario: Master switch off cancels all pending notifications

- **WHEN** the user turns off the global notification master switch
- **THEN** the system cancels all pending care notifications and does not schedule new ones while the master switch remains off

#### Scenario: Category toggle off suppresses only that category

- **WHEN** the user disables overdue-care notifications while leaving due-care notifications enabled
- **THEN** the system cancels pending overdue notifications but keeps due-care notifications scheduled

#### Scenario: Defaults allow notifications

- **WHEN** the app is installed fresh and notification settings have never been changed
- **THEN** the master switch and category toggles default to enabled, subject to OS permission still being required

### Requirement: Notifications are reconciled after data or schedule changes

The system SHALL reconcile pending notifications after any change that can affect due dates or reminder configuration, including plant add/edit/delete, custom care rule create/update/delete/toggle, task completion, snooze, skip, schedule configuration change, global notification setting change, time-zone change, and daylight-saving transition.

#### Scenario: Mark done reschedules next occurrence

- **WHEN** the user marks a watering task done for a plant that has a reminder-enabled watering rule
- **THEN** the system cancels the previous pending notification for that rule and schedules the next occurrence from the new completion anchor

#### Scenario: Snooze or skip updates pending notification

- **WHEN** the user snoozes or skips a task occurrence
- **THEN** the system updates the pending notification for the affected rule to the overridden due date

#### Scenario: Plant deletion cancels its notifications

- **WHEN** the user deletes a plant
- **THEN** the system cancels all pending notifications for that plant's rules

#### Scenario: Stale notifications are canceled

- **WHEN** reconciliation runs and a previously scheduled notification no longer has a matching enabled reminder or its due date has changed
- **THEN** the system cancels the stale pending notification

### Requirement: Notifications survive app restart and device reboot

The system SHALL restore scheduled local notifications after app startup and after device reboot without requiring an always-running background service. On Android the system SHALL handle boot completion and reschedule valid pending notifications from persisted plants, rules, and settings.

#### Scenario: App restart restores notifications

- **WHEN** the app is terminated and then launched again
- **THEN** the system recomputes pending notifications from stored data and re-registers them with the OS

#### Scenario: Device reboot restores notifications on Android

- **WHEN** the Android device reboots and the app's boot receiver runs
- **THEN** the system restores pending notifications that are still valid according to current rules and global settings

#### Scenario: Invalid notifications are not restored

- **WHEN** restoration runs and a rule is now disabled or globally filtered
- **THEN** the system does not restore a notification for that rule

### Requirement: Notification permission is requested and reflected in UI

The system SHALL check OS notification permission status, request permission at an appropriate in-app moment, and surface permission state and guidance in the notification settings UI. If permission is denied or unavailable, the system SHALL explain the state and offer to open OS settings where possible.

#### Scenario: Permission not yet requested shows request affordance

- **WHEN** the user opens notification settings and OS permission has not been granted
- **THEN** the settings UI shows a request permission action and explains why local reminders need permission

#### Scenario: Permission denied shows settings guidance

- **WHEN** OS notification permission is denied
- **THEN** the settings UI indicates notifications are blocked at OS level and offers to open system settings

#### Scenario: Permission granted allows scheduling

- **WHEN** OS notification permission is granted and global settings allow a category
- **THEN** the system schedules pending notifications for matching reminder-enabled rules

### Requirement: Notification tap navigates to care schedule

Tapping a delivered care notification SHALL open or bring forward the app and navigate to the care schedule, focusing the relevant plant or task where possible.

#### Scenario: Tap opens care schedule

- **WHEN** the user taps a delivered care notification for a specific plant and task type
- **THEN** the app opens to the care schedule with that plant or task type highlighted or filtered

#### Scenario: Tap with missing plant falls back gracefully

- **WHEN** a notification is tapped but the referenced plant or rule no longer exists
- **THEN** the app still opens to the care schedule without crashing

### Requirement: Time-zone and daylight-saving changes preserve local reminder time

The system SHALL schedule notifications using time-zone-aware local time so that the configured reminder time (for example 09:00) continues to fire at the same wall-clock time after the device time zone changes or after a daylight-saving transition.

#### Scenario: Time zone change keeps local time

- **WHEN** the device time zone changes from Europe/Berlin to Europe/London
- **THEN** a reminder configured for 09:00 continues to fire at 09:00 in the new local zone after reconciliation

#### Scenario: DST transition keeps local time

- **WHEN** a daylight-saving transition occurs
- **THEN** reminders configured for a fixed local time still fire at that local time on the next matching weekday

### Requirement: Notifications remain local and offline

The system SHALL deliver care notifications using only on-device OS scheduling. The system SHALL NOT require internet access, Firebase, push messaging, accounts, analytics, or any third-party notification service for care reminders.

#### Scenario: Offline delivery

- **WHEN** the device is offline and a scheduled reminder becomes due
- **THEN** the notification is still delivered locally by the OS

#### Scenario: No network dependency on startup or reschedule

- **WHEN** the app reconciles notifications after startup, reboot, or rule change
- **THEN** it does so without network access and without contacting any remote service

### Requirement: Notification content is localized and accessible

Notification titles, bodies, and in-app notification settings copy SHALL use localized strings from ARB files for supported locales, and notification actions and navigation SHALL remain accessible with standard assistive technologies.

#### Scenario: Notification text uses localized strings

- **WHEN** a notification is delivered on a device set to German
- **THEN** its title and body use German localization keys rather than hard-coded literals

#### Scenario: Settings labels are localized

- **WHEN** the user views notification settings in any supported locale
- **THEN** all labels, helper text, and permission guidance come from localized strings
