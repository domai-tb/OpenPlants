## ADDED Requirements

### Requirement: Plant detail page shows custom care rules section
The system SHALL display a "Care Rules" section on the plant detail page showing a summary of custom care rules for that plant (count of active rules and a tap target to manage them).

#### Scenario: Plant with no rules shows empty state
- **WHEN** user views plant detail for a plant with no custom care rules
- **THEN** the Care Rules section shows "No custom rules" with an "Add rule" button

#### Scenario: Plant with rules shows count
- **WHEN** user views plant detail for a plant with 3 active custom care rules
- **THEN** the Care Rules section shows "3 active rules" with a tap target to open the rule list

### Requirement: Rule list page displays all rules for a plant
The system SHALL provide a page or sheet that lists all custom care rules for a selected plant, showing task type, interval, and enabled status for each rule.

#### Scenario: Rule list shows all rules
- **WHEN** user opens the care rules list for a plant with 2 rules
- **THEN** the list displays both rules with task type, interval, and toggle switch

#### Scenario: Empty rule list shows call-to-action
- **WHEN** user opens the care rules list for a plant with no rules
- **THEN** the list shows an empty state with an "Add your first rule" prompt

### Requirement: User can add a new custom care rule from the UI
The system SHALL provide an "Add rule" action that opens a form where the user can select or type a task type, set an interval in days, and optionally configure reminder settings.

#### Scenario: Add rule with built-in task type
- **WHEN** user taps "Add rule" and selects "watering" from the dropdown with interval 10 days
- **THEN** a new rule is created for the plant with task type "watering" and interval 10 days

#### Scenario: Add rule with custom task type
- **WHEN** user taps "Add rule", types "Check for flowers" in the task type field, and sets interval 7 days
- **THEN** a new rule is created with task type "Check for flowers" and interval 7 days

#### Scenario: Add rule with reminder
- **WHEN** user enables reminder, sets time to 09:00, and selects monday/wednesday/friday
- **THEN** the new rule is created with reminder config as specified

### Requirement: User can edit an existing custom care rule
The system SHALL allow users to tap on a rule in the list to open an edit form pre-populated with the rule's current values.

#### Scenario: Edit rule interval
- **WHEN** user opens a rule for editing and changes interval from 7 to 14 days
- **THEN** the rule is updated to 14 days and the list reflects the change

#### Scenario: Edit rule reminder
- **WHEN** user opens a rule, enables reminder, and sets time to 08:00
- **THEN** the rule's reminder config is updated

### Requirement: User can disable or delete a rule from the list
Each rule in the list SHALL have a toggle switch to enable/disable and a delete action (swipe-to-delete or menu option).

#### Scenario: Toggle rule off
- **WHEN** user taps the toggle switch on an enabled rule
- **THEN** the rule is disabled (isEnabled=false) and visually dimmed in the list

#### Scenario: Delete rule
- **WHEN** user swipes to delete a rule and confirms
- **THEN** the rule is removed from the list and from storage

### Requirement: Custom task types appear in task-type filter
The system SHALL include user-defined task types (from custom care rules) in the task-type filter on the care schedule page, so users can filter by their custom task types.

#### Scenario: Custom task type in filter
- **WHEN** a user has a custom care rule with task type "Check for flowers"
- **THEN** "Check for flowers" appears as an option in the task-type filter dropdown
