import 'dart:convert';

import 'package:test/test.dart';

import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_result_entity.dart';

void main() {
  group('DiagnosisResultEntity JSON serialization edge cases', () {
    group('full JSON roundtrip', () {
      test('roundtrip with all fields populated', () {
        // Arrange
        final original = DiagnosisResultEntity(
          id: 'full-roundtrip-id',
          plantId: 'plant-full',
          symptomLogEntryId: 'symptom-full',
          plantSymptoms: [
            PlantSymptom.yellowingLeaves,
            PlantSymptom.droopingWilt,
            PlantSymptom.brownTips,
            PlantSymptom.visibleInsects,
            PlantSymptom.moldOnSoil,
          ],
          causes: [
            const ScoredCause(
              causeId: 'overwatering',
              confidence: ConfidenceLevel.high,
              evidence: 'Multiple symptoms indicate overwatering.',
              recommendedActions: ['Reduce watering.', 'Check drainage.'],
              followUpChecks: ['Inspect roots.', 'Monitor soil moisture.'],
              score: 0.9,
            ),
            const ScoredCause(
              causeId: 'pests',
              confidence: ConfidenceLevel.medium,
              evidence: 'Visible insects detected.',
              recommendedActions: ['Apply neem oil.', 'Isolate plant.'],
              followUpChecks: ['Check under leaves.'],
              score: 0.6,
            ),
          ],
          type: DiagnosisResultType.rankedCauses,
          context: const DiagnosisContext(
            symptoms: [
              PlantSymptom.yellowingLeaves,
              PlantSymptom.droopingWilt,
              PlantSymptom.brownTips,
              PlantSymptom.visibleInsects,
              PlantSymptom.moldOnSoil,
            ],
            plantSpecies: 'Ficus benjamina',
            potType: PotType.noDrainage,
            soilType: SoilType.standard,
            wateringFrequency: WateringFrequency.frequent,
            lightExposure: LightExposure.indirect,
            humidityLevel: HumidityLevel.low,
            recentFertilizing: false,
            pestSigns: true,
          ),
          createdAt: DateTime(2026, 7, 10, 14, 30),
        );

        // Act
        final jsonString = jsonEncode(original.toJson());
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final restored = DiagnosisResultEntity.fromJson(decoded);

        // Assert
        expect(restored.id, equals(original.id));
        expect(restored.plantId, equals(original.plantId));
        expect(restored.symptomLogEntryId, equals(original.symptomLogEntryId));
        expect(restored.plantSymptoms.length, equals(5));
        expect(restored.causes.length, equals(2));
        expect(restored.causes[0].causeId, equals('overwatering'));
        expect(restored.causes[1].causeId, equals('pests'));
        expect(restored.type, equals(DiagnosisResultType.rankedCauses));
        expect(restored.context.plantSpecies, equals('Ficus benjamina'));
        expect(restored.context.potType, equals(PotType.noDrainage));
        expect(restored.context.recentFertilizing, isFalse);
        expect(restored.context.pestSigns, isTrue);
        expect(restored.createdAt, equals(original.createdAt));
      });

      test('roundtrip preserves DateTime precision', () {
        // Arrange
        final original = DiagnosisResultEntity(
          id: 'precision-test',
          plantId: 'plant',
          plantSymptoms: const [PlantSymptom.leafSpots],
          causes: const [],
          type: DiagnosisResultType.emptyInput,
          context: const DiagnosisContext(symptoms: []),
          createdAt: DateTime(2026, 3, 15, 9, 45, 30, 123, 456),
        );

        // Act
        final json = original.toJson();
        final restored = DiagnosisResultEntity.fromJson(json);

        // Assert
        expect(restored.createdAt, equals(original.createdAt));
      });

      test('decodes manual diagnosis records without a symptom log ID', () {
        // Arrange
        final original = DiagnosisResultEntity(
          id: 'manual-diagnosis',
          plantId: 'plant',
          plantSymptoms: const [PlantSymptom.leafSpots],
          causes: const [],
          type: DiagnosisResultType.emptyInput,
          context: const DiagnosisContext(symptoms: []),
          createdAt: DateTime(2026),
        );
        final json = original.toJson()..remove('symptomLogEntryId');

        // Act
        final restored = DiagnosisResultEntity.fromJson(json);

        // Assert
        expect(restored.symptomLogEntryId, isNull);
      });
    });

    group('empty causes', () {
      test('entity with empty causes list roundtrips correctly', () {
        // Arrange
        final original = DiagnosisResultEntity(
          id: 'empty-causes',
          plantId: 'plant',
          plantSymptoms: const [PlantSymptom.yellowingLeaves],
          causes: const [],
          type: DiagnosisResultType.emptyInput,
          context: const DiagnosisContext(symptoms: []),
          createdAt: DateTime(2026),
        );

        // Act
        final json = original.toJson();
        final restored = DiagnosisResultEntity.fromJson(json);

        // Assert
        expect(restored.causes, isEmpty);
        expect(restored.toJson()['causes'], equals([]));
      });

      test('noClearMatch entity with fallback cause roundtrips correctly', () {
        // Arrange
        final original = DiagnosisResultEntity(
          id: 'no-match',
          plantId: 'plant',
          plantSymptoms: const [PlantSymptom.softStems],
          causes: const [
            ScoredCause(
              causeId: 'no_clear_match',
              confidence: ConfidenceLevel.low,
              evidence: 'No single cause stood out.',
              recommendedActions: ['Check light.'],
              followUpChecks: ['Try again.'],
              score: 0,
            ),
          ],
          type: DiagnosisResultType.noClearMatch,
          context: const DiagnosisContext(symptoms: [PlantSymptom.softStems]),
          createdAt: DateTime(2026),
        );

        // Act
        final json = original.toJson();
        final restored = DiagnosisResultEntity.fromJson(json);

        // Assert
        expect(restored.type, equals(DiagnosisResultType.noClearMatch));
        expect(restored.causes.first.causeId, equals('no_clear_match'));
        expect(restored.causes.first.score, equals(0));
      });
    });

    group('special characters in strings', () {
      test('evidence with unicode characters roundtrips correctly', () {
        // Arrange
        const cause = ScoredCause(
          causeId: 'test_unicode',
          confidence: ConfidenceLevel.low,
          evidence: 'Plant shows \u{1F343} and \u{1F342} symptoms. Temperature: \u00B0C.',
          recommendedActions: ['Action with \u00E9\u00E8\u00EA characters.'],
          followUpChecks: ['Check \u2611\uFE0F checkbox.'],
          score: 0.5,
        );

        // Act
        final json = cause.toJson();
        final jsonString = jsonEncode(json);
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final restored = ScoredCause.fromJson(decoded);

        // Assert
        expect(restored.evidence, equals(cause.evidence));
        expect(restored.recommendedActions.first, equals(cause.recommendedActions.first));
      });

      test('evidence with newlines and quotes roundtrips correctly', () {
        // Arrange
        const cause = ScoredCause(
          causeId: 'test_newlines',
          confidence: ConfidenceLevel.medium,
          evidence: 'Line 1\nLine 2\n"Quoted" and \'apostrophe\'.',
          recommendedActions: ['Step 1: "Do this"', "Step 2: Don't do that."],
          followUpChecks: [],
          score: 0.4,
        );

        // Act
        final json = cause.toJson();
        final jsonString = jsonEncode(json);
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final restored = ScoredCause.fromJson(decoded);

        // Assert
        expect(restored.evidence, equals(cause.evidence));
        expect(restored.recommendedActions, equals(cause.recommendedActions));
      });

      test('plantSpecies with special characters roundtrips correctly', () {
        // Arrange
        final original = DiagnosisResultEntity(
          id: 'special-species',
          plantId: 'plant',
          plantSymptoms: const [PlantSymptom.yellowingLeaves],
          causes: const [],
          type: DiagnosisResultType.emptyInput,
          context: const DiagnosisContext(
            symptoms: [PlantSymptom.yellowingLeaves],
            plantSpecies: 'Monstera deliciosa var. borsigiana',
          ),
          createdAt: DateTime(2026),
        );

        // Act
        final json = original.toJson();
        final jsonString = jsonEncode(json);
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final restored = DiagnosisResultEntity.fromJson(decoded);

        // Assert
        expect(restored.context.plantSpecies, equals('Monstera deliciosa var. borsigiana'));
      });
    });

    group('ScoredCause with many actions', () {
      test('roundtrip preserves all recommendedActions and followUpChecks', () {
        // Arrange
        const cause = ScoredCause(
          causeId: 'overwatering',
          confidence: ConfidenceLevel.high,
          evidence: 'Classic overwatering.',
          recommendedActions: [
            'Allow top soil to dry.',
            'Check drainage holes.',
            'Trim rotten roots.',
            'Repot in fresh soil.',
            'Reduce watering frequency.',
          ],
          followUpChecks: [
            'Check root color.',
            'Monitor soil moisture.',
            'Observe leaf recovery.',
          ],
          score: 0.85,
        );

        // Act
        final json = cause.toJson();
        final restored = ScoredCause.fromJson(json);

        // Assert
        expect(restored.recommendedActions.length, equals(5));
        expect(restored.followUpChecks.length, equals(3));
      });
    });

    group('DiagnosisResultEntity JSON string roundtrip', () {
      test('full entity serializes to valid JSON string and back', () {
        // Arrange
        final original = DiagnosisResultEntity(
          id: 'json-string-test',
          plantId: 'plant',
          plantSymptoms: const [PlantSymptom.yellowingLeaves, PlantSymptom.leafCurling],
          causes: const [
            ScoredCause(
              causeId: 'underwatering',
              confidence: ConfidenceLevel.medium,
              evidence: 'Leaf curling and yellowing.',
              recommendedActions: ['Water more.'],
              followUpChecks: ['Check soil.'],
              score: 0.55,
            ),
          ],
          type: DiagnosisResultType.rankedCauses,
          context: const DiagnosisContext(
            symptoms: [PlantSymptom.yellowingLeaves, PlantSymptom.leafCurling],
            wateringFrequency: WateringFrequency.infrequent,
          ),
          createdAt: DateTime(2026, 8, 15),
        );

        // Act
        final jsonString = jsonEncode(original.toJson());
        final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
        final restored = DiagnosisResultEntity.fromJson(decoded);

        // Assert
        expect(restored.id, equals(original.id));
        expect(restored.plantId, equals(original.plantId));
        expect(restored.plantSymptoms, equals(original.plantSymptoms));
        expect(restored.causes.length, equals(original.causes.length));
        expect(restored.type, equals(original.type));
        expect(restored.context.symptoms, equals(original.context.symptoms));
        expect(restored.context.wateringFrequency, equals(original.context.wateringFrequency));
        expect(restored.createdAt, equals(original.createdAt));
      });
    });

    group('all enum values roundtrip', () {
      test('all PlantSymptom values survive JSON roundtrip', () {
        for (final symptom in PlantSymptom.values) {
          final entity = DiagnosisResultEntity(
            id: 'sym-${symptom.name}',
            plantId: 'plant',
            plantSymptoms: [symptom],
            causes: const [],
            type: DiagnosisResultType.rankedCauses,
            context: DiagnosisContext(symptoms: [symptom]),
            createdAt: DateTime(2026),
          );

          final json = entity.toJson();
          final restored = DiagnosisResultEntity.fromJson(json);

          expect(restored.plantSymptoms.first, equals(symptom), reason: 'Failed for ${symptom.name}');
        }
      });

      test('all DiagnosisResultType values survive JSON roundtrip', () {
        for (final type in DiagnosisResultType.values) {
          final entity = DiagnosisResultEntity(
            id: 'type-${type.name}',
            plantId: 'plant',
            plantSymptoms: const [PlantSymptom.leafSpots],
            causes: const [],
            type: type,
            context: const DiagnosisContext(symptoms: []),
            createdAt: DateTime(2026),
          );

          final json = entity.toJson();
          final restored = DiagnosisResultEntity.fromJson(json);

          expect(restored.type, equals(type), reason: 'Failed for ${type.name}');
        }
      });

      test('all ConfidenceLevel values survive JSON roundtrip via ScoredCause', () {
        for (final level in ConfidenceLevel.values) {
          final cause = ScoredCause(
            causeId: 'test-${level.name}',
            confidence: level,
            evidence: 'Test.',
            recommendedActions: const [],
            followUpChecks: const [],
            score: 0.5,
          );

          final json = cause.toJson();
          final restored = ScoredCause.fromJson(json);

          expect(restored.confidence, equals(level), reason: 'Failed for ${level.name}');
        }
      });
    });
  });
}
