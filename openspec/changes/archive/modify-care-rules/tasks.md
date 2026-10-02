## 1. Use-case Layer

- [ ] 1.1 Add `createOrUpdateOverride` method to `CustomCareRuleUsecases` that creates/updates a custom rule for a given task type and plant
- [ ] 1.2 Add `DuplicateRuleException` to exceptions.dart for when user tries to create duplicate rule for same task type
- [ ] 1.3 Add `getComputedRules` method to `CareScheduleUsecases` that returns computed rules with their effective intervals
- [ ] 1.4 Add `toggleComputedRule` method to `CareScheduleUsecases` that creates/disables custom override for computed rule

## 2. Data Layer

- [ ] 2.1 Add `hasCustomRuleForTaskType` method to `CustomCareRuleUsecases` to check if custom rule exists for task type
- [ ] 2.2 Update `CareScheduleRepository` to support querying custom rules by task type
- [ ] 2.3 Add method to `CareScheduleDatasource` to retrieve computed rules with modifiers

## 3. UI - Rule List

- [ ] 3.1 Create `CareRuleItem` widget that displays both computed and custom rules with visual distinction
- [ ] 3.2 Add chip/badge for "Species default" on computed rules
- [ ] 3.3 Add chip/badge for "Custom" on custom rules
- [ ] 3.4 Update `CareRuleListSheet` to show unified list of computed and custom rules
- [ ] 3.5 Add edit action on computed rules that opens form to create override
- [ ] 3.6 Add toggle switch on computed rules to enable/disable override

## 4. UI - Edit Form

- [ ] 4.1 Update `CareRuleFormSheet` to support editing computed rules (show current interval, allow changes)
- [ ] 4.2 Add tooltip showing base interval and modifiers for computed rules
- [ ] 4.3 Update form to pre-fill values when editing computed rule

## 5. Localization

- [ ] 5.1 Add new localization strings for "Species default", "Custom", "Edit computed rule"
- [ ] 5.2 Add strings for tooltip explanations
- [ ] 5.3 Run `fvm flutter gen-l10n` to regenerate localization files

## 6. Testing

- [ ] 6.1 Add unit tests for `createOrUpdateOverride` use-case
- [ ] 6.2 Add unit tests for `toggleComputedRule` use-case
- [ ] 6.3 Add widget tests for `CareRuleItem` with computed and custom rules
- [ ] 6.4 Add integration tests for editing computed rules flow

## 7. Final Validation

- [ ] 7.1 Run `fvm flutter analyze` to verify no lint errors
- [ ] 7.2 Run `fvm flutter test` to verify all tests pass
- [ ] 7.3 Manual testing: edit computed rule, verify override created
- [ ] 7.4 Manual testing: toggle computed rule, verify schedule updates
