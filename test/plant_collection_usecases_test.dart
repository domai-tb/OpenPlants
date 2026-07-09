import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:open_plant/pages/plant_collection/plant_collection_datasource.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_repository.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';

/// In-memory mock datasource for testing.
class _MockPlantCollectionDataSource extends PlantCollectionDataSource {
  final List<PlantEntity> _plants = [];

  @override
  Future<List<PlantEntity>> loadPlants() async => List.unmodifiable(_plants);

  @override
  Future<void> savePlants(List<PlantEntity> plants) async {
    _plants
      ..clear()
      ..addAll(plants);
  }

  @override
  Future<String> savePhoto(File sourceFile, String plantId) async => '/mock/photos/$plantId.jpg';

  @override
  Future<void> deletePhoto(String photoPath) async {}
}

PlantEntity _makePlant({
  String id = 'test-1',
  CareStatus careStatus = CareStatus.happy,
  DateTime? lastWateredAt,
  DateTime? lastFertilizedAt,
}) {
  return PlantEntity(
    id: id,
    name: 'Test Plant',
    careStatus: careStatus,
    lastWateredAt: lastWateredAt,
    lastFertilizedAt: lastFertilizedAt,
    createdAt: DateTime(2025),
    updatedAt: DateTime(2025),
  );
}

void main() {
  group('PlantEntity.effectiveCareStatus', () {
    test('returns needsWater for never-watered plant with happy stored status', () {
      final plant = _makePlant(
        lastFertilizedAt: DateTime(2025),
      );
      expect(plant.effectiveCareStatus, CareStatus.needsWater);
    });

    test('returns needsFertilizer for never-fertilized plant with happy stored status', () {
      final plant = _makePlant(
        lastWateredAt: DateTime(2025),
      );
      expect(plant.effectiveCareStatus, CareStatus.needsFertilizer);
    });

    test('returns stored needsWater when explicitly set (override wins)', () {
      final plant = _makePlant(
        careStatus: CareStatus.needsWater,
        lastWateredAt: DateTime(2025),
        lastFertilizedAt: DateTime(2025),
      );
      expect(plant.effectiveCareStatus, CareStatus.needsWater);
    });

    test('returns stored needsFertilizer when explicitly set (override wins)', () {
      final plant = _makePlant(
        careStatus: CareStatus.needsFertilizer,
        lastWateredAt: DateTime(2025),
        lastFertilizedAt: DateTime(2025),
      );
      expect(plant.effectiveCareStatus, CareStatus.needsFertilizer);
    });

    test('returns needsWater when both timestamps are null (water priority)', () {
      final plant = _makePlant(
        
      );
      expect(plant.effectiveCareStatus, CareStatus.needsWater);
    });

    test('returns happy when both timestamps are set and stored status is happy', () {
      final plant = _makePlant(
        lastWateredAt: DateTime(2025),
        lastFertilizedAt: DateTime(2025),
      );
      expect(plant.effectiveCareStatus, CareStatus.happy);
    });

    test('returns stored careStatus for needsAttention when timestamps are set', () {
      final plant = _makePlant(
        careStatus: CareStatus.needsAttention,
        lastWateredAt: DateTime(2025),
        lastFertilizedAt: DateTime(2025),
      );
      expect(plant.effectiveCareStatus, CareStatus.needsAttention);
    });
  });

  group('PlantCollectionUsecases.filterByCareStatus', () {
    late _MockPlantCollectionDataSource datasource;
    late PlantCollectionRepository repository;
    late PlantCollectionUsecases usecases;

    setUp(() {
      datasource = _MockPlantCollectionDataSource();
      repository = PlantCollectionRepository(dataSource: datasource);
      usecases = PlantCollectionUsecases(repository: repository);
    });

    test('returns all plants when status is null', () async {
      datasource._plants.add(_makePlant(id: '1'));
      datasource._plants.add(_makePlant(id: '2'));

      final result = await usecases.filterByCareStatus(null);
      expect(result.length, 2);
    });

    test('never-watered plant matches needsWater filter', () async {
      datasource._plants.add(_makePlant(
        id: 'never-watered',
        lastFertilizedAt: DateTime(2025),
      ),);
      datasource._plants.add(_makePlant(
        id: 'happy-plant',
        lastWateredAt: DateTime(2025),
        lastFertilizedAt: DateTime(2025),
      ),);

      final result = await usecases.filterByCareStatus(CareStatus.needsWater);
      expect(result.length, 1);
      expect(result.first.id, 'never-watered');
    });

    test('never-fertilized plant matches needsFertilizer filter', () async {
      datasource._plants.add(_makePlant(
        id: 'never-fertilized',
        lastWateredAt: DateTime(2025),
      ),);
      datasource._plants.add(_makePlant(
        id: 'happy-plant',
        lastWateredAt: DateTime(2025),
        lastFertilizedAt: DateTime(2025),
      ),);

      final result = await usecases.filterByCareStatus(CareStatus.needsFertilizer);
      expect(result.length, 1);
      expect(result.first.id, 'never-fertilized');
    });

    test('happy plant with both timestamps matches neither filter', () async {
      datasource._plants.add(_makePlant(
        id: 'happy-plant',
        lastWateredAt: DateTime(2025),
        lastFertilizedAt: DateTime(2025),
      ),);

      final waterResult = await usecases.filterByCareStatus(CareStatus.needsWater);
      final fertResult = await usecases.filterByCareStatus(CareStatus.needsFertilizer);

      expect(waterResult, isEmpty);
      expect(fertResult, isEmpty);
    });

    test('plant with explicit needsWater override matches needsWater filter', () async {
      datasource._plants.add(_makePlant(
        id: 'explicit-needs-water',
        careStatus: CareStatus.needsWater,
        lastWateredAt: DateTime(2025),
        lastFertilizedAt: DateTime(2025),
      ),);

      final result = await usecases.filterByCareStatus(CareStatus.needsWater);
      expect(result.length, 1);
      expect(result.first.id, 'explicit-needs-water');
    });

    test('plant with both timestamps null matches needsWater only', () async {
      datasource._plants.add(_makePlant(
        id: 'brand-new',
      ),);

      final waterResult = await usecases.filterByCareStatus(CareStatus.needsWater);
      final fertResult = await usecases.filterByCareStatus(CareStatus.needsFertilizer);

      expect(waterResult.length, 1);
      expect(waterResult.first.id, 'brand-new');
      expect(fertResult, isEmpty);
    });
  });
}
