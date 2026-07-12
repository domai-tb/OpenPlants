import 'dart:io';

import 'package:open_plant/pages/light_assessment/light_assessment_repository.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_photo_timeline/plant_photo_timeline_item_entity.dart';

/// Callback type for getting the latest photo.
typedef GetLatestPhotoFn = Future<PlantPhoto?> Function(String plantId);

/// Callback type for adding a photo.
typedef AddPhotoFn = Future<PlantPhoto> Function(String plantId, File image);

/// Use cases for light assessment business logic.
class LightAssessmentUseCases {
  final LightAssessmentRepository repository;
  final GetLatestPhotoFn _getLatestPhoto;
  final AddPhotoFn _addPhoto;

  const LightAssessmentUseCases({
    required this.repository,
    required GetLatestPhotoFn getLatestPhoto,
    required AddPhotoFn addPhoto,
  })  : _getLatestPhoto = getLatestPhoto,
        _addPhoto = addPhoto;

  /// Get the current light level for a plant. Returns null if not set.
  Future<LightLevel?> getLightLevel(String plantId) => repository.getLightLevel(plantId);

  /// Set the light level for a plant.
  Future<void> setLightLevel(String plantId, LightLevel level) => repository.setLightLevel(plantId, level);

  /// Clear the light level for a plant (reset to unset).
  Future<void> clearLightLevel(String plantId) => repository.clearLightLevel(plantId);

  /// Get the most recent photo for a plant, if any.
  Future<PlantPhoto?> getLatestPhoto(String plantId) => _getLatestPhoto(plantId);

  /// Add a photo to the plant's timeline and return it.
  Future<PlantPhoto> addPhoto(String plantId, File image) => _addPhoto(plantId, image);
}
