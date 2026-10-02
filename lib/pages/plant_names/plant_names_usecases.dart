import 'package:openplants/core/locale_service.dart';
import 'package:openplants/pages/plant_names/plant_names_repository.dart';

/// Use-case for resolving plant display names.
class PlantNamesUsecases {
  final PlantNamesRepository _repository;
  final LocaleService? _localeService;

  const PlantNamesUsecases({required PlantNamesRepository repository, LocaleService? localeService})
      : _repository = repository,
        _localeService = localeService;

  /// Returns the localized display name for [speciesId].
  ///
  /// Uses the active app locale when [localeCode] is not provided.
  /// If [scientificName] is provided, it's used as the final fallback.
  Future<String> getDisplayName(
    String speciesId, {
    String? localeCode,
    String? scientificName,
  }) {
    return _repository.getDisplayName(
      speciesId,
      localeCode ?? _localeService?.activeLocale.languageCode ?? 'en',
      scientificName: scientificName,
    );
  }
}
