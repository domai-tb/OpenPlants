## 1. Data Model

- [ ] 1.1 Add `LightLevel` enum (low, medium, brightIndirect, direct) to the plant entity
- [ ] 1.2 Add nullable `lightLevel` field to `PlantEntity`
- [ ] 1.3 Update serialization/deserialization for the new field (shared_preferences JSON)

## 2. Light Assessment Feature Module

- [ ] 2.1 Create `lib/pages/lightAssessment/light_assessment_datasource.dart` — persist light level via shared_preferences
- [ ] 2.2 Create `lib/pages/lightAssessment/light_assessment_repository.dart` — map raw data to/from `PlantEntity`
- [ ] 2.3 Create `lib/pages/lightAssessment/light_assessment_usecases.dart` — business logic for get/set light level
- [ ] 2.4 Create `lib/pages/lightAssessment/light_assessment_item_entity.dart` — data model for light level options
- [ ] 2.5 Create `lib/pages/lightAssessment/light_assessment_page.dart` — UI with 4-option selector and camera estimation hint

## 3. Camera Light Estimation (Optional)

- [ ] 3.1 Implement camera brightness reading from viewfinder frames
- [ ] 3.2 Map ambient brightness to the four light levels
- [ ] 3.3 Display estimation as a suggestion with accept/dismiss actions
- [ ] 3.4 Handle camera permission denial gracefully (hide estimation option)

## 4. DI Registration

- [ ] 4.1 Register `LightAssessmentDataSource`, `LightAssessmentRepository`, `LightAssessmentUseCases` in `lib/core/injection.dart`
- [ ] 4.2 Add `LightAssessmentUseCases` to `AppServices` constructor and field

## 5. Care Schedule Engine Integration

- [ ] 5.1 Add light-level modifier table to the care schedule engine (low=1.3×, medium=1.0×, brightIndirect=0.85×, direct=0.7× for watering)
- [ ] 5.2 Modify engine to accept plant light level and use it as a modifier when present
- [ ] 5.3 Ensure plant light level takes precedence over room sunlight when both exist
- [ ] 5.4 Ensure null light level falls back to existing room sunlight behavior

## 6. UI Integration

- [ ] 6.1 Add light level display to plant detail page (shows current value or "Not set")
- [ ] 6.2 Add navigation entry to light assessment page from plant detail
- [ ] 6.3 Run `fvm flutter analyze` — fix any lint violations

## 7. Testing

- [ ] 7.1 Write unit tests for `LightAssessmentUseCases` (set, get, default null)
- [ ] 7.2 Write unit tests for care schedule engine light-level modifier logic
- [ ] 7.3 Write unit tests for camera brightness-to-level mapping
- [ ] 7.4 Run `fvm flutter test` — all tests pass
