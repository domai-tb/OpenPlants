# Care Plan

## Purpose

Define the care plan generation logic that translates species data into actionable plant care guidance.

## Requirements

### Requirement: Care plan generation
The system SHALL provide a use-case method that takes a `SpeciesEntity` and returns a `CarePlan` value object. The `CarePlan` SHALL contain structured guidance for: watering schedule, light positioning, humidity targets, soil type recommendation, and repotting timeline.

#### Scenario: Care plan generated from species
- **WHEN** `usecases.generateCarePlan(speciesEntity)` is called
- **THEN** it SHALL return a `CarePlan` object with all care sections populated

### Requirement: Care plan includes watering guidance
The care plan SHALL translate `waterNeeds` enum to actionable text:
- `low` → "Water every 2-3 weeks, allowing soil to dry completely between waterings"
- `moderate` → "Water once per week, allowing top inch of soil to dry between waterings"
- `frequent` → "Water 2-3 times per week, keeping soil consistently moist"

#### Scenario: Low water needs
- **WHEN** a species has `waterNeeds == low`
- **THEN** the care plan SHALL recommend watering every 2-3 weeks

#### Scenario: Frequent water needs
- **WHEN** a species has `waterNeeds == frequent`
- **THEN** the care plan SHALL recommend watering 2-3 times per week

### Requirement: Care plan includes light guidance
The care plan SHALL translate `lightNeeds` enum to actionable text:
- `low` → "Thrives in low light, keep away from direct sun. Ideal for north-facing rooms"
- `medium` → "Prefers bright indirect light. East or west-facing windows are ideal"
- `bright` → "Needs bright indirect light. South-facing window with sheer curtain"
- `direct` → "Requires direct sunlight. South-facing windowsill or grow lights"

#### Scenario: Low light guidance
- **WHEN** a species has `lightNeeds == low`
- **THEN** the care plan SHALL recommend low light positioning

#### Scenario: Direct light guidance
- **WHEN** a species has `lightNeeds == direct`
- **THEN** the care plan SHALL recommend direct sunlight

### Requirement: Care plan includes humidity guidance
The care plan SHALL translate `humidityPreference` enum to actionable text:
- `low` → "Tolerates average household humidity (30-40%). No special care needed"
- `moderate` → "Prefers higher humidity (40-60%). Consider a pebble tray or occasional misting"
- `high` → "Needs high humidity (60%+). Use a humidifier or place in a terrarium"

#### Scenario: High humidity guidance
- **WHEN** a species has `humidityPreference == high`
- **THEN** the care plan SHALL recommend a humidifier or terrarium

### Requirement: Care plan includes repotting timeline
The care plan SHALL use `repottingIntervalMonths` to generate repotting advice. It SHALL show the interval in months and a plain-language recommendation:
- ≤ 12 months → "Annual repotting recommended"
- 13-24 months → "Repot every 1-2 years"
- > 24 months → "Rarely needs repotting — only when root-bound"

#### Scenario: Annual repotting
- **WHEN** a species has `repottingIntervalMonths == 12`
- **THEN** the care plan SHALL recommend annual repotting
