## Why

Users currently take photos of plants for identification but have no way to track visual changes over time. Without dated photo history, users cannot compare growth, detect decline early, or visually verify that care changes are working. A growth photo timeline gives users actionable visual feedback on plant health progression.

## What Changes

- Each plant gains a photo timeline: a chronological list of dated photos stored locally.
- Users can add a photo to any plant from the plant detail screen, with the current date auto-assigned (editable).
- Photos display in reverse-chronological order (newest first) with date labels.
- Users can tap a photo to view it full-screen, and swipe between photos in the timeline.
- Photo storage uses the device's local file system (no cloud sync in this phase).
- Existing plant entity gets a `photos` field to hold the photo list.

## Capabilities

### New Capabilities
- `plant-photo-timeline`: Core capability for storing, displaying, and navigating dated growth photos per plant.

### Modified Capabilities
- `plant-inventory`: Plant entity extended with a `photos` field (list of dated photo references).

## Impact

- **Code**: New feature module `lib/pages/plantPhotoTimeline/` following the 5-file pattern. Entity changes in `plant_inventory`.
- **Dependencies**: None new — uses existing `shared_preferences` for metadata and local file storage for images.
- **Storage**: Photo files stored in app's documents directory. Metadata (dates, file paths) stored in local DB or preferences.
- **UI**: Plant detail screen needs a "Growth Photos" section. Navigation to the timeline view.
