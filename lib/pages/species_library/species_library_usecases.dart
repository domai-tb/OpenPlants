import 'package:open_plants/pages/species_library/care_plan.dart';
import 'package:open_plants/pages/species_library/species_library_item_entity.dart';
import 'package:open_plants/pages/species_library/species_library_repository.dart';

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

  /// Generates a structured [CarePlan] from a [SpeciesEntity].
  CarePlan generateCarePlan(SpeciesEntity species) {
    return CarePlan(
      wateringGuidance: _waterGuidance(species.waterNeeds),
      lightGuidance: _lightGuidance(species.lightNeeds),
      humidityGuidance: _humidityGuidance(species.humidityPreference),
      soilRecommendation:
          'Best grown in ${species.soilType.toLowerCase()}. Ensure the pot has drainage holes to prevent root rot.',
      repottingAdvice: _repottingAdvice(species.repottingIntervalMonths),
    );
  }

  /// Cross-page lookup: finds species for a scientific name from
  /// identification results.
  Future<SpeciesEntity?> speciesForIdentifiedPlant(String scientificName) =>
      _repository.findByScientificName(scientificName);

  String _waterGuidance(WaterNeeds waterNeeds) {
    return switch (waterNeeds) {
      WaterNeeds.low => 'Water every 2-3 weeks, allowing soil to dry completely between waterings',
      WaterNeeds.moderate => 'Water once per week, allowing top inch of soil to dry between waterings',
      WaterNeeds.frequent => 'Water 2-3 times per week, keeping soil consistently moist',
    };
  }

  String _lightGuidance(LightNeeds lightNeeds) {
    return switch (lightNeeds) {
      LightNeeds.low => 'Thrives in low light, keep away from direct sun. Ideal for north-facing rooms',
      LightNeeds.medium => 'Prefers bright indirect light. East or west-facing windows are ideal',
      LightNeeds.bright => 'Needs bright indirect light. South-facing window with sheer curtain',
      LightNeeds.direct => 'Requires direct sunlight. South-facing windowsill or grow lights',
    };
  }

  String _humidityGuidance(HumidityPreference humidityPreference) {
    return switch (humidityPreference) {
      HumidityPreference.low => 'Tolerates average household humidity (30-40%). No special care needed',
      HumidityPreference.moderate => 'Prefers higher humidity (40-60%). Consider a pebble tray or occasional misting',
      HumidityPreference.high => 'Needs high humidity (60%+). Use a humidifier or place in a terrarium',
    };
  }

  String _repottingAdvice(int intervalMonths) {
    if (intervalMonths <= 12) return 'Annual repotting recommended';
    if (intervalMonths <= 24) return 'Repot every 1-2 years';
    return 'Rarely needs repotting — only when root-bound';
  }
}
