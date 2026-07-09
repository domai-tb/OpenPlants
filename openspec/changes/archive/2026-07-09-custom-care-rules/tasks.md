## 1. Data Layer

- [x] 1.1 Create `CustomCareRuleEntity` class in `lib/pages/care_tracking/custom_care_rule.dart` with all required fields (id, plantId, taskType, intervalDays, reminderEnabled, reminderTime, reminderDays, isEnabled, createdAt)
- [x] 1.2 Create `CustomCareRuleDataSource` in `lib/pages/care_tracking/care_tracking_datasource.dart` with CRUD methods using SharedPreferences JSON storage
- [x] 1.3 Create `CustomCareRuleRepository` in `lib/pages/care_tracking/care_tracking_repository.dart` mapping between raw storage and domain entity

## 2. Use Cases

- [x] 2.1 Create `CreateCustomCareRuleUseCase` accepting plantId, taskType, interval, optional reminder config
- [x] 2.2 Create `UpdateCustomCareRuleUseCase` accepting ruleId and partial update fields
- [x] 2.3 Create `DeleteCustomCareRuleUseCase` accepting ruleId
- [x] 2.4 Create `ToggleCustomCareRuleUseCase` to toggle isEnabled state
- [x] 2.5 Create `GetCustomCareRulesUseCase` accepting plantId, returning ordered list

## 3. Schedule Engine Integration

- [x] 3.1 Modify schedule engine function signature to accept custom care rules parameter
- [x] 3.2 Add pre-check logic: for each enabled rule, use rule interval directly (skip species defaults, room modifiers, pot-type modifiers)
- [x] 3.3 Add support for user-defined task types from rules (task types not in the 8 built-in types)
- [x] 3.4 Update engine tests to cover custom rule override scenarios

## 4. UI — Rule Management

- [x] 4.1 Add "Care Rules" section to plant detail page showing rule count and tap target
- [x] 4.2 Create rule list page/sheet showing all rules for a plant with task type, interval, and toggle
- [x] 4.3 Create "Add rule" form with task type dropdown (built-in types) + free text input, interval field, optional reminder config (time picker, day selector)
- [x] 4.4 Create edit rule form pre-populated with existing rule values
- [x] 4.5 Add swipe-to-delete or delete menu action with confirmation dialog
- [x] 4.6 Add empty state for plant with no rules and for empty rule list

## 5. UI — Filter Integration

- [x] 5.1 Update care schedule page task-type filter to include user-defined task types from custom rules

## 6. DI and Wiring

- [x] 6.1 Register `CustomCareRuleDataSource`, `CustomCareRuleRepository`, and all use-cases in `lib/core/injection.dart`
- [x] 6.2 Add new use-cases to `AppServices` constructor and `app_services.dart`
- [x] 6.3 Wire rule management pages into navigation from plant detail

## 7. Testing

- [x] 7.1 Write unit tests for `CustomCareRuleRepository` CRUD operations
- [x] 7.2 Write unit tests for all custom care rule use-cases
- [x] 7.3 Write unit tests for schedule engine with custom rule overrides
- [x] 7.4 Run `fvm flutter analyze` and fix any lint violations

## 8. Localization

- [x] 8.1 Add ARB keys for rule management UI strings (care rules section, add/edit/delete/empty state text)
- [x] 8.2 Run `fvm flutter gen-l10n` to regenerate localization files
