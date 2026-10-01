import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import 'package:openplants/pages/care_schedule/care_schedule_repository.dart';
import 'package:openplants/pages/care_schedule/species_care_presets.dart';
import 'package:openplants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:openplants/pages/species_library/species_library_repository.dart';

/// Repository for plant collection domain operations.
///
/// Maps data source CRUD to domain operations and handles ID generation.
class PlantCollectionRepository {
  final PlantCollectionDataSource dataSource;
  final SpeciesLibraryRepository? speciesLibrary;
  final CareScheduleRepository? careSchedule;
  final Uuid _uuid;

  PlantCollectionRepository({
    required this.dataSource,
    this.speciesLibrary,
    this.careSchedule,
  }) : _uuid = const Uuid();

  /// Load all plants.
  Future<List<PlantEntity>> loadPlants() => dataSource.loadPlants();

  /// Replace the persisted plant collection.
  Future<void> replaceAllPlants(List<PlantEntity> plants) => dataSource.savePlants(plants);

  /// Add a new plant with a generated UUID.
  ///
  /// If [photoFile] is provided, it will be copied to the app's documents
  /// directory and the path will be stored on the entity.
  ///
  /// When a species name is provided and matches a known species in the
  /// library, preset care rules are auto-populated for the new plant.
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

    try {
      final plants = await dataSource.loadPlants();
      plants.add(newPlant);
      await dataSource.savePlants(plants);
    } catch (_) {
      if (photoPath != null) {
        await _deletePhotoBestEffort(photoPath);
      }
      rethrow;
    }

    // Apply species care presets if species is known. Best-effort: preset
    // failures must not roll back the plant creation that already succeeded.
    try {
      await _applySpeciesPresets(newPlant);
    } catch (_) {
      // Presets are supplementary; plant already persisted.
    }

    return newPlant;
  }

  /// Look up the plant's species and persist preset care rules if found.
  Future<void> _applySpeciesPresets(PlantEntity plant) async {
    if (speciesLibrary == null || careSchedule == null) return;
    if (plant.speciesName == null || plant.speciesName!.isEmpty) return;

    final species = await speciesLibrary!.findByScientificName(plant.speciesName!);
    if (species == null) return;

    final presets = speciesCarePresets(species, plantId: plant.id);
    for (final rule in presets) {
      await careSchedule!.saveCustomCareRule(rule);
    }
  }

  /// Update an existing plant.
  ///
  /// If [photoFile] is provided, the new photo is staged first, then the
  /// entity is persisted, and only then is deletion of the old photo attempted.
  /// This ensures the old photo is retained if persistence fails.
  ///
  /// If persistence fails after staging a new photo, cleanup is attempted
  /// without replacing the persistence error if cleanup also fails.
  ///
  /// If clearing the photo, deletion of the old photo is attempted only after
  /// persistence succeeds.
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
    } catch (_) {
      // Persistence failed — clean up staged photo if any
      if (stagedPhotoPath != null) {
        await _deletePhotoBestEffort(stagedPhotoPath);
      }
      rethrow;
    }

    // Persistence succeeded — now safe to attempt deleting the old photo.
    if (existingPlant.photoPath != null && existingPlant.photoPath != photoPath) {
      await _deletePhotoBestEffort(existingPlant.photoPath!);
    }

    return updatedPlant;
  }

  /// Delete a plant by ID.
  ///
  /// Also attempts to delete the photo file from disk if it exists.
  Future<void> deletePlant(String id) async {
    final plants = await dataSource.loadPlants();
    final index = plants.indexWhere((p) => p.id == id);

    if (index == -1) {
      return;
    }

    final plant = plants[index];

    plants.removeAt(index);
    await dataSource.savePlants(plants);

    // Commit the removal first so the collection cannot point at a missing photo.
    if (plant.photoPath != null) {
      await _deletePhotoBestEffort(plant.photoPath!);
    }
  }

  Future<void> deletePhotoFile(String photoPath) => dataSource.deletePhoto(photoPath);

  Future<void> _deletePhotoBestEffort(String photoPath) async {
    try {
      await dataSource.deletePhoto(photoPath);
    } catch (error) {
      debugPrint('Failed to delete plant photo "$photoPath": $error');
    }
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
