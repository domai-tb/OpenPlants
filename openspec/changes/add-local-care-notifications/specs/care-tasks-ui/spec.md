## ADDED Requirements

### Requirement: App provides notification settings and permission status

The system SHALL provide an in-app notification settings surface reachable from app settings that shows the global master toggle, independent category toggles for notification types such as due-care and overdue-care, current OS permission state, and request or open-settings actions when permission is missing or denied.

#### Scenario: User toggles category off

- **WHEN** the user disables overdue-care notifications in notification settings
- **THEN** the system persists the new toggle value and reconciles pending notifications to reflect the change

#### Scenario: Master toggle off disables all categories

- **WHEN** the user turns off the global notification master switch
- **THEN** the system disables delivery for all notification categories and cancels all pending notifications until the master switch is turned on again

#### Scenario: Permission status is visible

- **WHEN** the user opens notification settings and OS notification permission is not granted
- **THEN** the UI shows that notifications require OS permission and offers to request permission or open system settings

### Requirement: Notification status feedback is localized and accessible

All notification settings labels, helper text, permission explanations, and status messages SHALL come from localized ARB keys for supported locales and SHALL be accessible with standard assistive technologies.

#### Scenario: Settings labels use localization

- **WHEN** notification settings are rendered in English or German
- **THEN** every user-facing string comes from `AppLocalizations` keys rather than string literals

#### Scenario: Permission guidance is accessible

- **WHEN** permission guidance or status text is shown
- **THEN** it uses accessible labels and supports text scaling and screen readers
