import 'package:openplants/pages/species_library/species_library_item_entity.dart';
import 'package:openplants/pages/species_library/species_library_repository.dart';

/// Business logic for the species library feature.
class SpeciesLibraryUsecases {
  final SpeciesLibraryRepository _repository;

  const SpeciesLibraryUsecases({required SpeciesLibraryRepository repository}) : _repository = repository;

  /// Returns all species in the library.
  Future<List<SpeciesEntity>> getAllSpecies() => _repository.listAll();

  /// Searches species by [query] across common names, scientific name,
  /// and description.
  Future<List<SpeciesEntity>> searchSpecies(String query) => _repository.search(query);

  /// Looks up a species by [scientificName] with fuzzy matching.
  Future<SpeciesEntity?> lookupSpecies(String scientificName) => _repository.findByScientificName(scientificName);

  /// Filters species by optional criteria.
  Future<List<SpeciesEntity>> filterSpecies({
    Difficulty? difficulty,
    bool? toxicOnly,
  }) =>
      _repository.filter(difficulty: difficulty, toxicOnly: toxicOnly);

  /// Cross-page lookup: finds species for a scientific name from
  /// identification results.
  Future<SpeciesEntity?> speciesForIdentifiedPlant(String scientificName) =>
      _repository.findByScientificName(scientificName);
}
