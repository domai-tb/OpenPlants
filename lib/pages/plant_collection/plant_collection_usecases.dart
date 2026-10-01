import 'dart:io';

import 'package:flutter/foundation.dart';

import 'package:openplants/core/exceptions.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:openplants/pages/plant_collection/plant_collection_repository.dart';

/// Use cases for plant collection business logic.
class PlantCollectionUsecases {
  final PlantCollectionRepository repository;
  final Future<void> Function()? onNotificationsChanged;

  const PlantCollectionUsecases({required this.repository, this.onNotificationsChanged});

  /// Load all plants from storage.
  Future<List<PlantEntity>> loadPlants() => repository.loadPlants();

  /// Replace all persisted plants and refresh their scheduled notifications.
  Future<void> replaceAllPlants(List<PlantEntity> plants) async {
    await repository.replaceAllPlants(plants);
    await _syncNotifications();
  }

  /// Get a single plant by ID.
  ///
  /// Returns `null` if the plant is not found.
  Future<PlantEntity?> getPlantById(String id) async {
    final plants = await repository.loadPlants();
    for (final plant in plants) {
      if (plant.id == id) return plant;
    }
    return null;
  }

  /// Add a new plant to the collection.
  ///
  /// If [photoFile] is provided, it will be stored in the app's documents
  /// directory and the path will be saved on the entity.
  Future<PlantEntity> addPlant(PlantEntity plant, {File? photoFile}) async {
    final saved = await repository.addPlant(plant, photoFile: photoFile);
    await _syncNotifications();
    return saved;
  }

  /// Update an existing plant.
  ///
  /// If [photoFile] is provided, the old photo will be replaced safely:
  /// the new photo is staged first, then the entity is persisted, and only
  /// then is the old photo deleted.
  ///
  /// Throws [PhotoSaveFailure] if persistence fails after staging a new photo.
  /// Throws [PhotoClearFailure] if persistence fails when clearing a photo.
  Future<PlantEntity> updatePlant(PlantEntity plant, {File? photoFile}) async {
    late final PlantEntity saved;
    try {
      saved = await repository.updatePlant(plant, photoFile: photoFile);
    } on Exception catch (e) {
      // Classify the failure based on what was being attempted
      if (photoFile != null) {
        throw PhotoSaveFailure(plantId: plant.id, underlyingError: e);
      } else if (plant.photoPath == null) {
        throw PhotoClearFailure(plantId: plant.id, underlyingError: e);
      }
      rethrow;
    }
    await _syncNotifications();
    return saved;
  }

  /// Delete a plant by ID.
  ///
  /// Also removes the photo file from disk.
  Future<void> deletePlant(String id) async {
    await repository.deletePlant(id);
    await _syncNotifications();
  }

  /// Delete a plant photo while a pending deletion is being retried.
  Future<void> deletePhotoFile(String photoPath) => repository.deletePhotoFile(photoPath);

  /// Search plants by name substring.
  Future<List<PlantEntity>> searchPlants(String query) async {
    final plants = await repository.loadPlants();
    if (query.trim().isEmpty) return plants;

    final lowerQuery = query.toLowerCase();
    return plants.where((p) => p.name.toLowerCase().contains(lowerQuery)).toList();
  }

  /// Filter plants by care status.
  ///
  /// Returns all plants if [status] is null.
  Future<List<PlantEntity>> filterByCareStatus(CareStatus? status) async {
    final plants = await repository.loadPlants();
    if (status == null) return plants;

    return plants.where((p) => p.effectiveCareStatus == status).toList();
  }

  /// Mark a plant as watered.
  ///
  /// Updates the lastWateredAt timestamp and sets care status to happy
  /// if it was needs_water.
  Future<PlantEntity> markAsWatered(PlantEntity plant) async {
    final newStatus = plant.careStatus == CareStatus.needsWater ? CareStatus.happy : plant.careStatus;

    final updated = plant.copyWith(
      careStatus: newStatus,
      lastWateredAt: DateTime.now(),
    );

    final saved = await repository.updatePlant(updated);
    await _syncNotifications();
    return saved;
  }

  /// Mark a plant as fertilized.
  ///
  /// Updates the lastFertilizedAt timestamp and sets care status to happy
  /// if it was needs_fertilizer.
  Future<PlantEntity> markAsFertilized(PlantEntity plant) async {
    final newStatus = plant.careStatus == CareStatus.needsFertilizer ? CareStatus.happy : plant.careStatus;

    final updated = plant.copyWith(
      careStatus: newStatus,
      lastFertilizedAt: DateTime.now(),
    );

    final saved = await repository.updatePlant(updated);
    await _syncNotifications();
    return saved;
  }

  Future<void> _syncNotifications() async {
    try {
      await onNotificationsChanged?.call();
    } catch (error) {
      debugPrint('Failed to sync notifications after plant change: $error');
    }
  }
}
