import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:open_plant/pages/species_library/species_library_item_entity.dart';

/// Loads bundled species JSON asset lazily with in-memory caching.
class SpeciesLibraryDatasource {
  final AssetBundle _bundle;

  /// Defaults to [rootBundle], injectable for testing.
  SpeciesLibraryDatasource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  List<SpeciesEntity>? _cachedSpecies;

  /// Returns all species from the bundled JSON asset.
  ///
  /// Loads and parses the asset on first call; subsequent calls return the
  /// cached in-memory list without re-reading the asset.
  Future<List<SpeciesEntity>> loadAll() async {
    if (_cachedSpecies != null) return _cachedSpecies!;

    final jsonString = await _bundle.loadString('assets/species/species.json');
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    _cachedSpecies = jsonList.map((e) => SpeciesEntity.fromJson(e as Map<String, dynamic>)).toList(growable: false);

    return _cachedSpecies!;
  }
}
