## ADDED Requirements

### Requirement: Care rule reminder changes reconcile local notifications

The system SHALL reconcile local notifications after any mutation of custom care rules that can affect reminder delivery, including creation, update, deletion, enabling, disabling, and changes to reminder time or weekdays. The system SHALL schedule a pending notification when a rule becomes eligible and SHALL cancel any pending notification when a rule becomes ineligible.

#### Scenario: Enabling a reminder schedules notification

- **WHEN** the user enables `reminderEnabled` and sets `reminderTime` to 08:30 and `reminderDays` to monday and thursday for an enabled rule
- **THEN** the system schedules a pending local notification for the next matching occurrence

#### Scenario: Disabling a reminder cancels notification

- **WHEN** the user sets `reminderEnabled` to false for a rule that previously had a pending notification
- **THEN** the system cancels that pending notification and does not schedule a replacement while disabled

#### Scenario: Deleting a rule cancels its notification

- **WHEN** the user deletes a custom care rule that had a pending notification
- **THEN** the system cancels the pending notification for the deleted rule

### Requirement: Rule validation preserves notification consistency

The system SHALL validate reminder configuration before treating a rule as notification-eligible, requiring a parseable `HH:mm` time and at least one valid weekday when `reminderEnabled` is true. Invalid reminder configuration SHALL be treated as ineligible for scheduling until corrected.

#### Scenario: Invalid time prevents scheduling

- **WHEN** a rule is saved with `reminderEnabled` true but `reminderTime` is missing or not in `HH:mm` format
- **THEN** the system does not schedule a notification for that rule

#### Scenario: Empty weekdays prevents scheduling

- **WHEN** a rule is saved with `reminderEnabled` true but `reminderDays` is empty or contains no valid weekdays
- **THEN** the system does not schedule a notification for that rule

### Requirement: Shared care-rule operation failures preserve notification state

If a custom care rule mutation fails due to persistence or validation failure, the system SHALL NOT update the derived notification schedule for that rule and SHALL surface a classified error without leaving a stale pending notification from the failed mutation.

#### Scenario: Failed update leaves notifications unchanged

- **WHEN** updating a care rule fails before persistence completes
- **THEN** the pending notification state for that rule remains as it was before the attempted update
