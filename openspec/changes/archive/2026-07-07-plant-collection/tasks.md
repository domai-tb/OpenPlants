## 1. Project Setup & Dependencies

- [x] 1.1 Add `path_provider` and `uuid` dependencies to `pubspec.yaml`
- [x] 1.2 Run `fvm flutter pub get` to resolve new dependencies

## 2. Data Layer — Entity

- [x] 2.1 Create `PlantEntity` class at `lib/pages/plant_collection/plant_collection_item_entity.dart` with fields: id (String), name (String), photoPath (String?), speciesName (String?), room (String?), notes (String?), careStatus (enum: happy/needs_water/needs_fertilizer), lastWateredAt (DateTime?), lastFertilizedAt (DateTime?), createdAt (DateTime), updatedAt (DateTime)
- [x] 2.2 Add `toJson()` / `fromJson()` serialization on `PlantEntity` and its `CareStatus` enum

## 3. Data Layer — Data Source & Repository

- [x] 3.1 Create `PlantCollectionDataSource` at `lib/pages/plant_collection/plant_collection_datasource.dart` — loads/saves plant list JSON from `shared_preferences` under key `plant_collection_v1`, manages photo file copy/deletion via local filesystem
- [x] 3.2 Create `PlantCollectionRepository` at `lib/pages/plant_collection/plant_collection_repository.dart` — maps data source CRUD to domain operations, handles ID generation with `uuid`

## 4. Business Logic — Use Cases

- [x] 4.1 Create `PlantCollectionUsecases` at `lib/pages/plant_collection/plant_collection_usecases.dart` with methods: `loadPlants()`, `addPlant(PlantEntity)`, `updatePlant(PlantEntity)`, `deletePlant(String id)`, `searchPlants(String query)`, `filterByCareStatus(CareStatus?)`
- [x] 4.2 Implement `addPlant` use-case — generates UUID, copies photo file to app documents directory, persists JSON
- [x] 4.3 Implement `deletePlant` use-case — removes photo file from disk, removes entity from list, persists JSON

## 5. Dependency Injection Wiring

- [x] 5.1 Register `PlantCollectionDataSource`, `PlantCollectionRepository`, `PlantCollectionUsecases` as lazy singletons in `lib/core/injection.dart`
- [x] 5.2 Add `PlantCollectionUsecases plantCollection` field to `AppServices` in `lib/core/app_services.dart` and wire in constructor

## 6. UI — Collection List Page

- [x] 6.1 Create `PlantCollectionPage` at `lib/pages/plant_collection/plant_collection_page.dart` — StatefulWidget with collection list, empty state, floating action button for add, search bar, and care-status filter chips
- [x] 6.2 Build plant list tile widget showing name, species, room badge, and care status indicator

## 7. UI — Add/Edit Plant Form

- [x] 7.1 Create add/edit plant form as a new route with fields: name (required TextField), photo (ImagePicker gallery button with preview), species (TextField), room (TextField), notes (multiline TextField), care status (segmented control)
- [x] 7.2 Implement photo picking via `image_picker` with preview and replace/remove controls

## 8. UI — Plant Detail View

- [x] 8.1 Create plant detail page with full-size photo, name, species, room, notes, care status, last-watered/fertilized dates, and edit/delete action buttons
- [x] 8.2 Add "Mark as watered" and "Mark as fertilized" action buttons that update the entity and reset care status to happy when appropriate

## 9. Navigation Integration

- [x] 9.1 Add `PageItem.plantCollection` to the `PageItem` enum in `lib/pages/home/page_navigator.dart`
- [x] 9.2 Add case for `PageItem.plantCollection` in `pageItemPresentation()` with title from l10n and an appropriate icon (e.g., `Icons.yard`)
- [x] 9.3 Add `PageItem.plantCollection` routed to `PlantCollectionPage` in `NavBarNavigator._routeBuilders()`
- [x] 9.4 Add plant_collection navigator keys in `HomePage` (navigatorKeys, exitAnimationKeys, entryAnimationKeys)

## 10. L10n & Settings

- [x] 10.1 Add l10n strings to asset ARB files: `plantCollectionTitle`, `plantCollectionEmpty`, `addPlant`, `editPlant`, `deletePlant`, `careStatusHappy`, `careStatusNeedsWater`, `careStatusNeedsFertilizer`, `markAsWatered`, `markAsFertilized`, `lastWatered`, `lastFertilized`, `confirmDelete`, `searchPlants`, `room`, `species`, `notes`, `photo`
- [x] 10.2 Run `fvm flutter gen-l10n` to regenerate localizations
- [x] 10.3 Update default `navBarItemOrder` in `Settings` to include `'plant_collection'`

## 11. Verification

- [x] 11.1 Run `fvm flutter analyze` and resolve any lint issues
- [x] 11.2 Run `fvm flutter test` to verify existing tests still pass
- [x] 11.3 Manual smoke test: add a plant with photo, verify it appears in list, edit it, delete it, confirm photo file cleanup
