import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';

/// Data source for plant collection persistence.
///
/// Stores plant metadata as JSON in shared_preferences and
/// manages photo files in the app's documents directory.
class PlantCollectionDataSource {
  static const String _prefsKey = 'plant_collection_v1';
  static const String _photoSubdir = 'plant_photos';

  /// Load all plants from shared_preferences.
  Future<List<PlantEntity>> loadPlants() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => PlantEntity.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Save plant list to shared_preferences.
  Future<void> savePlants(List<PlantEntity> plants) async {
    final prefs = await SharedPreferences.getInstance();
    final json = plants.map((p) => p.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(json));
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
