import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:openplants/pages/plant_collection/plant_collection_repository.dart';
import 'package:openplants/pages/plant_photo_timeline/plant_photo_timeline_datasource.dart';
import 'package:openplants/pages/plant_photo_timeline/plant_photo_timeline_item_entity.dart';

/// Repository for plant growth photo domain operations.
///
/// Coordinates file I/O via [PlantPhotoTimelineDataSource] and
/// metadata persistence via [PlantCollectionRepository].
class PlantPhotoTimelineRepository {
  final PlantPhotoTimelineDataSource dataSource;
  final PlantCollectionRepository plantCollection;
  final Uuid _uuid;

  PlantPhotoTimelineRepository({
    required this.dataSource,
    required this.plantCollection,
  }) : _uuid = const Uuid();

  /// Add a photo to a plant's timeline.
  ///
  /// Saves the image file to disk and persists metadata in the plant entity.
  /// Returns the created [PlantPhoto].
  Future<PlantPhoto> addPhoto(
    String plantId,
    File image, {
    DateTime? date,
    String? caption,
  }) async {
    final plants = await plantCollection.loadPlants();
    final plant = plants.firstWhere(
      (p) => p.id == plantId,
      orElse: () => throw Exception('Plant not found: $plantId'),
    );

    final photoId = _uuid.v4();
    final filePath = await dataSource.savePhotoFile(image, plantId);

    final photo = PlantPhoto(
      id: photoId,
      date: date ?? DateTime.now(),
      filePath: filePath,
      caption: caption,
    );

    final updatedPlant = plant.copyWith(
      photos: [...plant.photos, photo],
      updatedAt: DateTime.now(),
    );

    try {
      await plantCollection.replacePlant(updatedPlant);
    } catch (_) {
      await _deletePhotoFileBestEffort(filePath);
      rethrow;
    }

    return photo;
  }

  /// Delete a photo from a plant's timeline.
  ///
  /// Removes the metadata entry, then attempts to delete the file from disk.
  Future<void> deletePhoto(String plantId, String photoId) async {
    final plants = await plantCollection.loadPlants();
    final plant = plants.firstWhere(
      (p) => p.id == plantId,
      orElse: () => throw Exception('Plant not found: $plantId'),
    );

    final photoIndex = plant.photos.indexWhere((p) => p.id == photoId);
    if (photoIndex == -1) return;

    final photo = plant.photos[photoIndex];

    final updatedPhotos = List<PlantPhoto>.from(plant.photos)..removeAt(photoIndex);
    final updatedPlant = plant.copyWith(
      photos: updatedPhotos,
      updatedAt: DateTime.now(),
    );

    await plantCollection.replacePlant(updatedPlant);
    await _deletePhotoFileBestEffort(photo.filePath);
  }

  /// Get the photo timeline for a plant, sorted newest-first.
  Future<List<PlantPhoto>> getTimeline(String plantId) async {
    final plants = await plantCollection.loadPlants();
    final plant = plants.firstWhere(
      (p) => p.id == plantId,
      orElse: () => throw Exception('Plant not found: $plantId'),
    );

    final sorted = List<PlantPhoto>.from(plant.photos)..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Update the date of a photo and re-sort the timeline.
  Future<List<PlantPhoto>> updatePhotoDate(
    String plantId,
    String photoId,
    DateTime newDate,
  ) async {
    final plants = await plantCollection.loadPlants();
    final plant = plants.firstWhere(
      (p) => p.id == plantId,
      orElse: () => throw Exception('Plant not found: $plantId'),
    );

    final updatedPhotos = plant.photos.map((p) {
      if (p.id == photoId) {
        return p.copyWith(date: newDate);
      }
      return p;
    }).toList();

    final updatedPlant = plant.copyWith(
      photos: updatedPhotos,
      updatedAt: DateTime.now(),
    );

    await plantCollection.replacePlant(updatedPlant);

    final sorted = List<PlantPhoto>.from(updatedPhotos)..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  /// Clear photo metadata and attempt to delete all associated files.
  Future<void> deleteAllPhotos(String plantId) async {
    final plants = await plantCollection.loadPlants();
    final plantIndex = plants.indexWhere((p) => p.id == plantId);
    if (plantIndex == -1) {
      await _deleteAllPhotoFiles(plantId);
      return;
    }

    final plant = plants[plantIndex];
    if (plant.photos.isNotEmpty) {
      final updatedPlant = plant.copyWith(
        photos: const [],
        updatedAt: DateTime.now(),
      );
      await plantCollection.replacePlant(updatedPlant);
    }

    await _deleteAllPhotoFiles(plantId);
  }

  Future<void> _deletePhotoFileBestEffort(String filePath) async {
    try {
      await dataSource.deletePhotoFile(filePath);
    } catch (error) {
      debugPrint('Failed to delete timeline photo "$filePath": $error');
    }
  }

  Future<void> _deleteAllPhotoFiles(String plantId) async {
    try {
      await dataSource.deleteAllPhotoFiles(plantId);
    } catch (error) {
      debugPrint('Failed to delete timeline photos for plant "$plantId": $error');
      rethrow;
    }
  }
}
