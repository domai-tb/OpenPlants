import 'package:test/test.dart';

import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_result_entity.dart';

void main() {
  group('DiagnosisResultEntity serialization', () {
    group('toJson/fromJson roundtrip', () {
      test('roundtrip preserves all fields', () {
        // Arrange
        final original = DiagnosisResultEntity(
          id: 'test-id-123',
          plantId: 'plant-456',
          plantSymptoms: const [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
          causes: const [
            ScoredCause(
              causeId: 'overwatering',
              confidence: ConfidenceLevel.high,
              evidence: 'Yellowing leaves with frequent watering.',
              recommendedActions: ['Reduce watering frequency.'],
              followUpChecks: ['Check root health.'],
              score: 0.85,
            ),
          ],
          type: DiagnosisResultType.rankedCauses,
          context: const DiagnosisContext(
            symptoms: [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
            wateringFrequency: WateringFrequency.frequent,
            potType: PotType.noDrainage,
          ),
          createdAt: DateTime(2026, 1, 15, 10, 30),
        );

        // Act
        final json = original.toJson();
        final restored = DiagnosisResultEntity.fromJson(json);

        // Assert
        expect(restored.id, equals(original.id));
        expect(restored.plantId, equals(original.plantId));
        expect(restored.plantSymptoms, equals(original.plantSymptoms));
        expect(restored.causes.length, equals(original.causes.length));
        expect(restored.causes.first.causeId, equals('overwatering'));
        expect(restored.causes.first.score, equals(0.85));
        expect(restored.type, equals(original.type));
        expect(restored.context.symptoms, equals(original.context.symptoms));
        expect(restored.context.wateringFrequency, equals(WateringFrequency.frequent));
        expect(restored.context.potType, equals(PotType.noDrainage));
        expect(restored.createdAt, equals(original.createdAt));
      });

      test('roundtrip with minimal fields', () {
        // Arrange
        final original = DiagnosisResultEntity(
          id: 'minimal-id',
          plantId: 'plant-min',
          plantSymptoms: const [PlantSymptom.leafSpots],
          causes: const [],
          type: DiagnosisResultType.emptyInput,
          context: const DiagnosisContext(symptoms: []),
          createdAt: DateTime(2026, 6),
        );

        // Act
        final json = original.toJson();
        final restored = DiagnosisResultEntity.fromJson(json);

        // Assert
        expect(restored.id, equals('minimal-id'));
        expect(restored.causes, isEmpty);
        expect(restored.type, equals(DiagnosisResultType.emptyInput));
      });
    });

    group('PlantSymptom serialization', () {
      test('all PlantSymptom values serialize and deserialize correctly', () {
        for (final symptom in PlantSymptom.values) {
          // Act
          final json = symptom.toJson();
          final restored = PlantSymptomJson.fromJson(json);

          // Assert
          expect(restored, equals(symptom), reason: 'Failed for ${symptom.name}');
        }
      });

      test('fromJson returns yellowingLeaves for unknown symptom name', () {
        // Act
        final restored = PlantSymptomJson.fromJson('unknownSymptom');

        // Assert
        expect(restored, equals(PlantSymptom.yellowingLeaves));
      });
    });

    group('ScoredCause serialization', () {
      test('toJson/fromJson roundtrip preserves all fields', () {
        // Arrange
        const original = ScoredCause(
          causeId: 'underwatering',
          confidence: ConfidenceLevel.medium,
          evidence: 'Brown leaf tips suggest underwatering.',
          recommendedActions: ['Water thoroughly.', 'Establish a schedule.'],
          followUpChecks: ['Check root ball.'],
          score: 0.55,
        );

        // Act
        final json = original.toJson();
        final restored = ScoredCause.fromJson(json);

        // Assert
        expect(restored.causeId, equals('underwatering'));
        expect(restored.confidence, equals(ConfidenceLevel.medium));
        expect(restored.evidence, equals('Brown leaf tips suggest underwatering.'));
        expect(restored.recommendedActions, equals(['Water thoroughly.', 'Establish a schedule.']));
        expect(restored.followUpChecks, equals(['Check root ball.']));
        expect(restored.score, equals(0.55));
      });

      test('ScoredCause with empty lists serializes correctly', () {
        // Arrange
        const original = ScoredCause(
          causeId: 'unknown',
          confidence: ConfidenceLevel.low,
          evidence: 'No clear evidence.',
          recommendedActions: [],
          followUpChecks: [],
          score: 0.1,
        );

        // Act
        final json = original.toJson();
        final restored = ScoredCause.fromJson(json);

        // Assert
        expect(restored.recommendedActions, isEmpty);
        expect(restored.followUpChecks, isEmpty);
      });

      test('all ConfidenceLevel values serialize correctly', () {
        for (final level in ConfidenceLevel.values) {
          // Arrange
          final cause = ScoredCause(
            causeId: 'test',
            confidence: level,
            evidence: 'Test evidence.',
            recommendedActions: const [],
            followUpChecks: const [],
            score: 0.5,
          );

          // Act
          final json = cause.toJson();
          final restored = ScoredCause.fromJson(json);

          // Assert
          expect(restored.confidence, equals(level), reason: 'Failed for ${level.name}');
        }
      });
    });

    group('DiagnosisContext serialization', () {
      test('toMap/fromMap roundtrip with all optional fields', () {
        // Arrange
        const original = DiagnosisContext(
          symptoms: [PlantSymptom.brownTips, PlantSymptom.leafCurling],
          plantSpecies: 'Monstera deliciosa',
          potType: PotType.selfWatering,
          soilType: SoilType.orchid,
          wateringFrequency: WateringFrequency.normal,
          lightExposure: LightExposure.indirect,
          humidityLevel: HumidityLevel.moderate,
          recentFertilizing: true,
          pestSigns: false,
        );

        // Act
        final map = original.toMap();
        final restored = DiagnosisContext.fromMap(map);

        // Assert
        expect(restored.symptoms, equals(original.symptoms));
        expect(restored.plantSpecies, equals('Monstera deliciosa'));
        expect(restored.potType, equals(PotType.selfWatering));
        expect(restored.soilType, equals(SoilType.orchid));
        expect(restored.wateringFrequency, equals(WateringFrequency.normal));
        expect(restored.lightExposure, equals(LightExposure.indirect));
        expect(restored.humidityLevel, equals(HumidityLevel.moderate));
        expect(restored.recentFertilizing, isTrue);
        expect(restored.pestSigns, isFalse);
      });

      test('toMap/fromMap roundtrip with null optional fields', () {
        // Arrange
        const original = DiagnosisContext(
          symptoms: [PlantSymptom.yellowingLeaves],
        );

        // Act
        final map = original.toMap();
        final restored = DiagnosisContext.fromMap(map);

        // Assert
        expect(restored.symptoms, equals([PlantSymptom.yellowingLeaves]));
        expect(restored.plantSpecies, isNull);
        expect(restored.potType, isNull);
        expect(restored.soilType, isNull);
        expect(restored.wateringFrequency, isNull);
        expect(restored.lightExposure, isNull);
        expect(restored.humidityLevel, isNull);
        expect(restored.recentFertilizing, isNull);
        expect(restored.pestSigns, isNull);
      });

      test('all PotType values serialize correctly', () {
        for (final potType in PotType.values) {
          // Arrange
          final ctx = DiagnosisContext(
            symptoms: const [],
            potType: potType,
          );

          // Act
          final map = ctx.toMap();
          final restored = DiagnosisContext.fromMap(map);

          // Assert
          expect(restored.potType, equals(potType), reason: 'Failed for ${potType.name}');
        }
      });

      test('all WateringFrequency values serialize correctly', () {
        for (final freq in WateringFrequency.values) {
          // Arrange
          final ctx = DiagnosisContext(
            symptoms: const [],
            wateringFrequency: freq,
          );

          // Act
          final map = ctx.toMap();
          final restored = DiagnosisContext.fromMap(map);

          // Assert
          expect(restored.wateringFrequency, equals(freq), reason: 'Failed for ${freq.name}');
        }
      });

      test('all LightExposure values serialize correctly', () {
        for (final light in LightExposure.values) {
          // Arrange
          final ctx = DiagnosisContext(
            symptoms: const [],
            lightExposure: light,
          );

          // Act
          final map = ctx.toMap();
          final restored = DiagnosisContext.fromMap(map);

          // Assert
          expect(restored.lightExposure, equals(light), reason: 'Failed for ${light.name}');
        }
      });

      test('all HumidityLevel values serialize correctly', () {
        for (final humidity in HumidityLevel.values) {
          // Arrange
          final ctx = DiagnosisContext(
            symptoms: const [],
            humidityLevel: humidity,
          );

          // Act
          final map = ctx.toMap();
          final restored = DiagnosisContext.fromMap(map);

          // Assert
          expect(restored.humidityLevel, equals(humidity), reason: 'Failed for ${humidity.name}');
        }
      });

      test('all SoilType values serialize correctly', () {
        for (final soil in SoilType.values) {
          // Arrange
          final ctx = DiagnosisContext(
            symptoms: const [],
            soilType: soil,
          );

          // Act
          final map = ctx.toMap();
          final restored = DiagnosisContext.fromMap(map);

          // Assert
          expect(restored.soilType, equals(soil), reason: 'Failed for ${soil.name}');
        }
      });
    });

    group('DiagnosisResultType serialization', () {
      test('all DiagnosisResultType values serialize correctly via entity', () {
        for (final type in DiagnosisResultType.values) {
          // Arrange
          final entity = DiagnosisResultEntity(
            id: 'id-${type.name}',
            plantId: 'plant',
            plantSymptoms: const [PlantSymptom.yellowingLeaves],
            causes: const [],
            type: type,
            context: const DiagnosisContext(symptoms: []),
            createdAt: DateTime(2026),
          );

          // Act
          final json = entity.toJson();
          final restored = DiagnosisResultEntity.fromJson(json);

          // Assert
          expect(restored.type, equals(type), reason: 'Failed for ${type.name}');
        }
      });
    });

    group('edge cases', () {
      test('empty plantSymptoms list', () {
        // Arrange
        final entity = DiagnosisResultEntity(
          id: 'empty-symptoms',
          plantId: 'plant',
          plantSymptoms: const [],
          causes: const [],
          type: DiagnosisResultType.emptyInput,
          context: const DiagnosisContext(symptoms: []),
          createdAt: DateTime(2026),
        );

        // Act
        final json = entity.toJson();
        final restored = DiagnosisResultEntity.fromJson(json);

        // Assert
        expect(restored.plantSymptoms, isEmpty);
      });

      test('many symptoms serialize correctly', () {
        // Arrange
        final entity = DiagnosisResultEntity(
          id: 'many-symptoms',
          plantId: 'plant',
          plantSymptoms: PlantSymptom.values.toList(),
          causes: const [],
          type: DiagnosisResultType.rankedCauses,
          context: DiagnosisContext(symptoms: PlantSymptom.values.toList()),
          createdAt: DateTime(2026),
        );

        // Act
        final json = entity.toJson();
        final restored = DiagnosisResultEntity.fromJson(json);

        // Assert
        expect(restored.plantSymptoms.length, equals(PlantSymptom.values.length));
      });

      test('special characters in evidence string', () {
        // Arrange
        const cause = ScoredCause(
          causeId: 'test',
          confidence: ConfidenceLevel.low,
          evidence: 'Evidence with "quotes" and \'apostrophes\' and newlines\nand tabs\t.',
          recommendedActions: ['Action with unicode: \u{1F331}'],
          followUpChecks: [],
          score: 0.3,
        );

        // Act
        final json = cause.toJson();
        final restored = ScoredCause.fromJson(json);

        // Assert
        expect(restored.evidence, equals(cause.evidence));
        expect(restored.recommendedActions.first, equals('Action with unicode: \u{1F331}'));
      });
    });

    group('copyWith', () {
      test('copyWith preserves unchanged fields', () {
        // Arrange
        final original = DiagnosisResultEntity(
          id: 'original-id',
          plantId: 'plant',
          plantSymptoms: const [PlantSymptom.yellowingLeaves],
          causes: const [],
          type: DiagnosisResultType.rankedCauses,
          context: const DiagnosisContext(symptoms: [PlantSymptom.yellowingLeaves]),
          createdAt: DateTime(2026),
        );

        // Act
        final copy = original.copyWith(plantId: 'new-plant');

        // Assert
        expect(copy.id, equals('original-id'));
        expect(copy.plantId, equals('new-plant'));
        expect(copy.plantSymptoms, equals([PlantSymptom.yellowingLeaves]));
        expect(copy.type, equals(DiagnosisResultType.rankedCauses));
      });
    });
  });
}
