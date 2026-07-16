## 1. Preset Mapping Function

- [ ] 1.1 Create `lib/pages/care_schedule/species_care_presets.dart` with a pure function `speciesCarePresets(SpeciesEntity species) → List<CustomCareRuleEntity>` that maps species characteristics to 8 care rule templates
- [ ] 1.2 Implement interval lookup logic: watering (5/7/10d by WaterNeeds), fertilizing (14/21/30d by WaterNeeds), misting (3/5d or skip by HumidityPreference), pruning (30d), rotating (14d), repotting (months×30d), leaf cleaning (14d), pest inspection (21d)
- [ ] 1.3 Set default fields on generated rules: `isEnabled: true`, `reminderEnabled: false`, `reminderTime: null`, `reminderDays: null`, `createdAt: DateTime.now()`
- [ ] 1.4 Write unit tests for `speciesCarePresets` covering: all 8 types generated, high-humidity species misting (3d), low-humidity species skips misting, repotting interval scales with months, different WaterNeeds produce different watering/fertilizing intervals

## 2. Auto-Apply on Plant Creation

- [ ] 2.1 Modify `PlantCollectionRepository.addPlant` to accept an optional `SpeciesLibraryRepository` (or inject via constructor) for species lookup
- [ ] 2.2 After creating the `PlantEntity`, look up `plant.speciesName` in the species library via `findByScientificName`
- [ ] 2.3 If species found, call `speciesCarePresets(species)` and persist each generated rule via `CustomCareRuleRepository.createCustomCareRule`
- [ ] 2.4 If species not found or `speciesName` is null, skip preset creation (existing behavior)
- [ ] 2.5 Write integration tests: plant created with known species gets 8 rules, plant with unknown species gets 0 rules, plant without species gets 0 rules

## 3. DI Wiring

- [ ] 3.1 Ensure `SpeciesLibraryRepository` is accessible from `PlantCollectionRepository` (check `injection.dart` and `AppServices`)
- [ ] 3.2 Register any new dependencies in `lib/core/injection.dart` if needed
- [ ] 3.3 Verify `CustomCareRuleRepository` is accessible from `PlantCollectionRepository` for rule persistence

## 4. Verification

- [ ] 4.1 Run `fvm flutter analyze` — zero errors
- [ ] 4.2 Run `fvm flutter test` — all tests pass
- [ ] 4.3 Manual test: create a plant with a known species, verify 8 care rules appear in care schedule
- [ ] 4.4 Manual test: create a plant with unknown species, verify no care rules are created
