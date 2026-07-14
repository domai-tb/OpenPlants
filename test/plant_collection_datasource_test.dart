import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/exceptions.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';

void main() {
  late PlantCollectionDataSource dataSource;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    dataSource = PlantCollectionDataSource(prefs: prefs);
  });

  PlantEntity makePlant({
    String id = 'test-plant',
    String name = 'Test Plant',
  }) {
    return PlantEntity(
      id: id,
      name: name,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  }

  group('PlantCollectionDataSource', () {
    group('loadPlants', () {
      test('returns empty list when key does not exist', () async {
        final plants = await dataSource.loadPlants();
        expect(plants, isEmpty);
      });

      test('loads valid plants', () async {
        final plant = makePlant(id: 'valid-1');
        await dataSource.savePlants([plant]);

        final plants = await dataSource.loadPlants();
        expect(plants, hasLength(1));
        expect(plants.first.id, equals('valid-1'));
      });

      test('throws CollectionDecodeFailure for malformed JSON', () async {
        await prefs.setString('plant_collection_v1', 'not valid json{{');

        expect(
          () => dataSource.loadPlants(),
          throwsA(isA<CollectionDecodeFailure>()),
        );
      });

      test('throws CollectionShapeFailure when JSON is not a list', () async {
        await prefs.setString(
          'plant_collection_v1',
          jsonEncode({'not': 'a list'}),
        );

        expect(
          () => dataSource.loadPlants(),
          throwsA(isA<CollectionShapeFailure>()),
        );
      });

      test('throws RecordDecodeFailure for invalid record', () async {
        final records = [
          makePlant(id: 'valid').toJson(),
          {'id': 'invalid'}, // Missing required fields
        ];
        await prefs.setString('plant_collection_v1', jsonEncode(records));

        expect(
          () => dataSource.loadPlants(),
          throwsA(isA<RecordDecodeFailure>()),
        );
      });
    });

    group('corrupt data protection', () {
      test('savePlants does not replace corrupt data', () async {
        const corruptValue = 'not valid json';
        await prefs.setString('plant_collection_v1', corruptValue);

        // First load detects the corruption
        expect(
          () => dataSource.loadPlants(),
          throwsA(isA<CollectionDecodeFailure>()),
        );

        // Subsequent save should fail because the codec is blocked
        expect(
          () => dataSource.savePlants([makePlant()]),
          throwsA(isA<BlockedAfterDecodeFailure>()),
        );

        // Raw value should be preserved
        expect(prefs.getString('plant_collection_v1'), equals(corruptValue));
      });

      test('addPlant does not replace corrupt data', () async {
        const corruptValue = '{"corrupted": "data"}';
        await prefs.setString('plant_collection_v1', corruptValue);

        expect(
          () => dataSource.addPlant(makePlant()),
          throwsA(isA<BlockedAfterDecodeFailure>()),
        );

        expect(prefs.getString('plant_collection_v1'), equals(corruptValue));
      });

      test('updatePlant does not replace corrupt data', () async {
        const corruptValue = '["invalid", "data"]';
        await prefs.setString('plant_collection_v1', corruptValue);

        expect(
          () => dataSource.updatePlant(makePlant()),
          throwsA(isA<BlockedAfterDecodeFailure>()),
        );

        expect(prefs.getString('plant_collection_v1'), equals(corruptValue));
      });

      test('deletePlant does not replace corrupt data', () async {
        const corruptValue = 'not valid json';
        await prefs.setString('plant_collection_v1', corruptValue);

        expect(
          () => dataSource.deletePlant('some-id'),
          throwsA(isA<BlockedAfterDecodeFailure>()),
        );

        expect(prefs.getString('plant_collection_v1'), equals(corruptValue));
      });

      test('isBlocked returns true after corruption detection', () async {
        await prefs.setString('plant_collection_v1', 'corrupted');

        expect(
          () => dataSource.loadPlants(),
          throwsA(isA<CollectionDecodeFailure>()),
        );

        expect(await dataSource.isBlocked, isTrue);
      });

      test('isBlocked returns false for valid data', () async {
        await dataSource.savePlants([makePlant()]);
        final plants = await dataSource.loadPlants();

        expect(plants, hasLength(1));
        expect(await dataSource.isBlocked, isFalse);
      });
    });

    group('valid operations', () {
      test('addPlant appends to collection', () async {
        await dataSource.addPlant(makePlant(id: 'plant-1'));
        await dataSource.addPlant(makePlant(id: 'plant-2'));

        final plants = await dataSource.loadPlants();
        expect(plants, hasLength(2));
      });

      test('updatePlant replaces existing plant', () async {
        await dataSource.addPlant(makePlant(id: 'plant-1', name: 'Original'));
        await dataSource.updatePlant(makePlant(id: 'plant-1', name: 'Updated'));

        final plants = await dataSource.loadPlants();
        expect(plants, hasLength(1));
        expect(plants.first.name, equals('Updated'));
      });

      test('deletePlant removes plant', () async {
        await dataSource.addPlant(makePlant(id: 'plant-1'));
        await dataSource.addPlant(makePlant(id: 'plant-2'));
        await dataSource.deletePlant('plant-1');

        final plants = await dataSource.loadPlants();
        expect(plants, hasLength(1));
        expect(plants.first.id, equals('plant-2'));
      });

      test('operations work after successful load', () async {
        // First load should succeed (empty collection)
        await dataSource.loadPlants();

        // Operations should work after successful load
        await dataSource.addPlant(makePlant());
        final plants = await dataSource.loadPlants();
        expect(plants, hasLength(1));
      });
    });
  });
}
