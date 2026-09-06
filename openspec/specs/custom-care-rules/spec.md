# Custom Care Rules

User-defined care rules that override the computed schedule engine for specific plants.

## Purpose

Allow users to define custom care rules per plant that take precedence over the species-default schedule engine, enabling personalized care routines with custom task types, intervals, and optional reminders.

## Requirements

### Requirement: Custom care rules are stored per plant
The system SHALL maintain a list of custom care rules for each plant, where each rule defines a task type, interval in days, and optional reminder configuration. When a plant is created with a known species, the system SHALL auto-populate this list with species-derived preset rules. When a plant is created without a known species, the list SHALL start empty.

#### Scenario: New plant starts with no custom rules
- **WHEN** a new plant is created without a species name
- **THEN** the system assigns an empty list of custom care rules for that plant

#### Scenario: New plant with known species starts with preset rules
- **WHEN** a new plant is created with a species name matching a known species
- **THEN** the system assigns a list of preset care rules derived from that species' characteristics

#### Scenario: Rule is created for a plant
- **WHEN** user creates a custom care rule for plant "Monstera" with task type "Check for flowers" and interval 7 days
- **THEN** the rule is persisted and associated with that plant

### Requirement: Custom care rule fields
Each custom care rule SHALL contain: id (UUID), plantId, taskType (String), intervalDays (int), reminderEnabled (bool), reminderTime (nullable String in HH:mm format), reminderDays (nullable list of day names), isEnabled (bool), and createdAt (DateTime).

#### Scenario: Rule with all fields
- **WHEN** user creates a rule with task type "watering", interval 5 days, reminder at 09:00 on monday/wednesday/friday
- **THEN** the persisted rule contains all specified fields with correct values

#### Scenario: Rule with minimal fields
- **WHEN** user creates a rule with only task type "pruning" and interval 30 days
- **THEN** reminderEnabled defaults to false, reminderTime is null, reminderDays is null, and isEnabled defaults to true

### Requirement: Users can create custom care rules
The system SHALL provide a use-case method that accepts a plant ID, task type, interval, and optional reminder config, and returns the created rule.

#### Scenario: Create rule via use-case
- **WHEN** `usecases.createCustomCareRule(plantId, "fertilizing", 14, null, null)` is called
- **THEN** a new rule is persisted and the returned rule has a generated UUID and the current timestamp

### Requirement: Users can update custom care rules
The system SHALL provide a use-case method that accepts a rule ID and updated fields, applies the changes, and returns the updated rule.

#### Scenario: Update rule interval
- **WHEN** `usecases.updateCustomCareRule(ruleId, intervalDays: 10)` is called
- **THEN** the rule's interval is updated to 10 days and the returned rule reflects the change

#### Scenario: Update non-existent rule
- **WHEN** `usecases.updateCustomCareRule("nonexistent-id", intervalDays: 10)` is called
- **THEN** the use-case throws a `RuleNotFoundException`

### Requirement: Users can delete custom care rules
The system SHALL provide a use-case method that accepts a rule ID and removes it from storage.

#### Scenario: Delete rule
- **WHEN** `usecases.deleteCustomCareRule(ruleId)` is called
- **THEN** the rule is removed from storage and no longer appears in the plant's rule list

### Requirement: Users can toggle rule enabled state
The system SHALL allow users to disable a rule without deleting it, so it is excluded from schedule computation but can be re-enabled later.

#### Scenario: Disable rule
- **WHEN** user disables a custom care rule
- **THEN** `isEnabled` is set to false and the rule is excluded from schedule computation

#### Scenario: Re-enable rule
- **WHEN** user enables a previously disabled custom care rule
- **THEN** `isEnabled` is set to true and the rule is included in schedule computation again

### Requirement: Users can configure reminder settings
The system SHALL allow users to optionally enable reminders for each custom care rule, specifying a time-of-day and days-of-week.

#### Scenario: Enable reminder with time and days
- **WHEN** user sets reminder enabled to true, time to "08:30", and days to ["monday", "thursday"]
- **THEN** the rule's reminder config is persisted with those values

#### Scenario: Disable reminder
- **WHEN** user sets reminder enabled to false
- **THEN** reminderTime and reminderDays are cleared (set to null)

### Requirement: Users can retrieve all rules for a plant
The system SHALL provide a use-case method that accepts a plant ID and returns all custom care rules for that plant, ordered by creation date.

#### Scenario: Retrieve rules for plant
- **WHEN** `usecases.getCustomCareRules(plantId)` is called
- **THEN** the system returns all rules for that plant, ordered oldest-first

#### Scenario: Plant with no rules
- **WHEN** `usecases.getCustomCareRules(plantId)` is called for a plant with no rules
- **THEN** the system returns an empty list

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
