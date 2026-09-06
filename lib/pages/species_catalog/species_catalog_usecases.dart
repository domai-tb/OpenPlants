import 'package:open_plants/pages/species_catalog/species_catalog_entity.dart';
import 'package:open_plants/pages/species_catalog/species_catalog_repository.dart';

/// Use cases for the species catalog feature.
class SpeciesCatalogUsecases {
  final SpeciesCatalogRepository _repository;

  const SpeciesCatalogUsecases({required SpeciesCatalogRepository repository})
      : _repository = repository;

  /// Search species by query with locale-aware results.
  Future<List<SpeciesCatalogEntry>> search(
    String query, {
    String locale = 'en',
    int limit = 20,
  }) =>
      _repository.search(query, locale: locale, limit: limit);

  /// Lookup a species by stable catalog ID.
  Future<SpeciesCatalogEntry?> findById(String id) => _repository.findById(id);

  /// Lookup a species by classifier model index.
  Future<SpeciesCatalogEntry?> findByModelIndex(int index) =>
      _repository.findByModelIndex(index);

  /// Lookup a species by scientific name.
  Future<SpeciesCatalogEntry?> findByScientificName(String name) =>
      _repository.findByScientificName(name);

  /// Resolve a species with locale data for display.
  Future<ResolvedSpecies?> resolveForDisplay(
    String id, {
    String activeLocale = 'en',
    String fallbackLocale = 'en',
  }) =>
      _repository.resolveWithLocale(id, activeLocale: activeLocale, fallbackLocale: fallbackLocale);

  /// Resolve a species from a scientific name (e.g. from classifier output).
  Future<ResolvedSpecies?> resolveFromScientificName(
    String scientificName, {
    String activeLocale = 'en',
    String fallbackLocale = 'en',
  }) async {
    final entry = await _repository.findByScientificName(scientificName);
    if (entry == null) return null;
    return _repository.resolveWithLocale(entry.id, activeLocale: activeLocale, fallbackLocale: fallbackLocale);
  }

  /// Get all species (for picker with client-side filtering).
  Future<List<SpeciesCatalogEntry>> listAll() => _repository.listAll();
}
