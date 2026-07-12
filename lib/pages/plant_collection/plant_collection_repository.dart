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
  /// If [photoFile] is provided, the old photo will be deleted and the new
  /// one will be copied to the app's documents directory.
  Future<PlantEntity> updatePlant(
    PlantEntity plant, {
    File? photoFile,
  }) async {
    final plants = await dataSource.loadPlants();
    final index = plants.indexWhere((p) => p.id == plant.id);

    if (index == -1) {
      throw Exception('Plant not found: ${plant.id}');
    }

    String? photoPath = plant.photoPath;

    if (photoFile != null) {
      // Delete old photo if it exists
      if (plant.photoPath != null) {
        await dataSource.deletePhoto(plant.photoPath!);
      }
      // Copy new photo
      photoPath = await dataSource.savePhoto(photoFile, plant.id);
    }

    final updatedPlant = plant.copyWith(
      photoPath: photoPath,
      clearPhoto: photoPath == null,
      updatedAt: DateTime.now(),
    );

    plants[index] = updatedPlant;
    await dataSource.savePlants(plants);

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
