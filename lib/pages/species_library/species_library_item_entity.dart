/// Difficulty level for plant care.
enum Difficulty { easy, moderate, challenging }

/// Light needs for a plant species.
enum LightNeeds { low, medium, bright, direct }

/// Water needs for a plant species.
enum WaterNeeds { low, moderate, frequent }

/// Humidity preference for a plant species.
enum HumidityPreference { low, moderate, high }

/// Immutable entity representing a plant species in the library.
class SpeciesEntity {
  final String scientificName;
  final List<String> commonNames;
  final Difficulty difficulty;
  final LightNeeds lightNeeds;
  final WaterNeeds waterNeeds;
  final HumidityPreference humidityPreference;
  final String soilType;
  final int repottingIntervalMonths;
  final bool toxicToHumans;
  final bool toxicToPets;
  final String description;
  final String careSummary;

  const SpeciesEntity({
    required this.scientificName,
    required this.commonNames,
    required this.difficulty,
    required this.lightNeeds,
    required this.waterNeeds,
    required this.humidityPreference,
    required this.soilType,
    required this.repottingIntervalMonths,
    required this.toxicToHumans,
    required this.toxicToPets,
    required this.description,
    required this.careSummary,
  });

  /// Creates a [SpeciesEntity] from a parsed JSON map.
  factory SpeciesEntity.fromJson(Map<String, dynamic> json) {
    return SpeciesEntity(
      scientificName: json['scientificName'] as String,
      commonNames: List<String>.from(json['commonNames'] as List),
      difficulty: Difficulty.values.byName(json['difficulty'] as String),
      lightNeeds: LightNeeds.values.byName(json['lightNeeds'] as String),
      waterNeeds: WaterNeeds.values.byName(json['waterNeeds'] as String),
      humidityPreference: HumidityPreference.values.byName(json['humidityPreference'] as String),
      soilType: json['soilType'] as String,
      repottingIntervalMonths: json['repottingIntervalMonths'] as int,
      toxicToHumans: json['toxicToHumans'] as bool,
      toxicToPets: json['toxicToPets'] as bool,
      description: json['description'] as String,
      careSummary: json['careSummary'] as String,
    );
  }
}
