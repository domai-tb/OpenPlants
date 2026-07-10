import 'package:test/test.dart';

import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_usecases.dart';

void main() {
  group('DiagnosisEngine', () {
    late DiagnosisEngine engine;

    setUp(() {
      engine = DiagnosisEngine();
    });

    group('evaluate', () {
      test('returns empty-input semantics for no symptoms', () {
        // Arrange
        const context = DiagnosisContext(symptoms: []);

        // Act
        final result = engine.evaluate(context);

        // Assert
        expect(
          (result.type, result.causes, result.hasResults, result.isEmptyInput, result.isNoClearMatch),
          equals((DiagnosisResultType.emptyInput, const <ScoredCause>[], false, true, false)),
        );
      });

      test('returns ranked-result semantics for a normal diagnosis', () {
        // Arrange
        const context = DiagnosisContext(
          symptoms: [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
          wateringFrequency: WateringFrequency.frequent,
        );

        // Act
        final result = engine.evaluate(context);

        // Assert
        expect(
          (result.type, result.causes.isNotEmpty, result.hasResults, result.isEmptyInput, result.isNoClearMatch),
          equals((DiagnosisResultType.rankedCauses, true, true, false, false)),
        );
      });

      test('results are sorted by score descending', () {
        const context = DiagnosisContext(
          symptoms: [
            PlantSymptom.yellowingLeaves,
            PlantSymptom.droopingWilt,
            PlantSymptom.moldOnSoil,
          ],
          wateringFrequency: WateringFrequency.frequent,
          potType: PotType.noDrainage,
        );
        final result = engine.evaluate(context);
        for (var i = 0; i < result.causes.length - 1; i++) {
          expect(
            result.causes[i].score,
            greaterThanOrEqualTo(result.causes[i + 1].score),
          );
        }
      });

      test('is deterministic (same input produces same output)', () {
        const context = DiagnosisContext(
          symptoms: [PlantSymptom.yellowingLeaves],
          wateringFrequency: WateringFrequency.frequent,
        );
        final result1 = engine.evaluate(context);
        final result2 = engine.evaluate(context);
        expect(result1.causes.length, equals(result2.causes.length));
        for (var i = 0; i < result1.causes.length; i++) {
          expect(result1.causes[i].causeId, equals(result2.causes[i].causeId));
          expect(result1.causes[i].score, equals(result2.causes[i].score));
          expect(result1.causes[i].confidence, equals(result2.causes[i].confidence));
        }
      });
    });
  });

  group('OverwateringRule', () {
    late OverwateringRule rule;

    setUp(() {
      rule = OverwateringRule();
    });

    test('high confidence with yellowing + frequent watering + no drainage', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
        wateringFrequency: WateringFrequency.frequent,
        potType: PotType.noDrainage,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.high));
    });

    test('medium confidence with drooping + yellowing + wet soil', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.droopingWilt, PlantSymptom.yellowingLeaves],
        wateringFrequency: WateringFrequency.frequent,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.4));
      expect(score, lessThanOrEqualTo(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.medium));
    });

    test('low confidence with only yellowing leaves', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.yellowingLeaves],
      );
      final score = rule.score(context);
      expect(score, lessThanOrEqualTo(0.4));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.low));
    });
  });

  group('UnderwateringRule', () {
    late UnderwateringRule rule;

    setUp(() {
      rule = UnderwateringRule();
    });

    test('high confidence with drooping + brown tips + curling + infrequent', () {
      const context = DiagnosisContext(
        symptoms: [
          PlantSymptom.droopingWilt,
          PlantSymptom.brownTips,
          PlantSymptom.leafCurling,
        ],
        wateringFrequency: WateringFrequency.infrequent,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.high));
    });

    test('medium confidence with brown tips + infrequent watering', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.brownTips],
        wateringFrequency: WateringFrequency.infrequent,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.4));
      expect(score, lessThanOrEqualTo(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.medium));
    });
  });

  group('LowLightRule', () {
    late LowLightRule rule;

    setUp(() {
      rule = LowLightRule();
    });

    test('high confidence with leggy growth + low light', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.leggyGrowth, PlantSymptom.paleLeaves],
        lightExposure: LightExposure.low,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.high));
    });

    test('medium confidence with pale leaves + low light', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.paleLeaves],
        lightExposure: LightExposure.low,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.4));
      expect(score, lessThanOrEqualTo(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.medium));
    });
  });

  group('SunburnRule', () {
    late SunburnRule rule;

    setUp(() {
      rule = SunburnRule();
    });

    test('high confidence with scorched patches + direct sun', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.brownPatches],
        lightExposure: LightExposure.direct,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.high));
    });

    test('medium confidence with scorched patches + yellowing', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.brownPatches, PlantSymptom.yellowingLeaves],
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.4));
      expect(score, lessThanOrEqualTo(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.medium));
    });
  });

  group('LowHumidityRule', () {
    late LowHumidityRule rule;

    setUp(() {
      rule = LowHumidityRule();
    });

    test('high confidence with brown tips + low humidity', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.brownTips, PlantSymptom.leafCurling],
        humidityLevel: HumidityLevel.low,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.high));
    });

    test('medium confidence with brown tips + curling', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.brownTips, PlantSymptom.leafCurling],
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.4));
      expect(score, lessThanOrEqualTo(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.medium));
    });
  });

  group('NutrientProblemRule', () {
    late NutrientProblemRule rule;

    setUp(() {
      rule = NutrientProblemRule();
    });

    test('unknown fertilizing answer does not boost nutrient-deficiency score', () {
      // Arrange
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.paleLeaves, PlantSymptom.stuntedGrowth],
      );

      // Act
      final score = rule.score(context);

      // Assert
      expect((score, rule.confidenceFromScore(score)), equals((0.5, ConfidenceLevel.medium)));
    });

    test('explicit negative fertilizing answer boosts nutrient-deficiency score', () {
      // Arrange
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.paleLeaves, PlantSymptom.stuntedGrowth],
        recentFertilizing: false,
      );

      // Act
      final score = rule.score(context);

      // Assert
      expect((score, rule.confidenceFromScore(score)), equals((0.75, ConfidenceLevel.high)));
    });

    test('medium confidence with pale leaves + stunted growth + recent fertilizing', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.paleLeaves, PlantSymptom.stuntedGrowth],
        recentFertilizing: true,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.4));
      expect(score, lessThanOrEqualTo(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.medium));
    });
  });

  group('RootIssueRule', () {
    late RootIssueRule rule;

    setUp(() {
      rule = RootIssueRule();
    });

    test('high confidence with all symptoms + frequent watering', () {
      const context = DiagnosisContext(
        symptoms: [
          PlantSymptom.droopingWilt,
          PlantSymptom.stuntedGrowth,
          PlantSymptom.foulSmell,
          PlantSymptom.moldOnSoil,
        ],
        wateringFrequency: WateringFrequency.frequent,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.high));
    });

    test('medium confidence with foul smell + mold', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.foulSmell, PlantSymptom.moldOnSoil],
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.4));
      expect(score, lessThanOrEqualTo(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.medium));
    });
  });

  group('PestRule', () {
    late PestRule rule;

    setUp(() {
      rule = PestRule();
    });

    test('high confidence with visible insects + sticky residue', () {
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.visibleInsects, PlantSymptom.stickyResidue],
        pestSigns: true,
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.high));
    });

    test('medium confidence with visible insects + leaf drop + yellowing', () {
      const context = DiagnosisContext(
        symptoms: [
          PlantSymptom.visibleInsects,
          PlantSymptom.leafDrop,
          PlantSymptom.yellowingLeaves,
        ],
      );
      final score = rule.score(context);
      expect(score, greaterThan(0.4));
      expect(score, lessThanOrEqualTo(0.7));
      expect(rule.confidenceFromScore(score), equals(ConfidenceLevel.medium));
    });
  });

  group('ConfidenceLevel', () {
    test('confidenceFromScore returns high for score > 0.7', () {
      final rule = OverwateringRule();
      expect(rule.confidenceFromScore(0.8), equals(ConfidenceLevel.high));
      expect(rule.confidenceFromScore(1), equals(ConfidenceLevel.high));
    });

    test('confidenceFromScore returns medium for 0.4 < score <= 0.7', () {
      final rule = OverwateringRule();
      expect(rule.confidenceFromScore(0.5), equals(ConfidenceLevel.medium));
      expect(rule.confidenceFromScore(0.7), equals(ConfidenceLevel.medium));
    });

    test('confidenceFromScore returns low for score <= 0.4', () {
      final rule = OverwateringRule();
      expect(rule.confidenceFromScore(0.3), equals(ConfidenceLevel.low));
      expect(rule.confidenceFromScore(0), equals(ConfidenceLevel.low));
    });
  });

  group('DiagnosisEngine.withRules', () {
    test('uses custom rules', () {
      final customRule = _ConstantRule(0.8);
      final engine = DiagnosisEngine.withRules([customRule]);
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.yellowingLeaves],
      );
      final result = engine.evaluate(context);
      expect(result.causes.length, equals(1));
      expect(result.causes.first.causeId, equals('custom'));
      expect(result.causes.first.score, equals(0.8));
    });

    test('returns no-clear-match fallback when all rules are below threshold', () {
      // Arrange
      final customRule = _ConstantRule(0.1);
      final engine = DiagnosisEngine.withRules([customRule]);
      const context = DiagnosisContext(
        symptoms: [PlantSymptom.yellowingLeaves],
      );

      // Act
      final result = engine.evaluate(context);

      // Assert
      expect(
        (
          result.type,
          result.hasResults,
          result.isEmptyInput,
          result.isNoClearMatch,
          result.causes.length,
          result.causes.single.causeId,
          result.causes.single.score,
          result.causes.single.confidence,
        ),
        equals(
          (
            DiagnosisResultType.noClearMatch,
            false,
            false,
            true,
            1,
            'no_clear_match',
            0,
            ConfidenceLevel.low,
          ),
        ),
      );
    });
  });
}

class _ConstantRule extends DiagnosisRule {
  final double _score;

  _ConstantRule(this._score);

  @override
  String get causeId => 'custom';

  @override
  double score(DiagnosisContext context) => _score;
}
