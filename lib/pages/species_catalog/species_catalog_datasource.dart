import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:openplants/pages/species_catalog/species_catalog_entity.dart';

String _defaultLocalePath(String locale) => 'assets/species/locales/$locale.json';

/// Lazy-cached catalog datasource loading bundled JSON assets.
class SpeciesCatalogDatasource {
  final AssetBundle _bundle;
  final String _catalogAsset;
  final String Function(String locale) _localeAssetPath;

  SpeciesCatalogDatasource({
    AssetBundle? bundle,
    String? catalogAsset,
    String Function(String locale)? localeAssetPath,
  })  : _bundle = bundle ?? rootBundle,
        _catalogAsset = catalogAsset ?? 'assets/species/catalog.json',
        _localeAssetPath = localeAssetPath ?? _defaultLocalePath;

  List<SpeciesCatalogEntry>? _cachedCatalog;
  final Map<String, List<SpeciesLocaleData>> _cachedLocales = {};

  /// Loads the base catalog. Cached after first call.
  Future<List<SpeciesCatalogEntry>> loadCatalog() async {
    if (_cachedCatalog != null) return _cachedCatalog!;

    final jsonString = await _bundle.loadString(_catalogAsset);
    final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

    _cachedCatalog =
        jsonList.map((e) => SpeciesCatalogEntry.fromJson(e as Map<String, dynamic>)).toList(growable: false);

    return _cachedCatalog!;
  }

  /// Loads locale data for a specific locale. Cached after first call.
  Future<List<SpeciesLocaleData>> loadLocale(String locale) async {
    if (_cachedLocales.containsKey(locale)) return _cachedLocales[locale]!;

    try {
      final jsonString = await _bundle.loadString(_localeAssetPath(locale));
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;

      final data = jsonList.map((e) => SpeciesLocaleData.fromJson(e as Map<String, dynamic>)).toList(growable: false);

      _cachedLocales[locale] = data;
      return data;
    } catch (_) {
      // Locale asset not found — return empty list.
      _cachedLocales[locale] = [];
      return [];
    }
  }

  /// Clears all cached data. Useful for testing.
  void clearCache() {
    _cachedCatalog = null;
    _cachedLocales.clear();
  }
}
