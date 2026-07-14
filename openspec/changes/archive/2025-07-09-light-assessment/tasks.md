## 1. Data Model

- [x] 1.1 Add `LightLevel` enum (low, medium, brightIndirect, direct) to the plant entity
- [x] 1.2 Add nullable `lightLevel` field to `PlantEntity`
- [x] 1.3 Update serialization/deserialization for the new field (shared_preferences JSON)

## 2. Light Assessment Feature Module

- [x] 2.1 Create `lib/pages/lightAssessment/light_assessment_datasource.dart` — persist light level via shared_preferences
- [x] 2.2 Create `lib/pages/lightAssessment/light_assessment_repository.dart` — map raw data to/from `PlantEntity`
- [x] 2.3 Create `lib/pages/lightAssessment/light_assessment_usecases.dart` — business logic for get/set light level
- [x] 2.4 Create `lib/pages/lightAssessment/light_assessment_item_entity.dart` — data model for light level options
- [x] 2.5 Create `lib/pages/lightAssessment/light_assessment_page.dart` — UI with 4-option selector and camera estimation hint

## 3. Camera Light Estimation (Optional)

- [x] 3.1 Implement camera brightness reading from viewfinder frames
- [x] 3.2 Map ambient brightness to the four light levels
- [x] 3.3 Display estimation as a suggestion with accept/dismiss actions
- [x] 3.4 Handle camera permission denial gracefully (hide estimation option)

## 4. DI Registration

- [x] 4.1 Register `LightAssessmentDataSource`, `LightAssessmentRepository`, `LightAssessmentUseCases` in `lib/core/injection.dart`
- [x] 4.2 Add `LightAssessmentUseCases` to `AppServices` constructor and field

## 5. Care Schedule Engine Integration

- [x] 5.1 Add light-level modifier table to the care schedule engine (low=1.3×, medium=1.0×, brightIndirect=0.85×, direct=0.7× for watering)
- [x] 5.2 Modify engine to accept plant light level and use it as a modifier when present
- [x] 5.3 Ensure plant light level takes precedence over room sunlight when both exist
- [x] 5.4 Ensure null light level falls back to existing room sunlight behavior

## 6. UI Integration

- [x] 6.1 Add light level display to plant detail page (shows current value or "Not set")
- [x] 6.2 Add navigation entry to light assessment page from plant detail
- [x] 6.3 Run `fvm flutter analyze` — fix any lint violations

## 7. Testing

- [x] 7.1 Write unit tests for `LightAssessmentUseCases` (set, get, default null)
- [x] 7.2 Write unit tests for care schedule engine light-level modifier logic
- [x] 7.3 Write unit tests for camera brightness-to-level mapping
- [x] 7.4 Run `fvm flutter test` — all tests pass
