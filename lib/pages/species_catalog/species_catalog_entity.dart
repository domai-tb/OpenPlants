/// Stable catalog entry for a plant species.
///
/// Each species has a unique [id], an optional [modelIndex] mapping to the
/// classifier label, scientific name as fallback, and locale-specific data
/// loaded from separate locale assets.
class SpeciesCatalogEntry {
  /// Stable unique identifier (e.g. "monstera_deliciosa").
  final String id;

  /// Index in the classifier's label file; null if not in the model.
  final int? modelIndex;

  /// Scientific name — required, used as fallback when locale data is missing.
  final String scientificName;

  /// Aliases for search (common names in all locales, abbreviations, etc.).
  final List<String> aliases;

  /// Care metadata shared across all locales.
  final SpeciesCareMeta careMeta;

  const SpeciesCatalogEntry({
    required this.id,
    this.modelIndex,
    required this.scientificName,
    this.aliases = const [],
    required this.careMeta,
  });

  factory SpeciesCatalogEntry.fromJson(Map<String, dynamic> json) {
    return SpeciesCatalogEntry(
      id: json['id'] as String,
      modelIndex: json['modelIndex'] as int?,
      scientificName: json['scientificName'] as String,
      aliases: (json['aliases'] as List<dynamic>?)?.cast<String>() ?? [],
      careMeta: SpeciesCareMeta.fromJson(json['careMeta'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (modelIndex != null) 'modelIndex': modelIndex,
        'scientificName': scientificName,
        'aliases': aliases,
        'careMeta': careMeta.toJson(),
      };
}

/// Care metadata for a species (shared across locales).
class SpeciesCareMeta {
  final String difficulty;
  final String lightNeeds;
  final String waterNeeds;
  final String humidityPreference;
  final String soilType;
  final int repottingIntervalMonths;
  final bool toxicToHumans;
  final bool toxicToPets;

  const SpeciesCareMeta({
    required this.difficulty,
    required this.lightNeeds,
    required this.waterNeeds,
    required this.humidityPreference,
    required this.soilType,
    required this.repottingIntervalMonths,
    required this.toxicToHumans,
    required this.toxicToPets,
  });

  factory SpeciesCareMeta.fromJson(Map<String, dynamic> json) {
    return SpeciesCareMeta(
      difficulty: json['difficulty'] as String,
      lightNeeds: json['lightNeeds'] as String,
      waterNeeds: json['waterNeeds'] as String,
      humidityPreference: json['humidityPreference'] as String,
      soilType: json['soilType'] as String,
      repottingIntervalMonths: json['repottingIntervalMonths'] as int,
      toxicToHumans: json['toxicToHumans'] as bool,
      toxicToPets: json['toxicToPets'] as bool,
    );
  }

  Map<String, dynamic> toJson() => {
        'difficulty': difficulty,
        'lightNeeds': lightNeeds,
        'waterNeeds': waterNeeds,
        'humidityPreference': humidityPreference,
        'soilType': soilType,
        'repottingIntervalMonths': repottingIntervalMonths,
        'toxicToHumans': toxicToHumans,
        'toxicToPets': toxicToPets,
      };
}

/// Locale-specific data for a species.
class SpeciesLocaleData {
  final String locale;
  final String commonName;
  final List<String> commonNames;
  final String? description;
  final String? careSummary;

  const SpeciesLocaleData({
    required this.locale,
    required this.commonName,
    this.commonNames = const [],
    this.description,
    this.careSummary,
  });

  factory SpeciesLocaleData.fromJson(Map<String, dynamic> json) {
    return SpeciesLocaleData(
      locale: json['locale'] as String,
      commonName: json['commonName'] as String,
      commonNames: (json['commonNames'] as List<dynamic>?)?.cast<String>() ?? [],
      description: json['description'] as String?,
      careSummary: json['careSummary'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'locale': locale,
        'commonName': commonName,
        'commonNames': commonNames,
        if (description != null) 'description': description,
        if (careSummary != null) 'careSummary': careSummary,
      };
}

/// Fully resolved species with catalog entry and locale data.
class ResolvedSpecies {
  final SpeciesCatalogEntry catalog;
  final SpeciesLocaleData localeData;

  const ResolvedSpecies({
    required this.catalog,
    required this.localeData,
  });

  String get displayName => localeData.commonName;
  String get scientificName => catalog.scientificName;
  String get id => catalog.id;
}
