import 'package:open_plants/pages/room_profiles/room_profiles_entity.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_item_entity.dart';

/// Plant symptoms that can be observed during diagnosis.
enum PlantSymptom {
  yellowingLeaves,
  droopingWilt,
  brownTips,
  brownPatches,
  paleLeaves,
  leggyGrowth,
  visibleInsects,
  stickyResidue,
  moldOnSoil,
  foulSmell,
  stuntedGrowth,
  leafCurling,
  leafDrop,
  softStems,
  drySoil,
  wetSoil,
  leafSpots,
}

/// Extension for JSON serialization of [PlantSymptom].
extension PlantSymptomJson on PlantSymptom {
  String toJson() => name;

  static PlantSymptom fromJson(String json) {
    return PlantSymptom.values.firstWhere(
      (e) => e.name == json,
      orElse: () => PlantSymptom.yellowingLeaves,
    );
  }
}

/// Confidence level for a diagnosis cause.
enum ConfidenceLevel {
  low,
  medium,
  high,
}

/// Pot type for the plant.
enum PotType {
  standard,
  selfWatering,
  noDrainage,
}

/// Soil type used for the plant.
enum SoilType {
  standard,
  succulent,
  orchid,
  cactus,
}

/// How frequently the user waters the plant.
enum WateringFrequency {
  frequent,
  normal,
  infrequent,
}

/// Light exposure the plant receives.
enum LightExposure {
  low,
  indirect,
  direct,
}

/// Indoor humidity level.
enum HumidityLevel {
  low,
  moderate,
  high,
}

/// Immutable value object representing all user-provided context for diagnosis.
class DiagnosisContext {
  /// Observed symptoms (must not be empty for a meaningful diagnosis).
  final List<PlantSymptom> symptoms;

  /// Optional plant species name.
  final String? plantSpecies;

  /// Pot type the plant is in.
  final PotType? potType;

  /// Soil type used.
  final SoilType? soilType;

  /// Watering frequency.
  final WateringFrequency? wateringFrequency;

  /// Light exposure.
  final LightExposure? lightExposure;

  /// Humidity level.
  final HumidityLevel? humidityLevel;

  /// Whether the user has fertilized recently, or `null` when unanswered.
  final bool? recentFertilizing;

  /// Whether the user has noticed pest signs, or `null` when unanswered.
  final bool? pestSigns;

  const DiagnosisContext({
    required this.symptoms,
    this.plantSpecies,
    this.potType,
    this.soilType,
    this.wateringFrequency,
    this.lightExposure,
    this.humidityLevel,
    this.recentFertilizing,
    this.pestSigns,
  });

  /// Creates diagnosis input from a symptom log and its optional room profile.
  factory DiagnosisContext.fromSymptomLogEntry(
    SymptomLogEntry entry, {
    RoomEntity? room,
  }) {
    final loggedLightExposure = switch (entry.lightConditions) {
      LightCondition.fullSun => LightExposure.direct,
      LightCondition.partialShade => LightExposure.indirect,
      LightCondition.lowLight => LightExposure.low,
      LightCondition.unknown || null => null,
    };

    return DiagnosisContext(
      symptoms: entry.symptomTypes,
      wateringFrequency: switch (entry.soilMoisture) {
        SoilMoisture.dry => WateringFrequency.infrequent,
        SoilMoisture.moist => WateringFrequency.normal,
        SoilMoisture.wet || SoilMoisture.soggy => WateringFrequency.frequent,
        null => null,
      },
      lightExposure: loggedLightExposure ?? _mapRoomLight(room?.lightLevel),
      humidityLevel: _mapRoomHumidity(room?.humidityLevel),
    );
  }

  static LightExposure? _mapRoomLight(RoomLightLevel? lightLevel) {
    return switch (lightLevel) {
      RoomLightLevel.low => LightExposure.low,
      RoomLightLevel.medium || RoomLightLevel.bright => LightExposure.indirect,
      RoomLightLevel.directSun => LightExposure.direct,
      null => null,
    };
  }

  static HumidityLevel? _mapRoomHumidity(RoomHumidityLevel? humidityLevel) {
    return switch (humidityLevel) {
      RoomHumidityLevel.low => HumidityLevel.low,
      RoomHumidityLevel.medium => HumidityLevel.moderate,
      RoomHumidityLevel.high => HumidityLevel.high,
      null => null,
    };
  }

  /// Creates a DiagnosisContext from a JSON map.
  factory DiagnosisContext.fromMap(Map<String, dynamic> json) {
    return DiagnosisContext(
      symptoms: (json['symptoms'] as List<dynamic>)
          .map((e) => PlantSymptom.values.firstWhere((s) => s.name == e as String))
          .toList(),
      plantSpecies: json['plantSpecies'] as String?,
      potType: json['potType'] != null ? PotType.values.firstWhere((e) => e.name == json['potType']) : null,
      soilType: json['soilType'] != null ? SoilType.values.firstWhere((e) => e.name == json['soilType']) : null,
      wateringFrequency: json['wateringFrequency'] != null
          ? WateringFrequency.values.firstWhere((e) => e.name == json['wateringFrequency'])
          : null,
      lightExposure: json['lightExposure'] != null
          ? LightExposure.values.firstWhere((e) => e.name == json['lightExposure'])
          : null,
      humidityLevel: json['humidityLevel'] != null
          ? HumidityLevel.values.firstWhere((e) => e.name == json['humidityLevel'])
          : null,
      recentFertilizing: json['recentFertilizing'] as bool?,
      pestSigns: json['pestSigns'] as bool?,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toMap() => {
        'symptoms': symptoms.map((e) => e.name).toList(),
        if (plantSpecies != null) 'plantSpecies': plantSpecies,
        if (potType != null) 'potType': potType!.name,
        if (soilType != null) 'soilType': soilType!.name,
        if (wateringFrequency != null) 'wateringFrequency': wateringFrequency!.name,
        if (lightExposure != null) 'lightExposure': lightExposure!.name,
        if (humidityLevel != null) 'humidityLevel': humidityLevel!.name,
        if (recentFertilizing != null) 'recentFertilizing': recentFertilizing,
        if (pestSigns != null) 'pestSigns': pestSigns,
      };
}

/// A scored cause returned by the diagnosis engine.
class ScoredCause {
  /// Identifier for the cause (e.g. "overwatering", "low_light").
  final String causeId;

  /// Confidence level computed from the evidence score.
  final ConfidenceLevel confidence;

  /// Plain-language summary of why this cause was suggested.
  final String evidence;

  /// Actionable steps the user can take.
  final List<String> recommendedActions;

  /// Things to check next to confirm or rule out this cause.
  final List<String> followUpChecks;

  /// Internal numeric score (0.0 – 1.0) used for sorting.
  final double score;

  const ScoredCause({
    required this.causeId,
    required this.confidence,
    required this.evidence,
    required this.recommendedActions,
    required this.followUpChecks,
    required this.score,
  });

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
        'causeId': causeId,
        'confidence': confidence.name,
        'evidence': evidence,
        'recommendedActions': recommendedActions,
        'followUpChecks': followUpChecks,
        'score': score,
      };

  /// Creates a ScoredCause from a JSON map.
  factory ScoredCause.fromJson(Map<String, dynamic> json) {
    return ScoredCause(
      causeId: json['causeId'] as String,
      confidence: ConfidenceLevel.values.firstWhere((e) => e.name == json['confidence']),
      evidence: json['evidence'] as String,
      recommendedActions: (json['recommendedActions'] as List<dynamic>).cast<String>(),
      followUpChecks: (json['followUpChecks'] as List<dynamic>).cast<String>(),
      score: (json['score'] as num).toDouble(),
    );
  }
}

/// Semantic outcome of a diagnosis evaluation.
enum DiagnosisResultType {
  /// One or more rules met the threshold and were ranked.
  rankedCauses,

  /// Evaluation was skipped because no symptoms were provided.
  emptyInput,

  /// Symptoms were provided, but no rule met the threshold.
  noClearMatch,
}

/// Result returned by the diagnosis engine.
class DiagnosisResult {
  /// Ranked list of likely causes (highest confidence first).
  final List<ScoredCause> causes;

  /// Semantic outcome, independent of the cause identifiers.
  final DiagnosisResultType type;

  const DiagnosisResult._({required this.causes, required this.type});

  /// Creates a result containing ranked causes.
  factory DiagnosisResult.ranked(List<ScoredCause> causes) => DiagnosisResult._(
        causes: List.unmodifiable(causes),
        type: DiagnosisResultType.rankedCauses,
      );

  /// Creates a result for an evaluation with no symptom input.
  const DiagnosisResult.emptyInput()
      : this._(
          causes: const [],
          type: DiagnosisResultType.emptyInput,
        );

  /// Creates a result for symptoms that produced no clear match.
  factory DiagnosisResult.noClearMatch(ScoredCause fallback) => DiagnosisResult._(
        causes: List.unmodifiable([fallback]),
        type: DiagnosisResultType.noClearMatch,
      );

  /// Whether any cause exceeded the minimum confidence threshold.
  bool get hasResults => type == DiagnosisResultType.rankedCauses;

  /// Whether evaluation was skipped because no symptoms were provided.
  bool get isEmptyInput => type == DiagnosisResultType.emptyInput;

  /// Whether symptoms were provided but no rule met the threshold.
  bool get isNoClearMatch => type == DiagnosisResultType.noClearMatch;

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
        'causes': causes.map((e) => e.toJson()).toList(),
        'type': type.name,
      };

  /// Creates a DiagnosisResult from a JSON map.
  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    final type = DiagnosisResultType.values.firstWhere((e) => e.name == json['type']);
    final causes =
        (json['causes'] as List<dynamic>).map((e) => ScoredCause.fromJson(e as Map<String, dynamic>)).toList();
    return DiagnosisResult._(causes: List.unmodifiable(causes), type: type);
  }
}
