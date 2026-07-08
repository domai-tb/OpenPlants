import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads bundled model metadata JSON asset lazily with in-memory caching.
class ModelInfoDatasource {
  final AssetBundle _bundle;

  /// Defaults to [rootBundle], injectable for testing.
  ModelInfoDatasource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  Map<String, dynamic>? _cachedMeta;

  /// Returns the parsed model metadata from the bundled JSON asset.
  ///
  /// Loads and parses the asset on first call; subsequent calls return the
  /// cached in-memory map without re-reading the asset.
  Future<Map<String, dynamic>> loadModelMeta() async {
    if (_cachedMeta != null) return _cachedMeta!;

    final jsonString = await _bundle.loadString(
      'assets/ml/plant-identification/model_meta.json',
    );
    _cachedMeta = json.decode(jsonString) as Map<String, dynamic>;

    return _cachedMeta!;
  }
}
