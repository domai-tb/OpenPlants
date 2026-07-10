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
}
