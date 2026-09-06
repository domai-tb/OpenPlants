## MODIFIED Requirements

### Requirement: Users can create custom care rules
The system SHALL provide a use-case method that accepts a plant ID, task type, interval, and optional reminder config, and returns the created rule. The system SHALL enforce one custom rule per task type per plant.

#### Scenario: Create rule via use-case
- **WHEN** `usecases.createCustomCareRule(plantId, "fertilizing", 14, null, null)` is called
- **THEN** a new rule is persisted and the returned rule has a generated UUID and the current timestamp

#### Scenario: Create duplicate rule for same task type
- **WHEN** `usecases.createCustomCareRule(plantId, "watering", 7, null, null)` is called and a custom rule with taskType "watering" already exists for that plant
- **THEN** the use-case throws a `DuplicateRuleException`

### Requirement: Users can update custom care rules
The system SHALL provide a use-case method that accepts a rule ID and updated fields, applies the changes, and returns the updated rule.

#### Scenario: Update rule interval
- **WHEN** `usecases.updateCustomCareRule(ruleId, intervalDays: 10)` is called
- **THEN** the rule's interval is updated to 10 days and the returned rule reflects the change

#### Scenario: Update non-existent rule
- **WHEN** `usecases.updateCustomCareRule("nonexistent-id", intervalDays: 10)` is called
- **THEN** the use-case throws a `RuleNotFoundException`

#### Scenario: Update task type to duplicate
- **WHEN** `usecases.updateCustomCareRule(ruleId, taskType: "watering")` is called and another custom rule with taskType "watering" already exists for that plant
- **THEN** the use-case throws a `DuplicateRuleException`

## ADDED Requirements

### Requirement: Custom rules are visually distinguished
The system SHALL visually distinguish custom rules from computed rules in the care rules list using chips or badges.

#### Scenario: Custom rule shows badge
- **WHEN** a custom rule is displayed in the care rules list
- **THEN** it shows a "Custom" chip or badge to indicate it's user-defined

#### Scenario: Computed rule shows badge
- **WHEN** a computed rule is displayed in the care rules list
- **THEN** it shows a "Species default" chip or badge to indicate it's computed

### Requirement: Unified rule list
The system SHALL display both computed and custom care rules in a single unified list, ordered by task type name.

#### Scenario: Mixed rule list
- **WHEN** user views care rules for a plant with computed watering and custom fertilizing rules
- **THEN** both rules appear in the same list, sorted alphabetically by task type

#### Scenario: Rule list with overrides
- **WHEN** user views care rules for a plant with a custom override for watering
- **THEN** only the custom override is shown (not both computed and custom for same task type)
