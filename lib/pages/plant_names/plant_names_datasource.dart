import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:open_plants/pages/plant_names/plant_names_entity.dart';

/// Loads plant names from the bundled JSON asset.
class PlantNamesDatasource {
  Map<String, PlantNameEntry>? _cache;

  /// Loads and returns the plant names lookup map.
  ///
  /// Returns an empty map if the asset is missing or malformed.
  Future<Map<String, PlantNameEntry>> loadPlantNames() async {
    if (_cache != null) return _cache!;

    try {
      final jsonStr = await rootBundle.loadString('assets/data/plant_names.json');
      final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;

      _cache = decoded.map(
        (speciesId, namesJson) => MapEntry(
          speciesId,
          PlantNameEntry.fromJson(speciesId, namesJson as Map<String, dynamic>),
        ),
      );
    } catch (_) {
      _cache = {};
    }

    return _cache!;
  }
}
