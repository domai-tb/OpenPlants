import 'dart:io';

import 'package:open_plants/core/exceptions.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_repository.dart';

/// Use cases for plant collection business logic.
class PlantCollectionUsecases {
  final PlantCollectionRepository repository;

  const PlantCollectionUsecases({required this.repository});

  /// Load all plants from storage.
  Future<List<PlantEntity>> loadPlants() => repository.loadPlants();

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
  Future<PlantEntity> addPlant(PlantEntity plant, {File? photoFile}) {
    return repository.addPlant(plant, photoFile: photoFile);
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
    try {
      return await repository.updatePlant(plant, photoFile: photoFile);
    } on Exception catch (e) {
      // Classify the failure based on what was being attempted
      if (photoFile != null) {
        throw PhotoSaveFailure(plantId: plant.id, underlyingError: e);
      } else if (plant.photoPath == null) {
        throw PhotoClearFailure(plantId: plant.id, underlyingError: e);
      }
      rethrow;
    }
  }

  /// Delete a plant by ID.
  ///
  /// Also removes the photo file from disk.
  Future<void> deletePlant(String id) => repository.deletePlant(id);

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

    return repository.updatePlant(updated);
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

    return repository.updatePlant(updated);
  }
}
