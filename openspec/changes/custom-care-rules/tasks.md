## 1. Data Layer

- [ ] 1.1 Create `CustomCareRuleEntity` class in `lib/pages/careTracking/care_tracking_item_entity.dart` with all required fields (id, plantId, taskType, intervalDays, reminderEnabled, reminderTime, reminderDays, isEnabled, createdAt)
- [ ] 1.2 Create `CustomCareRuleDataSource` in `lib/pages/careTracking/care_tracking_datasource.dart` with CRUD methods using SharedPreferences JSON storage
- [ ] 1.3 Create `CustomCareRuleRepository` in `lib/pages/careTracking/care_tracking_repository.dart` mapping between raw storage and domain entity

## 2. Use Cases

- [ ] 2.1 Create `CreateCustomCareRuleUseCase` accepting plantId, taskType, interval, optional reminder config
- [ ] 2.2 Create `UpdateCustomCareRuleUseCase` accepting ruleId and partial update fields
- [ ] 2.3 Create `DeleteCustomCareRuleUseCase` accepting ruleId
- [ ] 2.4 Create `ToggleCustomCareRuleUseCase` to toggle isEnabled state
- [ ] 2.5 Create `GetCustomCareRulesUseCase` accepting plantId, returning ordered list

## 3. Schedule Engine Integration

- [ ] 3.1 Modify schedule engine function signature to accept custom care rules parameter
- [ ] 3.2 Add pre-check logic: for each enabled rule, use rule interval directly (skip species defaults, room modifiers, pot-type modifiers)
- [ ] 3.3 Add support for user-defined task types from rules (task types not in the 8 built-in types)
- [ ] 3.4 Update engine tests to cover custom rule override scenarios

## 4. UI — Rule Management

- [ ] 4.1 Add "Care Rules" section to plant detail page showing rule count and tap target
- [ ] 4.2 Create rule list page/sheet showing all rules for a plant with task type, interval, and toggle
- [ ] 4.3 Create "Add rule" form with task type dropdown (built-in types) + free text input, interval field, optional reminder config (time picker, day selector)
- [ ] 4.4 Create edit rule form pre-populated with existing rule values
- [ ] 4.5 Add swipe-to-delete or delete menu action with confirmation dialog
- [ ] 4.6 Add empty state for plant with no rules and for empty rule list

## 5. UI — Filter Integration

- [ ] 5.1 Update care schedule page task-type filter to include user-defined task types from custom rules

## 6. DI and Wiring

- [ ] 6.1 Register `CustomCareRuleDataSource`, `CustomCareRuleRepository`, and all use-cases in `lib/core/injection.dart`
- [ ] 6.2 Add new use-cases to `AppServices` constructor and `app_services.dart`
- [ ] 6.3 Wire rule management pages into navigation from plant detail

## 7. Testing

- [ ] 7.1 Write unit tests for `CustomCareRuleRepository` CRUD operations
- [ ] 7.2 Write unit tests for all custom care rule use-cases
- [ ] 7.3 Write unit tests for schedule engine with custom rule overrides
- [ ] 7.4 Run `fvm flutter analyze` and fix any lint violations

## 8. Localization

- [ ] 8.1 Add ARB keys for rule management UI strings (care rules section, add/edit/delete/empty state text)
- [ ] 8.2 Run `fvm flutter gen-l10n` to regenerate localization files
