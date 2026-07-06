## ADDED Requirements

### Requirement: Rename page3 folder to plant_identification
The system SHALL rename the `lib/pages/page3/` directory to `lib/pages/plant_identification/` to reflect its actual purpose.

#### Scenario: Folder renamed
- **WHEN** the rename is complete
- **THEN** the directory `lib/pages/plant_identification/` exists and `lib/pages/page3/` no longer exists

### Requirement: Rename page3 files to meaningful names
The system SHALL rename all `page3_*` files within the plant identification feature to descriptive names that reflect their purpose.

#### Scenario: File names updated
- **WHEN** the rename is complete
- **THEN** the following file mapping exists:
  - `page3_page.dart` → `plant_identification_page.dart`
  - `page3_datasource.dart` → `plant_identification_datasource.dart`
  - `page3_repository.dart` → `plant_identification_repository.dart`
  - `page3_usecases.dart` → `plant_identification_usecases.dart`
  - `page3_item_entity.dart` → `identification_state.dart`

### Requirement: Rename PageItem enum value
The system SHALL rename the `PageItem.page3` enum value to `PageItem.plantIdentification` in `lib/pages/home/page_navigator.dart`.

#### Scenario: Enum value renamed
- **WHEN** the rename is complete
- **THEN** `PageItem.page3` no longer exists and `PageItem.plantIdentification` is used throughout the codebase

#### Scenario: All enum references updated
- **WHEN** the enum value is renamed
- **THEN** all switch statements, maps, and references using `PageItem.page3` are updated to `PageItem.plantIdentification`

### Requirement: Rename AppServices field
The system SHALL rename the `AppServices.page3` field to `AppServices.plantIdentification` in `lib/core/app_services.dart`.

#### Scenario: Field renamed
- **WHEN** the rename is complete
- **THEN** `AppServices.page3` no longer exists and `AppServices.plantIdentification` is used

### Requirement: Update DI registration names
The system SHALL update all GetIt registration names in `lib/core/injection.dart` from `Page3*` to `PlantIdentification*` class names.

#### Scenario: DI classes renamed
- **WHEN** the rename is complete
- **THEN** `Page3DataSource` → `PlantIdentificationDataSource`, `Page3Repository` → `PlantIdentificationRepository`, `Page3Usecases` → `PlantIdentificationUsecases`

### Requirement: Remove all generic "Page 3" references
The system SHALL remove all remaining references to "Page 3", "page3", or "Page3" from the codebase, including localization strings, comments, and documentation.

#### Scenario: Localization strings updated
- **WHEN** the rename is complete
- **THEN** `l10n_en.arb` and `l10n_de.arb` contain `"plantIdentificationTitle": "Plant ID"` instead of `"page3Title": "Page 3"`

#### Scenario: No generic references remain
- **WHEN** the rename is complete
- **THEN** a codebase search for "page3", "Page3", "Page 3", or "page 3" (case-insensitive) returns zero results in `lib/` and `assets/l10n/`

#### Scenario: Comments and documentation updated
- **WHEN** the rename is complete
- **THEN** all comments and documentation files referencing "page3" or "Page 3" are updated to "plant_identification" or "Plant Identification"
