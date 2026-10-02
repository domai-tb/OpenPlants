## Why

Users can currently add custom care rules, but the pre-created care rules (watering, fertilizing, misting, etc.) that are computed from species profiles are not directly editable. Users must create a custom rule with the same task type to override the computed schedule, which is non-obvious and confusing. The user should be able to modify all care rules—both computed and custom—from a single, unified interface.

## What Changes

- Add ability to edit pre-created (computed) care rules directly from the care schedule UI
- Unified rule list showing both computed and custom rules with clear visual distinction
- Edit action on computed rules creates a custom override that takes precedence
- Toggle enable/disable on computed rules (temporarily suppress without deleting)
- Visual indicators differentiate computed vs custom rules

## Capabilities

### New Capabilities

- `editable-computed-rules`: Allow users to modify pre-created care rules by creating custom overrides that take precedence over computed schedules

### Modified Capabilities

- `custom-care-rules`: Extend existing capability to support editing computed rules and visual differentiation between rule types

## Impact

- `lib/pages/care_schedule/widgets/care_rules_section.dart` — UI changes for rule list and edit flow
- `lib/pages/care_schedule/custom_care_rule_usecases.dart` — New use-case for creating overrides for computed rules
- `lib/pages/care_schedule/schedule_engine.dart` — Logic to apply computed rule overrides
- `lib/l10n/l10n_en.dart`, `lib/l10n/l10n_de.dart` — New localization strings
