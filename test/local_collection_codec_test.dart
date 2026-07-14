import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/core/exceptions.dart';
import 'package:open_plants/core/local_collection_codec.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';

void main() {
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
  });

  group('LocalCollectionCodec', () {
    group('missing key', () {
      test('returns empty collection when key does not exist', () async {
        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        final result = await codec.load();

        expect(result, isA<DecodedCollection<PlantEntity>>());
        expect(result.isSuccess, isTrue);
        expect(result.asSuccess, isEmpty);
      });
    });

    group('malformed JSON', () {
      test('reports classified failure for malformed JSON', () async {
        await prefs.setString('plant_collection_v1', 'not valid json{{');

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        final result = await codec.load();

        expect(result, isA<DecodedCollection<PlantEntity>>());
        expect(result.isFailure, isTrue);
        expect(result.asFailure, isA<CollectionDecodeFailure>());
        expect(result.asFailure!.collection, equals('plant_collection_v1'));
      });

      test('leaves raw stored value unchanged after decode failure', () async {
        const rawValue = 'not valid json{{';
        await prefs.setString('plant_collection_v1', rawValue);

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        await codec.load();

        expect(prefs.getString('plant_collection_v1'), equals(rawValue));
      });
    });

    group('wrong top-level shape', () {
      test('reports classified failure when JSON is not a list', () async {
        await prefs.setString(
          'plant_collection_v1',
          jsonEncode({'not': 'a list'}),
        );

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        final result = await codec.load();

        expect(result.isFailure, isTrue);
        expect(result.asFailure, isA<CollectionShapeFailure>());
        expect(result.asFailure!.collection, equals('plant_collection_v1'));
      });

      test('leaves raw stored value unchanged after shape failure', () async {
        final rawValue = jsonEncode({'not': 'a list'});
        await prefs.setString('plant_collection_v1', rawValue);

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        await codec.load();

        expect(prefs.getString('plant_collection_v1'), equals(rawValue));
      });
    });

    group('invalid record index', () {
      test('reports failing record index when one record cannot be decoded', () async {
        final records = [
          PlantEntity(
            id: 'valid-1',
            name: 'Valid Plant',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ).toJson(),
          {'id': 'invalid', 'name': null}, // Missing required field
          PlantEntity(
            id: 'valid-2',
            name: 'Another Plant',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ).toJson(),
        ];
        await prefs.setString('plant_collection_v1', jsonEncode(records));

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        final result = await codec.load();

        expect(result.isFailure, isTrue);
        expect(result.asFailure, isA<RecordDecodeFailure>());
        expect((result.asFailure! as RecordDecodeFailure).failingIndex, equals(1));
      });

      test('does not return partial collection as writable state', () async {
        final records = [
          PlantEntity(
            id: 'valid-1',
            name: 'Valid Plant',
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ).toJson(),
          {'id': 'invalid'}, // Invalid record
        ];
        await prefs.setString('plant_collection_v1', jsonEncode(records));

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        final result = await codec.load();

        expect(result.isFailure, isTrue);
        // The result should NOT contain a partial list of valid records
        expect(result.isSuccess, isFalse);
      });
    });

    group('supported migration', () {
      test('migrates and decodes records from a known older schema', () async {
        // Simulate an older schema format (e.g., missing 'photos' field)
        final oldSchemaRecords = [
          {
            'id': 'old-plant',
            'name': 'Old Schema Plant',
            'createdAt': '2026-01-01T00:00:00.000',
            'updatedAt': '2026-01-01T00:00:00.000',
          },
        ];
        await prefs.setString('plant_collection_v1', jsonEncode(oldSchemaRecords));

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        final result = await codec.load();

        // Should succeed with migrated records (photos defaults to empty list)
        expect(result.isSuccess, isTrue);
        expect(result.asSuccess, hasLength(1));
        expect(result.asSuccess.first.id, equals('old-plant'));
        expect(result.asSuccess.first.photos, isEmpty);
      });
    });

    group('raw-value preservation', () {
      test('preserves raw SharedPreferences content on decode failure', () async {
        const rawValue = '{"corrupted": "data"}';
        await prefs.setString('plant_collection_v1', rawValue);

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        await codec.load();

        // Raw value must be untouched
        expect(prefs.getString('plant_collection_v1'), equals(rawValue));
      });

      test('preserves raw content even when save is attempted after failure', () async {
        const rawValue = 'not valid json';
        await prefs.setString('plant_collection_v1', rawValue);

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        final result = await codec.load();
        expect(result.isFailure, isTrue);

        // Attempting to save after a failed load should be blocked
        expect(
          () => codec.save([]),
          throwsA(isA<BlockedAfterDecodeFailure>()),
        );

        // Raw value still preserved
        expect(prefs.getString('plant_collection_v1'), equals(rawValue));
      });
    });

    group('blocked mutation after failed load', () {
      test('blocks save after a failed load', () async {
        await prefs.setString('plant_collection_v1', 'corrupted');

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        final result = await codec.load();
        expect(result.isFailure, isTrue);

        // Save should throw because the collection is in a failed state
        expect(
          () => codec.save([
            PlantEntity(
              id: 'new',
              name: 'New Plant',
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ]),
          throwsA(isA<BlockedAfterDecodeFailure>()),
        );
      });

      test('blocks add after a failed load', () async {
        await prefs.setString('plant_collection_v1', 'corrupted');

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        await codec.load();

        expect(
          () => codec.add(
            PlantEntity(
              id: 'new',
              name: 'New Plant',
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ),
          throwsA(isA<BlockedAfterDecodeFailure>()),
        );
      });

      test('blocks update after a failed load', () async {
        await prefs.setString('plant_collection_v1', 'corrupted');

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        await codec.load();

        expect(
          () => codec.update(
            PlantEntity(
              id: 'existing',
              name: 'Updated',
              createdAt: DateTime(2026),
              updatedAt: DateTime(2026),
            ),
          ),
          throwsA(isA<BlockedAfterDecodeFailure>()),
        );
      });

      test('blocks delete after a failed load', () async {
        await prefs.setString('plant_collection_v1', 'corrupted');

        final codec = LocalCollectionCodec<PlantEntity>(
          prefs: prefs,
          key: 'plant_collection_v1',
          fromJson: PlantEntity.fromJson,
          toJson: (e) => e.toJson(),
          keyExtractor: (e) => e.id,
        );

        await codec.load();

        expect(
          () => codec.delete('some-id'),
          throwsA(isA<BlockedAfterDecodeFailure>()),
        );
      });
    });
  });
}
