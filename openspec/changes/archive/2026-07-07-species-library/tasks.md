## 1. Species Data Model & Asset

- [x] 1.1 Create `lib/pages/species_library/` directory structure
- [x] 1.2 Create `lib/pages/species_library/species_library_item_entity.dart` — immutable `SpeciesEntity` class with all required fields (scientificName, commonNames, difficulty enum, lightNeeds enum, waterNeeds enum, humidityPreference enum, soilType, repottingIntervalMonths, toxicToHumans, toxicToPets, description, careSummary)
- [x] 1.3 Create `lib/pages/species_library/care_plan.dart` — immutable `CarePlan` value object with wateringGuidance, lightGuidance, humidityGuidance, soilRecommendation, repottingAdvice fields
- [x] 1.4 Create `assets/species/` directory and `assets/species/species.json` with a curated catalog of 20+ plant species covering all difficulty levels and care profiles
- [x] 1.5 Declare `assets/species/` in `pubspec.yaml` under `flutter: assets:`

## 2. Data Source & Repository

- [x] 2.1 Create `lib/pages/species_library/species_library_datasource.dart` — `SpeciesLibraryDatasource` that loads bundled JSON asset lazily with in-memory caching
- [x] 2.2 Create `lib/pages/species_library/species_library_repository.dart` — `SpeciesLibraryRepository` wrapping the datasource with `listAll()`, `search(String query)`, `findByScientificName(String name)`, and `filter({Difficulty? difficulty, bool? toxicOnly})` methods
- [x] 2.3 Implement case-insensitive and fuzzy (Levenshtein distance ≤ 2) scientific name matching in the repository

## 3. Use Cases

- [x] 3.1 Create `lib/pages/species_library/species_library_usecases.dart` — `SpeciesLibraryUsecases` exposing: `getAllSpecies()`, `searchSpecies(String query)`, `lookupSpecies(String scientificName)`, `filterSpecies({Difficulty? difficulty, bool? toxicOnly})`, and `generateCarePlan(SpeciesEntity species) -> CarePlan`
- [x] 3.2 Implement `generateCarePlan` with the enum-to-text translation logic for watering, light, humidity, and repotting guidance per care-plan spec

## 4. Species List Page

- [x] 4.1 Create `lib/pages/species_library/species_library_page.dart` — list page showing all species with scrollable list, each item showing common name, scientific name (italic), and difficulty indicator
- [x] 4.2 Add search bar with case-insensitive substring search across common names, scientific names, and descriptions
- [x] 4.3 Add difficulty filter chips (Easy, Moderate, Challenging) with multi-select and visual active state
- [x] 4.4 Add toxic-species-only toggle filter
- [x] 4.5 Implement empty state ("No species found") when search/filter yields no results
- [x] 4.6 Create `lib/pages/species_library/species_detail_page.dart` — detail page showing all species fields in structured layout with care plan section, toxicity warning highlights, and difficulty badge

## 5. Navigation & DI Wiring

- [x] 5.1 Register `SpeciesLibraryDatasource`, `SpeciesLibraryRepository`, and `SpeciesLibraryUsecases` as lazy singletons in `lib/core/injection.dart`
- [x] 5.2 Add `SpeciesLibraryUsecases` field to `AppServices` in `lib/core/app_services.dart` and wire in injection
- [x] 5.3 Add `PageItem.speciesLibrary` enum value in `lib/pages/home/page_navigator.dart`
- [x] 5.4 Add `PageItemPresentation` entry for species library with icon (e.g., `menu_book`) and l10n title
- [x] 5.5 Add navigator key and animation key entries in `lib/pages/home/home_page.dart` for the new page
- [x] 5.6 Add `_routeBuilders` case in `NavBarNavigator` for `PageItem.speciesLibrary`
- [x] 5.7 Add l10n strings for species library (page title, search hint, difficulty labels, care section headings, toxicity warnings)

## 6. Identification Integration

- [x] 6.1 Add `speciesForIdentifiedPlant(String scientificName)` method to `SpeciesLibraryUsecases` for cross-page lookup
- [x] 6.2 Update the plant identification results page to show a "View Species Details" button when the classified species exists in the library
- [x] 6.3 Implement cross-tab navigation: tapping "View Species Details" switches to the species library tab and pushes the species detail page

## 7. Polish & Verify

- [x] 7.1 Run `fvm flutter analyze` and fix any lint issues
- [x] 7.2 Run `fvm dart format --line-length=120 .` to format all files
- [x] 7.3 Add unit tests for repository (search, filter, fuzzy matching) and use-cases (care plan generation)
- [x] 7.4 Run `fvm flutter test` to verify all tests pass
