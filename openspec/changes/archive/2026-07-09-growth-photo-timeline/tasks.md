## 1. Entity & Data Model

- [x] 1.1 Create `PlantPhoto` value object in `lib/pages/plantPhotoTimeline/plant_photo_timeline_item_entity.dart` with fields: `id` (String), `date` (DateTime), `filePath` (String), `caption` (String?)
- [x] 1.2 Add `List<PlantPhoto> photos` field to existing plant entity with JSON serialization (defaults to empty list)
- [x] 1.3 Add `PlantPhoto` JSON serialization/deserialization helpers

## 2. Photo Datasource

- [x] 2.1 Create `lib/pages/plantPhotoTimeline/plant_photo_timeline_datasource.dart` with file I/O methods
- [x] 2.2 Implement `savePhotoFile(String plantId, File image)` → saves compressed JPEG to `plant_photos/{plantId}/{photoId}.jpg`
- [x] 2.3 Implement `deletePhotoFile(String filePath)` → removes photo file from disk
- [x] 2.4 Implement `loadPhotoMetadata(String plantId)` → reads photo list from plant entity
- [x] 2.5 Implement `savePhotoMetadata(String plantId, List<PlantPhoto> photos)` → persists updated photo list

## 3. Photo Repository

- [x] 3.1 Create `lib/pages/plantPhotoTimeline/plant_photo_timeline_repository.dart`
- [x] 3.2 Implement `addPhoto(String plantId, File image, DateTime date, String? caption)` → saves file + metadata, returns PlantPhoto
- [x] 3.3 Implement `deletePhoto(String plantId, String photoId)` → removes file + metadata entry
- [x] 3.4 Implement `getTimeline(String plantId)` → returns photos sorted newest-first
- [x] 3.5 Implement `updatePhotoDate(String plantId, String photoId, DateTime newDate)` → updates date and re-sorts

## 4. Photo Use-Cases

- [x] 4.1 Create `lib/pages/plantPhotoTimeline/plant_photo_timeline_usecases.dart`
- [x] 4.2 Implement `AddPhotoUseCase` — validates input, calls repository
- [x] 4.3 Implement `DeletePhotoUseCase` — confirms deletion, calls repository
- [x] 4.4 Implement `GetPhotoTimelineUseCase` — retrieves sorted timeline
- [x] 4.5 Implement `UpdatePhotoDateUseCase` — updates date and returns refreshed timeline

## 5. UI — Plant Detail Photo Strip

- [x] 5.1 Add "Growth Photos" section to plant detail page with horizontal scrollable thumbnail strip
- [x] 5.2 Implement thumbnail tap → navigates to full-screen timeline view
- [x] 5.3 Implement "Add Photo" button in the strip → opens camera/gallery picker
- [x] 5.4 Show empty state when no photos exist ("Add your first growth photo")

## 6. UI — Full-Screen Timeline

- [x] 6.1 Create `lib/pages/plantPhotoTimeline/plant_photo_timeline_page.dart` with vertical scrollable timeline
- [x] 6.2 Display photos in reverse-chronological order with date labels
- [x] 6.3 Implement thumbnail tap → full-screen photo view with swipe navigation
- [x] 6.4 Implement back/swipe-down to close full-screen view
- [x] 6.5 Implement long-press on photo → delete confirmation dialog
- [x] 6.6 Implement tap on date label → date picker to edit photo date

## 7. DI & Integration

- [x] 7.1 Register `PlantPhotoTimelineDataSource`, `PlantPhotoTimelineRepository`, and use-cases in `lib/core/injection.dart`
- [x] 7.2 Add use-cases to `AppServices` constructor and fields in `app_services.dart`
- [x] 7.3 Add navigation entry from plant detail page to timeline view

## 8. Cleanup & Edge Cases

- [x] 8.1 Ensure plant deletion cascades to delete all photo files from disk
- [x] 8.2 Handle photo file missing gracefully (show placeholder in timeline)
- [x] 8.3 Compress images before saving to control storage usage

## 9. Verification

- [x] 9.1 Run `fvm flutter analyze` — zero lint violations
- [x] 9.2 Run `fvm flutter test` — all tests pass
- [x] 9.3 Manual test: add photos to a plant, view timeline, swipe full-screen, delete photo, edit date
