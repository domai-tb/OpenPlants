import 'dart:io';

import 'package:uuid/uuid.dart';

import 'package:open_plants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';

/// Repository for plant collection domain operations.
///
/// Maps data source CRUD to domain operations and handles ID generation.
class PlantCollectionRepository {
  final PlantCollectionDataSource dataSource;
  final Uuid _uuid;

  PlantCollectionRepository({required this.dataSource}) : _uuid = const Uuid();

  /// Load all plants.
  Future<List<PlantEntity>> loadPlants() => dataSource.loadPlants();

  /// Add a new plant with a generated UUID.
  ///
  /// If [photoFile] is provided, it will be copied to the app's documents
  /// directory and the path will be stored on the entity.
  Future<PlantEntity> addPlant(PlantEntity plant, {File? photoFile}) async {
    final id = _uuid.v4();
    String? photoPath;

    if (photoFile != null) {
      photoPath = await dataSource.savePhoto(photoFile, id);
    }

    final now = DateTime.now();
    final newPlant = plant.copyWith(
      id: id,
      photoPath: photoPath,
      createdAt: now,
      updatedAt: now,
    );

    final plants = await dataSource.loadPlants();
    plants.add(newPlant);
    await dataSource.savePlants(plants);

    return newPlant;
  }

  /// Update an existing plant.
  ///
  /// If [photoFile] is provided, the new photo is staged first, then the
  /// entity is persisted, and only then is the old photo deleted. This
  /// ensures the old photo is retained if persistence fails.
  ///
  /// If persistence fails after staging a new photo, the staged file is
  /// cleaned up and a classified failure is reported.
  ///
  /// If clearing the photo, the old photo is deleted only after persistence
  /// succeeds.
  Future<PlantEntity> updatePlant(
    PlantEntity plant, {
    File? photoFile,
  }) async {
    final plants = await dataSource.loadPlants();
    final index = plants.indexWhere((p) => p.id == plant.id);

    if (index == -1) {
      throw Exception('Plant not found: ${plant.id}');
    }

    final existingPlant = plants[index];
    String? photoPath = plant.photoPath;
    String? stagedPhotoPath;

    if (photoFile != null) {
      // Stage the new photo first (before deleting old)
      stagedPhotoPath = await dataSource.savePhoto(photoFile, plant.id);
      photoPath = stagedPhotoPath;
    }

    final updatedPlant = plant.copyWith(
      photoPath: photoPath,
      clearPhoto: photoPath == null && existingPlant.photoPath != null,
      updatedAt: DateTime.now(),
    );

    try {
      plants[index] = updatedPlant;
      await dataSource.savePlants(plants);
    } catch (e) {
      // Persistence failed — clean up staged photo if any
      if (stagedPhotoPath != null) {
        await dataSource.deletePhoto(stagedPhotoPath);
      }
      rethrow;
    }

    // Persistence succeeded — now safe to delete old photo
    if (photoFile != null && existingPlant.photoPath != null) {
      await dataSource.deletePhoto(existingPlant.photoPath!);
    } else if (photoPath == null && existingPlant.photoPath != null) {
      await dataSource.deletePhoto(existingPlant.photoPath!);
    }

    return updatedPlant;
  }

  /// Delete a plant by ID.
  ///
  /// Also deletes the photo file from disk if it exists.
  Future<void> deletePlant(String id) async {
    final plants = await dataSource.loadPlants();
    final index = plants.indexWhere((p) => p.id == id);

    if (index == -1) {
      return;
    }

    final plant = plants[index];

    // Delete photo file
    if (plant.photoPath != null) {
      await dataSource.deletePhoto(plant.photoPath!);
    }

    plants.removeAt(index);
    await dataSource.savePlants(plants);
  }

  /// Replace a plant in the collection (used by other repositories).
  Future<void> replacePlant(PlantEntity plant) async {
    final plants = await dataSource.loadPlants();
    final index = plants.indexWhere((p) => p.id == plant.id);

    if (index == -1) {
      throw Exception('Plant not found: ${plant.id}');
    }

    plants[index] = plant;
    await dataSource.savePlants(plants);
  }
}
