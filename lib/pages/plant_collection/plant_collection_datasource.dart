import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/exceptions.dart';
import 'package:open_plants/core/local_collection_codec.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';

/// Data source for plant collection persistence.
///
/// Stores plant metadata as JSON in shared_preferences and
/// manages photo files in the app's documents directory.
///
/// Uses [LocalCollectionCodec] to distinguish missing keys from corruption,
/// preserve raw values on failure, and block mutations after a decode failure.
class PlantCollectionDataSource {
  static const String _prefsKey = 'plant_collection_v1';
  static const String _photoSubdir = 'plant_photos';

  final SharedPreferences? _prefsOverride;
  LocalCollectionCodec<PlantEntity>? _codec;

  PlantCollectionDataSource({SharedPreferences? prefs}) : _prefsOverride = prefs;

  /// Returns the codec, initializing it lazily on first access.
  Future<LocalCollectionCodec<PlantEntity>> _getCodec() async {
    if (_codec == null) {
      final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
      _codec = LocalCollectionCodec<PlantEntity>(
        prefs: prefs,
        key: _prefsKey,
        fromJson: PlantEntity.fromJson,
        toJson: (e) => e.toJson(),
        keyExtractor: (e) => e.id,
      );
    }
    return _codec!;
  }

  /// Load all plants from shared_preferences.
  ///
  /// Returns an empty list when the key is absent.
  /// Throws [CollectionDecodeFailure], [CollectionShapeFailure], or
  /// [RecordDecodeFailure] when stored data is malformed.
  Future<List<PlantEntity>> loadPlants() async {
    final codec = await _getCodec();
    final result = await codec.load();
    if (result.isFailure) {
      throw result.asFailure!;
    }
    return result.asSuccess;
  }

  /// Whether the collection is in a corrupted state that blocks mutations.
  Future<bool> get isBlocked async {
    final codec = await _getCodec();
    return codec.isBlocked;
  }

  /// Save plant list to shared_preferences.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the most recent [loadPlants] call
  /// detected corruption.
  Future<void> savePlants(List<PlantEntity> plants) async {
    final codec = await _getCodec();
    await codec.save(plants);
  }

  /// Append a plant to the collection.
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> addPlant(PlantEntity plant) async {
    final codec = await _getCodec();
    await codec.add(plant);
  }

  /// Replace a plant identified by its [id].
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> updatePlant(PlantEntity plant) async {
    final codec = await _getCodec();
    await codec.update(plant, matchKey: (e) => e.id);
  }

  /// Remove a plant by its [id].
  ///
  /// Throws [BlockedAfterDecodeFailure] if the collection is corrupted.
  Future<void> deletePlant(String id) async {
    final codec = await _getCodec();
    await codec.delete(id, matchKey: (e) => e.id);
  }

  /// Copy a photo file to the app's documents directory.
  ///
  /// Returns the absolute path to the stored photo.
  Future<String> savePhoto(File sourceFile, String plantId) async {
    final dir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${dir.path}/$_photoSubdir');

    if (!photoDir.existsSync()) {
      await photoDir.create(recursive: true);
    }

    final extension = sourceFile.path.split('.').last;
    final targetPath = '${photoDir.path}/$plantId.$extension';

    await sourceFile.copy(targetPath);
    return targetPath;
  }

  /// Delete a photo file from disk.
  Future<void> deletePhoto(String photoPath) async {
    final file = File(photoPath);
    if (file.existsSync()) {
      await file.delete();
    }
  }
}
