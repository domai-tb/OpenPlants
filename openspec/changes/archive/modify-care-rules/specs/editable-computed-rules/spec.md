## ADDED Requirements

### Requirement: Users can edit computed care rules
The system SHALL allow users to edit pre-created care rules (watering, fertilizing, etc.) by creating custom overrides that take precedence over computed schedules.

#### Scenario: Edit computed rule creates override
- **WHEN** user edits the "watering" computed rule for plant "Monstera" and changes interval to 5 days
- **THEN** a custom care rule with taskType "watering" and intervalDays 5 is created for that plant
- **AND** the custom rule takes precedence over the computed watering schedule

#### Scenario: Edit existing custom override
- **WHEN** user edits a computed rule that already has a custom override
- **THEN** the existing custom override is updated (not a new rule created)

### Requirement: Computed rules are displayed in unified list
The system SHALL display both computed and custom care rules in a single unified list, with visual indicators showing which rules are computed vs custom.

#### Scenario: Mixed rule list
- **WHEN** user views care rules for a plant with computed watering and custom fertilizing rules
- **THEN** both rules appear in the same list with visual distinction (e.g., chip/badge)

#### Scenario: Visual indicator for computed rules
- **WHEN** a computed rule is displayed in the list
- **THEN** it shows a "Species default" chip or badge to indicate it's computed

#### Scenario: Visual indicator for custom rules
- **WHEN** a custom rule is displayed in the list
- **THEN** it shows a "Custom" chip or badge to indicate it's user-defined

### Requirement: Users can toggle computed rules
The system SHALL allow users to disable computed care rules temporarily without deleting them, by creating a disabled custom override.

#### Scenario: Disable computed rule
- **WHEN** user disables a computed rule (e.g., "fertilizing")
- **THEN** a custom rule with taskType "fertilizing" and isEnabled=false is created
- **AND** the computed fertilizing schedule is suppressed for that plant

#### Scenario: Re-enable computed rule
- **WHEN** user enables a previously disabled computed rule
- **THEN** the custom override is updated with isEnabled=true
- **AND** the computed schedule resumes (using custom override interval)

### Requirement: Computed rules show current interval
The system SHALL display the effective interval for computed rules, including any modifiers applied (light, humidity, pot type).

#### Scenario: Show modified interval
- **WHEN** computed rule has base interval of 7 days but light modifier makes it 5 days
- **THEN** the rule displays "Every 5 days" with a tooltip showing the base interval and modifiers

#### Scenario: Show base interval for custom overrides
- **WHEN** custom override exists for a computed rule
- **THEN** the rule displays the custom interval, not the computed one
