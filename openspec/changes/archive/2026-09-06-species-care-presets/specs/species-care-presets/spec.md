## ADDED Requirements

### Requirement: Species care presets map characteristics to intervals
The system SHALL provide a pure function that accepts a `SpeciesEntity` and returns a list of `CustomCareRuleEntity` records — one for each of the 8 built-in task types with a non-zero interval.

#### Scenario: All 8 task types generated for a species
- **WHEN** the preset function receives a species with `waterNeeds: moderate`, `lightNeeds: medium`, `humidityPreference: moderate`, and `repottingIntervalMonths: 12`
- **THEN** the returned list contains exactly 8 rules for task types: watering (7d), fertilizing (21d), misting (5d), pruning (30d), rotating (14d), repotting (360d), leaf cleaning (14d), pest inspection (21d)

#### Scenario: High-humidity species skips misting
- **WHEN** the preset function receives a species with `humidityPreference: high`
- **THEN** the returned list contains a misting rule with `intervalDays: 3`

#### Scenario: Low-humidity species omits misting
- **WHEN** the preset function receives a species with `humidityPreference: low`
- **THEN** the returned list does NOT contain a misting rule (interval is 0 → omitted)

### Requirement: Preset rules have sensible defaults
Each generated rule SHALL have `isEnabled: true`, `reminderEnabled: false`, `reminderTime: null`, `reminderDays: null`, and `createdAt` set to the current timestamp.

#### Scenario: Generated rule has correct defaults
- **WHEN** the preset function generates a rule for task type "watering"
- **THEN** the rule has `isEnabled: true`, `reminderEnabled: false`, `reminderTime: null`, `reminderDays: null`

### Requirement: Preset interval values follow task-type logic
The system SHALL use the following mapping logic for interval computation:

| Task Type | Source |
|-----------|--------|
| watering | `WaterNeeds.frequent → 5d`, `.moderate → 7d`, `.low → 10d` |
| fertilizing | `WaterNeeds.frequent → 14d`, `.moderate → 21d`, `.low → 30d` |
| misting | `HumidityPreference.high → 3d`, `.moderate → 5d`, `.low → 0` (omit) |
| pruning | Fixed 30d |
| rotating | Fixed 14d |
| repotting | `species.repottingIntervalMonths × 30` |
| leaf cleaning | Fixed 14d |
| pest inspection | Fixed 21d |

#### Scenario: Frequent-watering species gets shorter intervals
- **WHEN** the preset function receives a species with `waterNeeds: frequent`
- **THEN** the watering rule has `intervalDays: 5` and the fertilizing rule has `intervalDays: 14`

#### Scenario: Repotting interval scales with species
- **WHEN** the preset function receives a species with `repottingIntervalMonths: 6`
- **THEN** the repotting rule has `intervalDays: 180`

### Requirement: Presets are applied on plant creation with known species
When a new plant is created and its `speciesName` matches a known species in the species library, the system SHALL automatically create the 8 preset care rules for that plant.

#### Scenario: Plant created with known species gets presets
- **WHEN** a user creates a plant with `speciesName: "Monstera deliciosa"` (a known species)
- **THEN** the plant has 8 custom care rules derived from the species' characteristics

#### Scenario: Plant created with unknown species gets no presets
- **WHEN** a user creates a plant with `speciesName: "My Mystery Plant"` (not in species library)
- **THEN** the plant has zero custom care rules (existing behavior)

#### Scenario: Plant created without species gets no presets
- **WHEN** a user creates a plant with `speciesName: null`
- **THEN** the plant has zero custom care rules (existing behavior)
