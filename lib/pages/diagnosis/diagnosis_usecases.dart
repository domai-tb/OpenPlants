import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';

// ---------------------------------------------------------------------------
// Base Rule
// ---------------------------------------------------------------------------

/// A single diagnosis rule that evaluates a [DiagnosisContext] and produces
/// a score between 0.0 and 1.0.
abstract class DiagnosisRule {
  /// Unique identifier for this rule (e.g. "overwatering").
  String get causeId;

  /// Evaluates the context and returns a score in 0.0 – 1.0 range.
  double score(DiagnosisContext context);

  /// Converts a numeric score to a [ConfidenceLevel].
  ///
  /// Thresholds:
  /// - high:   score > 0.7
  /// - medium: 0.4 < score <= 0.7
  /// - low:    score <= 0.4
  ConfidenceLevel confidenceFromScore(double score) {
    if (score > 0.7) return ConfidenceLevel.high;
    if (score > 0.4) return ConfidenceLevel.medium;
    return ConfidenceLevel.low;
  }
}

// ---------------------------------------------------------------------------
// Concrete Rules
// ---------------------------------------------------------------------------

class OverwateringRule extends DiagnosisRule {
  @override
  String get causeId => 'overwatering';

  @override
  double score(DiagnosisContext context) {
    var s = 0.0;
    final hasYellowing = context.symptoms.contains(PlantSymptom.yellowingLeaves);
    final hasDrooping = context.symptoms.contains(PlantSymptom.droopingWilt);
    final hasMold = context.symptoms.contains(PlantSymptom.moldOnSoil);
    final hasFoulSmell = context.symptoms.contains(PlantSymptom.foulSmell);

    // Core symptoms
    if (hasYellowing) s += 0.25;
    if (hasDrooping) s += 0.2;
    if (hasMold) s += 0.3;
    if (hasFoulSmell) s += 0.15;

    // Context amplifiers
    if (context.wateringFrequency == WateringFrequency.frequent) s += 0.15;
    if (context.potType == PotType.noDrainage) s += 0.15;
    if (context.potType == PotType.selfWatering) s += 0.05;

    return s.clamp(0.0, 1.0);
  }
}

class UnderwateringRule extends DiagnosisRule {
  @override
  String get causeId => 'underwatering';

  @override
  double score(DiagnosisContext context) {
    var s = 0.0;
    final hasDrooping = context.symptoms.contains(PlantSymptom.droopingWilt);
    final hasBrownTips = context.symptoms.contains(PlantSymptom.brownTips);
    final hasCurling = context.symptoms.contains(PlantSymptom.leafCurling);
    final hasDrop = context.symptoms.contains(PlantSymptom.leafDrop);

    if (hasDrooping) s += 0.25;
    if (hasBrownTips) s += 0.25;
    if (hasCurling) s += 0.2;
    if (hasDrop) s += 0.1;

    if (context.wateringFrequency == WateringFrequency.infrequent) s += 0.2;
    if (context.potType == PotType.standard) s += 0.05;

    return s.clamp(0.0, 1.0);
  }
}

class LowLightRule extends DiagnosisRule {
  @override
  String get causeId => 'low_light';

  @override
  double score(DiagnosisContext context) {
    var s = 0.0;
    final hasLeggy = context.symptoms.contains(PlantSymptom.leggyGrowth);
    final hasPale = context.symptoms.contains(PlantSymptom.paleLeaves);
    final hasStunted = context.symptoms.contains(PlantSymptom.stuntedGrowth);

    if (hasLeggy) s += 0.35;
    if (hasPale) s += 0.25;
    if (hasStunted) s += 0.1;

    if (context.lightExposure == LightExposure.low) s += 0.3;

    return s.clamp(0.0, 1.0);
  }
}

class SunburnRule extends DiagnosisRule {
  @override
  String get causeId => 'sunburn';

  @override
  double score(DiagnosisContext context) {
    var s = 0.0;
    final hasPatches = context.symptoms.contains(PlantSymptom.brownPatches);
    final hasYellowing = context.symptoms.contains(PlantSymptom.yellowingLeaves);

    if (hasPatches) s += 0.4;
    if (hasYellowing) s += 0.1;

    if (context.lightExposure == LightExposure.direct) s += 0.35;

    return s.clamp(0.0, 1.0);
  }
}

class LowHumidityRule extends DiagnosisRule {
  @override
  String get causeId => 'low_humidity';

  @override
  double score(DiagnosisContext context) {
    var s = 0.0;
    final hasBrownTips = context.symptoms.contains(PlantSymptom.brownTips);
    final hasCurling = context.symptoms.contains(PlantSymptom.leafCurling);
    final hasDrop = context.symptoms.contains(PlantSymptom.leafDrop);

    if (hasBrownTips) s += 0.3;
    if (hasCurling) s += 0.15;
    if (hasDrop) s += 0.1;

    if (context.humidityLevel == HumidityLevel.low) s += 0.3;

    return s.clamp(0.0, 1.0);
  }
}

class NutrientProblemRule extends DiagnosisRule {
  @override
  String get causeId => 'nutrient_problem';

  @override
  double score(DiagnosisContext context) {
    var s = 0.0;
    final hasYellowing = context.symptoms.contains(PlantSymptom.yellowingLeaves);
    final hasPale = context.symptoms.contains(PlantSymptom.paleLeaves);
    final hasStunted = context.symptoms.contains(PlantSymptom.stuntedGrowth);
    final hasDrop = context.symptoms.contains(PlantSymptom.leafDrop);

    if (hasYellowing) s += 0.2;
    if (hasPale) s += 0.3;
    if (hasStunted) s += 0.2;
    if (hasDrop) s += 0.1;

    if (context.recentFertilizing == false) s += 0.25;

    return s.clamp(0.0, 1.0);
  }
}

class RootIssueRule extends DiagnosisRule {
  @override
  String get causeId => 'root_issue';

  @override
  double score(DiagnosisContext context) {
    var s = 0.0;
    final hasDrooping = context.symptoms.contains(PlantSymptom.droopingWilt);
    final hasStunted = context.symptoms.contains(PlantSymptom.stuntedGrowth);
    final hasFoulSmell = context.symptoms.contains(PlantSymptom.foulSmell);
    final hasMold = context.symptoms.contains(PlantSymptom.moldOnSoil);

    if (hasDrooping) s += 0.15;
    if (hasStunted) s += 0.15;
    if (hasFoulSmell) s += 0.3;
    if (hasMold) s += 0.15;

    if (context.wateringFrequency == WateringFrequency.frequent) s += 0.15;

    return s.clamp(0.0, 1.0);
  }
}

class PestRule extends DiagnosisRule {
  @override
  String get causeId => 'pests';

  @override
  double score(DiagnosisContext context) {
    var s = 0.0;
    final hasInsects = context.symptoms.contains(PlantSymptom.visibleInsects);
    final hasSticky = context.symptoms.contains(PlantSymptom.stickyResidue);
    final hasDrop = context.symptoms.contains(PlantSymptom.leafDrop);
    final hasYellowing = context.symptoms.contains(PlantSymptom.yellowingLeaves);

    if (hasInsects) s += 0.4;
    if (hasSticky) s += 0.3;
    if (hasDrop) s += 0.1;
    if (hasYellowing) s += 0.05;

    if (context.pestSigns == true) s += 0.15;

    return s.clamp(0.0, 1.0);
  }
}

// ---------------------------------------------------------------------------
// Fallback
// ---------------------------------------------------------------------------

/// Returns a general "no clear match" cause when all rules score below the
/// minimum confidence threshold.
ScoredCause buildNoClearMatchFallback() {
  return const ScoredCause(
    causeId: 'no_clear_match',
    confidence: ConfidenceLevel.low,
    evidence: 'No single cause stood out based on the information provided. '
        'This could mean the issue is caused by factors not covered by the questionnaire.',
    recommendedActions: [
      'Ensure your plant receives appropriate light for its species.',
      'Check the soil moisture before watering — over- and under-watering are the most common issues.',
      'Inspect the leaves and stems closely for any unusual spots, pests, or texture changes.',
    ],
    followUpChecks: [
      "Try the questionnaire again with more details about your plant's environment.",
      'Consult a local plant shop or online community for species-specific advice.',
    ],
    score: 0,
  );
}

// ---------------------------------------------------------------------------
// Engine
// ---------------------------------------------------------------------------

/// Minimum score threshold for a rule to be included in results.
const double _minThreshold = 0.15;

/// Rule-based diagnosis engine.
///
/// Evaluates all registered [DiagnosisRule]s against a [DiagnosisContext]
/// and returns ranked [ScoredCause] results.
class DiagnosisEngine {
  /// All registered rules, evaluated in order.
  final List<DiagnosisRule> rules;

  /// Creates an engine with the default set of rules.
  DiagnosisEngine()
      : rules = [
          OverwateringRule(),
          UnderwateringRule(),
          LowLightRule(),
          SunburnRule(),
          LowHumidityRule(),
          NutrientProblemRule(),
          RootIssueRule(),
          PestRule(),
        ];

  /// Creates an engine with custom rules (useful for testing).
  DiagnosisEngine.withRules(this.rules);

  /// Evaluates the given [context] and returns a [DiagnosisResult].
  ///
  /// Rules scoring below the threshold are excluded unless all rules
  /// score below the threshold, in which case a fallback is returned.
  DiagnosisResult evaluate(DiagnosisContext context) {
    if (context.symptoms.isEmpty) {
      return const DiagnosisResult.emptyInput();
    }

    final scored = <ScoredCause>[];

    for (final rule in rules) {
      final s = rule.score(context);
      if (s >= _minThreshold) {
        scored.add(
          ScoredCause(
            causeId: rule.causeId,
            confidence: rule.confidenceFromScore(s),
            evidence: _buildEvidence(rule.causeId, context),
            recommendedActions: _recommendedActions(rule.causeId),
            followUpChecks: _followUpChecks(rule.causeId),
            score: s,
          ),
        );
      }
    }

    // Sort by score descending
    scored.sort((a, b) => b.score.compareTo(a.score));

    // If no rule exceeded the threshold, return fallback
    if (scored.isEmpty) {
      return DiagnosisResult.noClearMatch(buildNoClearMatchFallback());
    }

    return DiagnosisResult.ranked(scored);
  }
}

// ---------------------------------------------------------------------------
// Evidence & Action Helpers
// ---------------------------------------------------------------------------

String _buildEvidence(String causeId, DiagnosisContext context) {
  final symptomNames = context.symptoms.map(_symptomLabel).toList();
  final symptomText = symptomNames.isNotEmpty ? symptomNames.join(' and ') : '';

  switch (causeId) {
    case 'overwatering':
      return 'You reported $symptomText. '
          '${context.wateringFrequency == WateringFrequency.frequent ? 'You water frequently, which can keep the soil too wet. ' : ''}'
          '${context.potType == PotType.noDrainage ? 'Your pot has no drainage holes, which traps excess water. ' : ''}'
          'These are common signs of overwatering.';
    case 'underwatering':
      return 'You reported $symptomText. '
          '${context.wateringFrequency == WateringFrequency.infrequent ? 'You water infrequently, which may leave the soil too dry. ' : ''}'
          'These are common signs of underwatering.';
    case 'low_light':
      return 'You reported $symptomText. '
          '${context.lightExposure == LightExposure.low ? 'Your plant receives low light. ' : ''}'
          'Leggy growth and pale leaves are typical signs of insufficient light.';
    case 'sunburn':
      return 'You reported $symptomText. '
          '${context.lightExposure == LightExposure.direct ? 'Your plant receives direct sunlight. ' : ''}'
          'Brown scorched patches can indicate sun damage.';
    case 'low_humidity':
      return 'You reported $symptomText. '
          '${context.humidityLevel == HumidityLevel.low ? 'The humidity in your environment is low. ' : ''}'
          'Brown leaf tips and curling are common in dry indoor air.';
    case 'nutrient_problem':
      return 'You reported $symptomText. '
          '${context.recentFertilizing == false ? "You haven't fertilized recently. " : ''}'
          'Pale or yellowing growth can indicate nutrient deficiency.';
    case 'root_issue':
      return 'You reported $symptomText. '
          '${context.wateringFrequency == WateringFrequency.frequent ? 'Frequent watering can lead to root problems. ' : ''}'
          'Wilting despite moist soil and foul smell are signs of root issues.';
    case 'pests':
      return 'You reported $symptomText. '
          '${context.pestSigns == true ? "You've noticed signs of pests. " : ''}'
          'Visible insects, sticky residue, and leaf damage can indicate pest infestation.';
    default:
      return 'Based on your answers, this cause was identified as a possibility.';
  }
}

List<String> _recommendedActions(String causeId) {
  switch (causeId) {
    case 'overwatering':
      return [
        'Allow the top 2-3 inches of soil to dry before watering again.',
        'Check that your pot has drainage holes and empty the saucer after watering.',
        'If root rot is suspected, remove the plant and trim any brown, mushy roots.',
      ];
    case 'underwatering':
      return [
        'Water the plant thoroughly until water drains from the bottom.',
        "Establish a regular watering schedule based on the plant's needs.",
        'Consider bottom-watering to encourage deeper root growth.',
      ];
    case 'low_light':
      return [
        'Move the plant closer to a window or to a brighter location.',
        'Consider adding a grow light if natural light is limited.',
        'Rotate the plant regularly so all sides receive light.',
      ];
    case 'sunburn':
      return [
        'Move the plant to a spot with indirect or filtered light.',
        'Use a sheer curtain to diffuse direct sunlight.',
        'Remove severely burned leaves once the plant has adjusted.',
      ];
    case 'low_humidity':
      return [
        'Mist the plant regularly or place a humidifier nearby.',
        'Group humidity-loving plants together to create a microclimate.',
        'Place the pot on a pebble tray with water (pot sitting above the water line).',
      ];
    case 'nutrient_problem':
      return [
        'Apply a balanced liquid fertilizer at half strength during the growing season.',
        'Check if the plant is root-bound and needs repotting with fresh soil.',
        'Ensure the soil pH is appropriate for the plant species.',
      ];
    case 'root_issue':
      return [
        'Remove the plant from the pot and inspect the roots.',
        'Trim any brown, mushy, or foul-smelling roots with sterile scissors.',
        'Repot in fresh, well-draining soil and reduce watering frequency.',
      ];
    case 'pests':
      return [
        'Isolate the affected plant to prevent spreading.',
        'Wipe leaves with a damp cloth or spray with neem oil solution.',
        'Check under leaves and in leaf joints where pests often hide.',
      ];
    default:
      return [
        'Ensure your plant receives appropriate light and water for its species.',
        'Check the soil moisture before watering.',
      ];
  }
}

List<String> _followUpChecks(String causeId) {
  switch (causeId) {
    case 'overwatering':
      return [
        'Check the roots: healthy roots are firm and white, rotten roots are brown and mushy.',
        'Monitor soil moisture — it should dry out between waterings.',
      ];
    case 'underwatering':
      return [
        'Check the root ball: if it has pulled away from the pot edges, the soil is too dry.',
        'Feel the soil 2 inches down — it should be slightly moist, not bone dry.',
      ];
    case 'low_light':
      return [
        'Observe if new growth is still leggy after moving to a brighter spot.',
        'Note how many hours of light the plant receives daily.',
      ];
    case 'sunburn':
      return [
        'Check if the brown patches stop spreading after moving the plant.',
        'Monitor for new leaves — they should grow without brown spots.',
      ];
    case 'low_humidity':
      return [
        'Check if brown tips stop appearing after increasing humidity.',
        'Use a hygrometer to measure the actual humidity level near the plant.',
      ];
    case 'nutrient_problem':
      return [
        'After fertilizing, observe if new growth appears healthier within 2-3 weeks.',
        'Check if the soil is compacted or the plant is root-bound.',
      ];
    case 'root_issue':
      return [
        'Healthy roots are firm and white or light tan. Rotten roots are brown, black, or mushy.',
        'After repotting, wait a week before watering to let roots recover.',
      ];
    case 'pests':
      return [
        'Inspect the plant weekly for 3-4 weeks to ensure the pest problem is resolved.',
        'Check nearby plants for signs of spreading.',
      ];
    default:
      return [
        'Try the questionnaire again with more details.',
        'Consult a plant care expert for species-specific advice.',
      ];
  }
}

String _symptomLabel(PlantSymptom symptom) {
  switch (symptom) {
    case PlantSymptom.yellowingLeaves:
      return 'yellowing leaves';
    case PlantSymptom.droopingWilt:
      return 'drooping or wilting';
    case PlantSymptom.brownTips:
      return 'brown leaf tips';
    case PlantSymptom.brownPatches:
      return 'brown patches';
    case PlantSymptom.paleLeaves:
      return 'pale leaves';
    case PlantSymptom.leggyGrowth:
      return 'leggy growth';
    case PlantSymptom.visibleInsects:
      return 'visible insects';
    case PlantSymptom.stickyResidue:
      return 'sticky residue';
    case PlantSymptom.moldOnSoil:
      return 'mold on soil';
    case PlantSymptom.foulSmell:
      return 'foul smell from soil';
    case PlantSymptom.stuntedGrowth:
      return 'stunted growth';
    case PlantSymptom.leafCurling:
      return 'leaf curling';
    case PlantSymptom.leafDrop:
      return 'leaf drop';
  }
}
