import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plant/pages/diagnosis/diagnosis_datasource.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_repository.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_usecases.dart';

void main() {
  late DiagnosisDataSource dataSource;
  late DiagnosisRepository repository;
  late DiagnosisEngine engine;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dataSource = DiagnosisDataSource();
    engine = DiagnosisEngine();
    repository = DiagnosisRepository(
      engine: engine,
      dataSource: dataSource,
    );
  });

  /// Helper to create a test entity.
  DiagnosisResultEntity makeEntity({
    String id = '',
    String plantId = 'plant-1',
  }) {
    return DiagnosisResultEntity(
      id: id,
      plantId: plantId,
      plantSymptoms: const [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
      causes: const [
        ScoredCause(
          causeId: 'overwatering',
          confidence: ConfidenceLevel.high,
          evidence: 'Yellowing leaves.',
          recommendedActions: ['Water less.'],
          followUpChecks: ['Check roots.'],
          score: 0.8,
        ),
      ],
      type: DiagnosisResultType.rankedCauses,
      context: const DiagnosisContext(
        symptoms: [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
        wateringFrequency: WateringFrequency.frequent,
      ),
      createdAt: DateTime(2026, 1, 15),
    );
  }

  group('DiagnosisRepository', () {
    group('evaluate', () {
      test('delegates to engine and returns DiagnosisResult', () {
        // Arrange
        const context = DiagnosisContext(
          symptoms: [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
          wateringFrequency: WateringFrequency.frequent,
        );

        // Act
        final result = repository.evaluate(context);

        // Assert
        expect(result, isA<DiagnosisResult>());
        expect(result.hasResults, isTrue);
        expect(result.causes, isNotEmpty);
      });

      test('returns empty input for no symptoms', () {
        // Arrange
        const context = DiagnosisContext(symptoms: []);

        // Act
        final result = repository.evaluate(context);

        // Assert
        expect(result.isEmptyInput, isTrue);
        expect(result.causes, isEmpty);
      });
    });

    group('saveResult', () {
      test('generates UUID and persists entity', () async {
        // Arrange
        final entity = makeEntity();

        // Act
        final saved = await repository.saveResult(entity);

        // Assert
        expect(saved.id, isNotEmpty);
        expect(saved.id, isNot(equals('')));
        expect(saved.id.length, equals(36)); // UUID v4 format
        expect(saved.plantId, equals('plant-1'));
      });

      test('generated IDs are unique across multiple saves', () async {
        // Arrange
        final entity1 = makeEntity();
        final entity2 = makeEntity();

        // Act
        final saved1 = await repository.saveResult(entity1);
        final saved2 = await repository.saveResult(entity2);

        // Assert
        expect(saved1.id, isNot(equals(saved2.id)));
      });

      test('saved entity can be retrieved by ID', () async {
        // Arrange
        final entity = makeEntity();

        // Act
        final saved = await repository.saveResult(entity);
        final retrieved = await repository.getResultById(saved.id);

        // Assert
        expect(retrieved, isNotNull);
        expect(retrieved!.id, equals(saved.id));
        expect(retrieved.plantId, equals('plant-1'));
      });
    });

    group('getAllResults', () {
      test('returns all persisted results', () async {
        // Arrange
        await repository.saveResult(makeEntity(plantId: 'plant-A'));
        await repository.saveResult(makeEntity(plantId: 'plant-B'));

        // Act
        final results = await repository.getAllResults();

        // Assert
        expect(results.length, equals(2));
      });

      test('returns empty list when no results exist', () async {
        // Act
        final results = await repository.getAllResults();

        // Assert
        expect(results, isEmpty);
      });
    });

    group('getResultsByPlant', () {
      test('returns filtered results for a specific plant', () async {
        // Arrange
        await repository.saveResult(makeEntity(plantId: 'plant-A'));
        await repository.saveResult(makeEntity(plantId: 'plant-B'));
        await repository.saveResult(makeEntity(plantId: 'plant-A'));

        // Act
        final results = await repository.getResultsByPlant('plant-A');

        // Assert
        expect(results.length, equals(2));
        expect(results.every((r) => r.plantId == 'plant-A'), isTrue);
      });

      test('returns empty list for plant with no results', () async {
        // Arrange
        await repository.saveResult(makeEntity(plantId: 'plant-B'));

        // Act
        final results = await repository.getResultsByPlant('plant-A');

        // Assert
        expect(results, isEmpty);
      });
    });

    group('getResultById', () {
      test('returns correct entity by ID', () async {
        // Arrange
        final saved = await repository.saveResult(makeEntity());

        // Act
        final result = await repository.getResultById(saved.id);

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(saved.id));
      });

      test('returns null for nonexistent ID', () async {
        // Act
        final result = await repository.getResultById('nonexistent-id');

        // Assert
        expect(result, isNull);
      });
    });

    group('deleteResult', () {
      test('removes entity by ID', () async {
        // Arrange
        final saved = await repository.saveResult(makeEntity());

        // Act
        await repository.deleteResult(saved.id);
        final result = await repository.getResultById(saved.id);

        // Assert
        expect(result, isNull);
      });

      test('delete does not affect other records', () async {
        // Arrange
        final saved1 = await repository.saveResult(makeEntity(plantId: 'plant-A'));
        final saved2 = await repository.saveResult(makeEntity(plantId: 'plant-B'));

        // Act
        await repository.deleteResult(saved1.id);
        final remaining = await repository.getAllResults();

        // Assert
        expect(remaining.length, equals(1));
        expect(remaining.first.id, equals(saved2.id));
      });
    });

    group('full workflow', () {
      test('evaluate, save, retrieve, delete works end-to-end', () async {
        // Arrange
        const context = DiagnosisContext(
          symptoms: [PlantSymptom.yellowingLeaves, PlantSymptom.droopingWilt],
          wateringFrequency: WateringFrequency.frequent,
        );

        // Act — evaluate
        final result = repository.evaluate(context);
        expect(result.hasResults, isTrue);

        // Act — save
        final entity = DiagnosisResultEntity(
          id: '',
          plantId: 'workflow-plant',
          plantSymptoms: context.symptoms,
          causes: result.causes,
          type: result.type,
          context: context,
          createdAt: DateTime.now(),
        );
        final saved = await repository.saveResult(entity);

        // Act — retrieve
        final retrieved = await repository.getResultById(saved.id);
        expect(retrieved, isNotNull);
        expect(retrieved!.causes.length, equals(result.causes.length));

        // Act — delete
        await repository.deleteResult(saved.id);
        final deleted = await repository.getResultById(saved.id);
        expect(deleted, isNull);
      });
    });
  });
}
