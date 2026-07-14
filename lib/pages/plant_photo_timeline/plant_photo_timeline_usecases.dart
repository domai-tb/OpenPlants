import 'dart:io';

import 'package:open_plants/pages/plant_photo_timeline/plant_photo_timeline_repository.dart';
import 'package:open_plants/pages/plant_photo_timeline/plant_photo_timeline_item_entity.dart';

/// Use-cases for the plant photo timeline feature.
class PlantPhotoTimelineUseCases {
  final PlantPhotoTimelineRepository repository;

  const PlantPhotoTimelineUseCases({required this.repository});

  /// Add a photo to a plant's timeline with the given [date] and optional [caption].
  Future<PlantPhoto> addPhoto(
    String plantId,
    File image, {
    DateTime? date,
    String? caption,
  }) {
    return repository.addPhoto(plantId, image, date: date, caption: caption);
  }

  /// Delete a photo from a plant's timeline.
  Future<void> deletePhoto(String plantId, String photoId) {
    return repository.deletePhoto(plantId, photoId);
  }

  /// Get the photo timeline for a plant, sorted newest-first.
  Future<List<PlantPhoto>> getTimeline(String plantId) {
    return repository.getTimeline(plantId);
  }

  /// Update the date of a photo and return the refreshed timeline.
  Future<List<PlantPhoto>> updatePhotoDate(
    String plantId,
    String photoId,
    DateTime newDate,
  ) {
    return repository.updatePhotoDate(plantId, photoId, newDate);
  }

  /// Delete all photo files for a plant (used during plant deletion).
  Future<void> deleteAllPhotos(String plantId) {
    return repository.deleteAllPhotos(plantId);
  }
}
