import 'package:open_plant/pages/plant_names/plant_names_datasource.dart';

/// Resolves plant species to localized display names using tiered lookup:
/// 1. In-memory cache (from datasource)
/// 2. Bundled JSON asset
/// 3. Falls back to scientific name
class PlantNamesRepository {
  final PlantNamesDatasource _datasource;

  const PlantNamesRepository({required PlantNamesDatasource datasource}) : _datasource = datasource;

  /// Returns the localized display name for [speciesId] in the given [localeCode].
  ///
  /// Falls back to [scientificName] if no localized name is found.
  Future<String> getDisplayName(
    String speciesId,
    String localeCode, {
    String? scientificName,
  }) async {
    final names = await _datasource.loadPlantNames();
    final entry = names[speciesId];

    if (entry != null) {
      // Try exact locale match first (e.g., "de_DE"), then language code ("de")
      final exactMatch = entry.localizedNames[localeCode];
      if (exactMatch != null) return exactMatch;

      final languageCode = localeCode.split('_').first;
      final langMatch = entry.localizedNames[languageCode];
      if (langMatch != null) return langMatch;

      // Try English as fallback within the entry
      final enFallback = entry.localizedNames['en'];
      if (enFallback != null) return enFallback;
    }

    return scientificName ?? speciesId;
  }
}
