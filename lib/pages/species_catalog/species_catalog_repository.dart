import 'package:open_plants/pages/species_catalog/species_catalog_datasource.dart';
import 'package:open_plants/pages/species_catalog/species_catalog_entity.dart';

/// Repository for the species catalog with search, lookup, and locale resolution.
class SpeciesCatalogRepository {
  final SpeciesCatalogDatasource _datasource;

  const SpeciesCatalogRepository({required SpeciesCatalogDatasource datasource})
      : _datasource = datasource;

  /// Returns all catalog entries.
  Future<List<SpeciesCatalogEntry>> listAll() => _datasource.loadCatalog();

  /// Lookup by stable catalog ID.
  Future<SpeciesCatalogEntry?> findById(String id) async {
    final all = await _datasource.loadCatalog();
    for (final entry in all) {
      if (entry.id == id) return entry;
    }
    return null;
  }

  /// Lookup by model classifier index.
  Future<SpeciesCatalogEntry?> findByModelIndex(int index) async {
    final all = await _datasource.loadCatalog();
    for (final entry in all) {
      if (entry.modelIndex == index) return entry;
    }
    return null;
  }

  /// Lookup by exact scientific name (case-insensitive).
  Future<SpeciesCatalogEntry?> findByScientificName(String name) async {
    final all = await _datasource.loadCatalog();
    final normalized = name.trim().toLowerCase();
    for (final entry in all) {
      if (entry.scientificName.toLowerCase() == normalized) return entry;
    }
    return null;
  }

  /// Search by query across common names (in locale), scientific name, and aliases.
  ///
  /// Returns at most [limit] results. Deterministic: sorted by relevance
  /// (exact common name > prefix > contains > scientific name > alias).
  Future<List<SpeciesCatalogEntry>> search(
    String query, {
    String locale = 'en',
    int limit = 20,
  }) async {
    final all = await _datasource.loadCatalog();
    final localeData = await _datasource.loadLocale(locale);
    final localeMap = {for (final ld in localeData) ld.locale: ld};

    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) return all.take(limit).toList();

    final results = <(SpeciesCatalogEntry, int)>[];
    for (final entry in all) {
      final ld = localeMap[entry.id];
      final score = _scoreEntry(entry, ld, trimmed);
      if (score > 0) results.add((entry, score));
    }

    results.sort((a, b) => b.$2.compareTo(a.$2));
    return results.take(limit).map((e) => e.$1).toList();
  }

  /// Resolve a species with locale data using active locale, fallback, and
  /// scientific name fallback.
  Future<ResolvedSpecies?> resolveWithLocale(
    String id, {
    String activeLocale = 'en',
    String fallbackLocale = 'en',
  }) async {
    final entry = await findById(id);
    if (entry == null) return null;

    // Try active locale
    final activeData = await _findLocaleData(id, activeLocale);
    if (activeData != null) return ResolvedSpecies(catalog: entry, localeData: activeData);

    // Try fallback locale
    if (fallbackLocale != activeLocale) {
      final fallbackData = await _findLocaleData(id, fallbackLocale);
      if (fallbackData != null) return ResolvedSpecies(catalog: entry, localeData: fallbackData);
    }

    // Scientific name fallback
    return ResolvedSpecies(
      catalog: entry,
      localeData: SpeciesLocaleData(
        locale: 'fallback',
        commonName: entry.scientificName,
      ),
    );
  }

  Future<SpeciesLocaleData?> _findLocaleData(String id, String locale) async {
    final data = await _datasource.loadLocale(locale);
    for (final ld in data) {
      if (ld.locale == id) return ld;
    }
    return null;
  }

  /// Score an entry for search relevance. Higher = better match.
  int _scoreEntry(SpeciesCatalogEntry entry, SpeciesLocaleData? ld, String query) {
    // Exact common name match
    if (ld != null && ld.commonName.toLowerCase() == query) return 100;
    // Common name starts with query
    if (ld != null && ld.commonName.toLowerCase().startsWith(query)) return 80;
    // Common name contains query
    if (ld != null && ld.commonName.toLowerCase().contains(query)) return 60;
    // Scientific name starts with query
    if (entry.scientificName.toLowerCase().startsWith(query)) return 50;
    // Scientific name contains query
    if (entry.scientificName.toLowerCase().contains(query)) return 40;
    // Alias match
    if (entry.aliases.any((a) => a.toLowerCase().contains(query))) return 30;
    // Common names list
    if (ld != null && ld.commonNames.any((n) => n.toLowerCase().contains(query))) return 20;
    return 0;
  }
}
