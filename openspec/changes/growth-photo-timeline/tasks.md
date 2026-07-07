## 1. Entity & Data Model

- [ ] 1.1 Create `PlantPhoto` value object in `lib/pages/plantPhotoTimeline/plantPhoto_item_entity.dart` with fields: `id` (String), `date` (DateTime), `filePath` (String), `caption` (String?)
- [ ] 1.2 Add `List<PlantPhoto> photos` field to existing plant entity with JSON serialization (defaults to empty list)
- [ ] 1.3 Add `PlantPhoto` JSON serialization/deserialization helpers

## 2. Photo Datasource

- [ ] 2.1 Create `lib/pages/plantPhotoTimeline/plantPhotoTimeline_datasource.dart` with file I/O methods
- [ ] 2.2 Implement `savePhotoFile(String plantId, File image)` → saves compressed JPEG to `plant_photos/{plantId}/{photoId}.jpg`
- [ ] 2.3 Implement `deletePhotoFile(String filePath)` → removes photo file from disk
- [ ] 2.4 Implement `loadPhotoMetadata(String plantId)` → reads photo list from plant entity
- [ ] 2.5 Implement `savePhotoMetadata(String plantId, List<PlantPhoto> photos)` → persists updated photo list

## 3. Photo Repository

- [ ] 3.1 Create `lib/pages/plantPhotoTimeline/plantPhotoTimeline_repository.dart`
- [ ] 3.2 Implement `addPhoto(String plantId, File image, DateTime date, String? caption)` → saves file + metadata, returns PlantPhoto
- [ ] 3.3 Implement `deletePhoto(String plantId, String photoId)` → removes file + metadata entry
- [ ] 3.4 Implement `getTimeline(String plantId)` → returns photos sorted newest-first
- [ ] 3.5 Implement `updatePhotoDate(String plantId, String photoId, DateTime newDate)` → updates date and re-sorts

## 4. Photo Use-Cases

- [ ] 4.1 Create `lib/pages/plantPhotoTimeline/plantPhotoTimeline_usecases.dart`
- [ ] 4.2 Implement `AddPhotoUseCase` — validates input, calls repository
- [ ] 4.3 Implement `DeletePhotoUseCase` — confirms deletion, calls repository
- [ ] 4.4 Implement `GetPhotoTimelineUseCase` — retrieves sorted timeline
- [ ] 4.5 Implement `UpdatePhotoDateUseCase` — updates date and returns refreshed timeline

## 5. UI — Plant Detail Photo Strip

- [ ] 5.1 Add "Growth Photos" section to plant detail page with horizontal scrollable thumbnail strip
- [ ] 5.2 Implement thumbnail tap → navigates to full-screen timeline view
- [ ] 5.3 Implement "Add Photo" button in the strip → opens camera/gallery picker
- [ ] 5.4 Show empty state when no photos exist ("Add your first growth photo")

## 6. UI — Full-Screen Timeline

- [ ] 6.1 Create `lib/pages/plantPhotoTimeline/plantPhotoTimeline_page.dart` with vertical scrollable timeline
- [ ] 6.2 Display photos in reverse-chronological order with date labels
- [ ] 6.3 Implement thumbnail tap → full-screen photo view with swipe navigation
- [ ] 6.4 Implement back/swipe-down to close full-screen view
- [ ] 6.5 Implement long-press on photo → delete confirmation dialog
- [ ] 6.6 Implement tap on date label → date picker to edit photo date

## 7. DI & Integration

- [ ] 7.1 Register `PlantPhotoTimelineDatasource`, `PlantPhotoTimelineRepository`, and use-cases in `lib/core/injection.dart`
- [ ] 7.2 Add use-cases to `AppServices` constructor and fields in `app_services.dart`
- [ ] 7.3 Add navigation entry from plant detail page to timeline view

## 8. Cleanup & Edge Cases

- [ ] 8.1 Ensure plant deletion cascades to delete all photo files from disk
- [ ] 8.2 Handle photo file missing gracefully (show placeholder in timeline)
- [ ] 8.3 Compress images before saving to control storage usage

## 9. Verification

- [ ] 9.1 Run `fvm flutter analyze` — zero lint violations
- [ ] 9.2 Run `fvm flutter test` — all tests pass
- [ ] 9.3 Manual test: add photos to a plant, view timeline, swipe full-screen, delete photo, edit date
