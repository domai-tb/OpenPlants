import 'package:open_plant/pages/plant_names/plant_names_repository.dart';

/// Use-case for resolving plant display names.
class PlantNamesUsecases {
  final PlantNamesRepository _repository;

  const PlantNamesUsecases({required PlantNamesRepository repository})
      : _repository = repository;

  /// Returns the localized display name for [speciesId].
  ///
  /// If [localeCode] is not provided, falls back to English.
  /// If [scientificName] is provided, it's used as the final fallback.
  Future<String> getDisplayName(
    String speciesId, {
    String localeCode = 'en',
    String? scientificName,
  }) {
    return _repository.getDisplayName(
      speciesId,
      localeCode,
      scientificName: scientificName,
    );
  }
}
