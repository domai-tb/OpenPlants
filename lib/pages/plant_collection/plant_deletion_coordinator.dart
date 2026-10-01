import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/plant_collection/plant_data_cleanup.dart';

/// Persists which plant deletions need to resume after a partial failure.
class PendingPlantDeletionDataSource {
  static const String _keyPrefix = 'pending_plant_deletion_v1_';
  static const String _photoPathKeyPrefix = 'pending_plant_deletion_photo_v1_';

  final SharedPreferences? _prefsOverride;

  PendingPlantDeletionDataSource({SharedPreferences? prefs}) : _prefsOverride = prefs;

  Future<void> markPending(String plantId, {String? photoPath}) async {
    final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
    if (photoPath != null) {
      final savedPhotoPath = await prefs.setString('$_photoPathKeyPrefix$plantId', photoPath);
      if (!savedPhotoPath) {
        throw StateError('Failed to persist the pending photo path for plant "$plantId".');
      }
    }
    final saved = await prefs.setBool('$_keyPrefix$plantId', true);
    if (!saved) {
      throw StateError('Failed to persist pending deletion for plant "$plantId".');
    }
  }

  Future<List<String>> loadPendingPlantIds() async {
    final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
    return prefs
        .getKeys()
        .where((key) => key.startsWith(_keyPrefix))
        .map((key) => key.substring(_keyPrefix.length))
        .where((plantId) => plantId.isNotEmpty)
        .toList();
  }

  Future<String?> loadPhotoPath(String plantId) async {
    final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
    return prefs.getString('$_photoPathKeyPrefix$plantId');
  }

  Future<void> clearPending(String plantId) async {
    try {
      final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
      final photoPathKey = '$_photoPathKeyPrefix$plantId';
      if (prefs.containsKey(photoPathKey) && !await prefs.remove(photoPathKey)) {
        debugPrint('Failed to clear pending photo path for plant "$plantId".');
        return;
      }
      final removed = await prefs.remove('$_keyPrefix$plantId');
      if (!removed) {
        debugPrint('Failed to clear pending deletion marker for plant "$plantId".');
      }
    } catch (error) {
      debugPrint('Failed to clear pending deletion marker for plant "$plantId": $error');
    }
  }
}

/// Coordinates child cleanup and plant removal with restart-safe retries.
class PlantDeletionCoordinator {
  final PlantCollectionUsecases _plantCollection;
  final PlantDataCleanup _dataCleanup;
  final PendingPlantDeletionDataSource _pendingDeletes;

  const PlantDeletionCoordinator({
    required PlantCollectionUsecases plantCollection,
    required PlantDataCleanup dataCleanup,
    required PendingPlantDeletionDataSource pendingDeletes,
  })  : _plantCollection = plantCollection,
        _dataCleanup = dataCleanup,
        _pendingDeletes = pendingDeletes;

  /// Completes a plant deletion, leaving a durable marker if it fails.
  Future<void> deletePlant(String plantId) async {
    final plant = await _plantCollection.getPlantById(plantId);
    final photoPath = plant?.photoPath ?? await _pendingDeletes.loadPhotoPath(plantId);
    await _pendingDeletes.markPending(plantId, photoPath: photoPath);
    await _plantCollection.deletePlant(plantId);
    if (photoPath != null) await _plantCollection.deletePhotoFile(photoPath);
    await _dataCleanup.deleteAllForPlant(plantId);
    await _pendingDeletes.clearPending(plantId);
  }

  /// Retries interrupted deletions before the app displays the plant list.
  Future<void> retryPendingDeletions() async {
    late final List<String> pendingPlantIds;
    try {
      pendingPlantIds = await _pendingDeletes.loadPendingPlantIds();
    } catch (error) {
      debugPrint('Failed to load pending plant deletions: $error');
      return;
    }

    for (final plantId in pendingPlantIds) {
      try {
        await deletePlant(plantId);
      } catch (error) {
        debugPrint('Failed to retry deletion for plant "$plantId": $error');
      }
    }
  }
}
