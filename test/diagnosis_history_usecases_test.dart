import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plant/pages/diagnosis/diagnosis_datasource.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_history_usecases.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_repository.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_usecases.dart';

void main() {
  late DiagnosisHistoryUseCases useCases;
  late DiagnosisRepository repository;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final dataSource = DiagnosisDataSource();
    final engine = DiagnosisEngine();
    repository = DiagnosisRepository(
      engine: engine,
      dataSource: dataSource,
    );
    useCases = DiagnosisHistoryUseCases(repository: repository);
  });

  /// Helper to create and persist a test entity.
  Future<DiagnosisResultEntity> saveEntity({
    String plantId = 'plant-1',
    DateTime? createdAt,
  }) {
    final entity = DiagnosisResultEntity(
      id: '',
      plantId: plantId,
      plantSymptoms: const [PlantSymptom.yellowingLeaves],
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
      context: const DiagnosisContext(symptoms: [PlantSymptom.yellowingLeaves]),
      createdAt: createdAt ?? DateTime(2026, 1, 15),
    );
    return repository.saveResult(entity);
  }

  group('DiagnosisHistoryUseCases', () {
    group('getAllResults', () {
      test('returns all persisted results', () async {
        // Arrange
        await saveEntity(plantId: 'plant-A');
        await saveEntity(plantId: 'plant-B');

        // Act
        final results = await useCases.getAllResults();

        // Assert
        expect(results.length, equals(2));
      });

      test('returns empty list when no results exist', () async {
        // Act
        final results = await useCases.getAllResults();

        // Assert
        expect(results, isEmpty);
      });

      test('returns results sorted by date descending', () async {
        // Arrange
        await saveEntity(plantId: 'plant', createdAt: DateTime(2026));
        await saveEntity(plantId: 'plant', createdAt: DateTime(2026, 6, 15));
        await saveEntity(plantId: 'plant', createdAt: DateTime(2026, 3, 10));

        // Act
        final results = await useCases.getAllResults();

        // Assert
        expect(results.length, equals(3));
        // Newest first
        expect(results[0].createdAt.isAfter(results[1].createdAt), isTrue);
        expect(results[1].createdAt.isAfter(results[2].createdAt), isTrue);
      });
    });

    group('getResultsForPlant', () {
      test('returns results only for the specified plant', () async {
        // Arrange
        await saveEntity(plantId: 'plant-A');
        await saveEntity(plantId: 'plant-B');
        await saveEntity(plantId: 'plant-A');

        // Act
        final results = await useCases.getResultsForPlant('plant-A');

        // Assert
        expect(results.length, equals(2));
        expect(results.every((r) => r.plantId == 'plant-A'), isTrue);
      });

      test('returns empty list for plant with no results', () async {
        // Arrange
        await saveEntity(plantId: 'plant-B');

        // Act
        final results = await useCases.getResultsForPlant('plant-A');

        // Assert
        expect(results, isEmpty);
      });

      test('returns results sorted by date descending', () async {
        // Arrange
        await saveEntity(plantId: 'plant-A', createdAt: DateTime(2026));
        await saveEntity(plantId: 'plant-A', createdAt: DateTime(2026, 12));

        // Act
        final results = await useCases.getResultsForPlant('plant-A');

        // Assert
        expect(results.length, equals(2));
        expect(results[0].createdAt.isAfter(results[1].createdAt), isTrue);
      });
    });

    group('deleteResult', () {
      test('removes a result by ID', () async {
        // Arrange
        final saved = await saveEntity();

        // Act
        await useCases.deleteResult(saved.id);
        final results = await useCases.getAllResults();

        // Assert
        expect(results, isEmpty);
      });

      test('only removes the specified result', () async {
        // Arrange
        final saved1 = await saveEntity(plantId: 'plant-A');
        final saved2 = await saveEntity(plantId: 'plant-B');

        // Act
        await useCases.deleteResult(saved1.id);
        final results = await useCases.getAllResults();

        // Assert
        expect(results.length, equals(1));
        expect(results.first.id, equals(saved2.id));
      });

      test('delete nonexistent ID does not throw', () async {
        // Arrange
        await saveEntity();

        // Act & Assert
        expect(() => useCases.deleteResult('nonexistent-id'), returnsNormally);
        final results = await useCases.getAllResults();
        expect(results.length, equals(1));
      });
    });

    group('integration with repository', () {
      test('use cases reflect repository state changes', () async {
        // Arrange
        final saved = await saveEntity(plantId: 'plant-A');

        // Act & Assert — initial state
        var results = await useCases.getResultsForPlant('plant-A');
        expect(results.length, equals(1));

        // Act & Assert — after delete
        await useCases.deleteResult(saved.id);
        results = await useCases.getResultsForPlant('plant-A');
        expect(results, isEmpty);
      });
    });
  });
}
