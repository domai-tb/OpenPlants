import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/pages/diagnosis/diagnosis_datasource.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_result_entity.dart';

void main() {
  late DiagnosisDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    dataSource = DiagnosisDataSource();
  });

  /// Helper to create a test entity with the given parameters.
  DiagnosisResultEntity makeEntity({
    String id = 'test-id',
    String plantId = 'plant-1',
    DateTime? createdAt,
  }) {
    return DiagnosisResultEntity(
      id: id,
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
  }

  group('DiagnosisDataSource', () {
    group('save', () {
      test('save persists entity and getAll returns it', () async {
        // Arrange
        final entity = makeEntity(id: 'save-1');

        // Act
        await dataSource.save(entity);
        final results = await dataSource.getAll();

        // Assert
        expect(results.length, equals(1));
        expect(results.first.id, equals('save-1'));
      });

      test('save multiple entities returns all', () async {
        // Arrange
        final entity1 = makeEntity(id: 'multi-1', createdAt: DateTime(2026));
        final entity2 = makeEntity(id: 'multi-2', createdAt: DateTime(2026, 1, 2));

        // Act
        await dataSource.save(entity1);
        await dataSource.save(entity2);
        final results = await dataSource.getAll();

        // Assert
        expect(results.length, equals(2));
      });

      test('save replaces an existing entity with the same ID', () async {
        // Arrange
        await dataSource.save(makeEntity(id: 'existing'));
        final updated = makeEntity(id: 'existing', plantId: 'updated-plant');

        // Act
        await dataSource.save(updated);
        final results = await dataSource.getAll();

        // Assert
        expect(results, hasLength(1));
        expect(results.single.plantId, equals('updated-plant'));
      });
    });

    group('getAll', () {
      test('returns empty list when no records exist', () async {
        // Act
        final results = await dataSource.getAll();

        // Assert
        expect(results, isEmpty);
      });

      test('returns results sorted by createdAt descending (newest first)', () async {
        // Arrange
        final old = makeEntity(id: 'old', createdAt: DateTime(2026));
        final middle = makeEntity(id: 'middle', createdAt: DateTime(2026, 6, 15));
        final recent = makeEntity(id: 'recent', createdAt: DateTime(2026, 12, 31));

        // Act
        await dataSource.save(old);
        await dataSource.save(middle);
        await dataSource.save(recent);
        final results = await dataSource.getAll();

        // Assert
        expect(results.map((e) => e.id).toList(), equals(['recent', 'middle', 'old']));
      });
    });

    group('getAllByPlant', () {
      test('returns only results for the specified plant', () async {
        // Arrange
        await dataSource.save(makeEntity(id: 'a1', plantId: 'plant-A'));
        await dataSource.save(makeEntity(id: 'b1', plantId: 'plant-B'));
        await dataSource.save(makeEntity(id: 'a2', plantId: 'plant-A'));

        // Act
        final results = await dataSource.getAllByPlant('plant-A');

        // Assert
        expect(results.length, equals(2));
        expect(results.every((r) => r.plantId == 'plant-A'), isTrue);
      });

      test('returns empty list when no results match plant', () async {
        // Arrange
        await dataSource.save(makeEntity(id: 'b1', plantId: 'plant-B'));

        // Act
        final results = await dataSource.getAllByPlant('plant-A');

        // Assert
        expect(results, isEmpty);
      });

      test('returns results sorted by createdAt descending', () async {
        // Arrange
        await dataSource.save(
          makeEntity(id: 'a-old', plantId: 'plant-A', createdAt: DateTime(2026)),
        );
        await dataSource.save(
          makeEntity(id: 'a-new', plantId: 'plant-A', createdAt: DateTime(2026, 12)),
        );

        // Act
        final results = await dataSource.getAllByPlant('plant-A');

        // Assert
        expect(results.map((e) => e.id).toList(), equals(['a-new', 'a-old']));
      });
    });

    group('getById', () {
      test('returns correct entity by id', () async {
        // Arrange
        await dataSource.save(makeEntity(id: 'find-me'));
        await dataSource.save(makeEntity(id: 'not-me'));

        // Act
        final result = await dataSource.getById('find-me');

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('find-me'));
      });

      test('returns null when id does not exist', () async {
        // Arrange
        await dataSource.save(makeEntity(id: 'existing'));

        // Act
        final result = await dataSource.getById('nonexistent');

        // Assert
        expect(result, isNull);
      });

      test('returns null when no records exist', () async {
        // Act
        final result = await dataSource.getById('any-id');

        // Assert
        expect(result, isNull);
      });
    });

    group('delete', () {
      test('removes entity by id', () async {
        // Arrange
        await dataSource.save(makeEntity(id: 'to-delete'));
        await dataSource.save(makeEntity(id: 'to-keep'));

        // Act
        await dataSource.delete('to-delete');
        final results = await dataSource.getAll();

        // Assert
        expect(results.length, equals(1));
        expect(results.first.id, equals('to-keep'));
      });

      test('delete with nonexistent id does not affect other records', () async {
        // Arrange
        await dataSource.save(makeEntity(id: 'existing'));

        // Act
        await dataSource.delete('nonexistent');
        final results = await dataSource.getAll();

        // Assert
        expect(results.length, equals(1));
      });

      test('delete from empty store does not throw', () async {
        // Act & Assert
        expect(() => dataSource.delete('any-id'), returnsNormally);
      });
    });

    group('persistence across calls', () {
      test('data persists across multiple getAll calls', () async {
        // Arrange
        await dataSource.save(makeEntity(id: 'persist-1'));

        // Act
        final first = await dataSource.getAll();
        final second = await dataSource.getAll();

        // Assert
        expect(first.length, equals(1));
        expect(second.length, equals(1));
        expect(first.first.id, equals(second.first.id));
      });
    });
  });
}
