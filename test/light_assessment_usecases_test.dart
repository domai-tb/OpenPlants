import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:open_plants/pages/light_assessment/light_assessment_datasource.dart';
import 'package:open_plants/pages/light_assessment/light_assessment_repository.dart';
import 'package:open_plants/pages/light_assessment/light_assessment_usecases.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plants/pages/plant_photo_timeline/plant_photo_timeline_item_entity.dart';

/// In-memory mock datasource for testing.
class MockLightAssessmentDataSource implements LightAssessmentDataSource {
  final Map<String, LightLevel?> _store = {};

  @override
  Future<LightLevel?> loadLightLevel(String plantId) async {
    return _store[plantId];
  }

  @override
  Future<void> saveLightLevel(String plantId, LightLevel level) async {
    _store[plantId] = level;
  }

  @override
  Future<void> clearLightLevel(String plantId) async {
    _store[plantId] = null;
  }
}

/// In-memory mock photo store for testing.
class MockPhotoStore {
  final Map<String, List<PlantPhoto>> _photos = {};

  Future<PlantPhoto> addPhoto(String plantId, File image, {DateTime? date, String? caption}) async {
    final photo = PlantPhoto(
      id: 'photo-${DateTime.now().millisecondsSinceEpoch}',
      date: date ?? DateTime.now(),
      filePath: image.path,
      caption: caption,
    );
    _photos.putIfAbsent(plantId, () => []).insert(0, photo);
    return photo;
  }

  Future<List<PlantPhoto>> getTimeline(String plantId) async {
    return _photos[plantId] ?? [];
  }
}

void main() {
  late MockLightAssessmentDataSource mockDataSource;
  late LightAssessmentRepository repository;
  late MockPhotoStore mockPhotoStore;
  late LightAssessmentUseCases usecases;

  setUp(() {
    mockDataSource = MockLightAssessmentDataSource();
    repository = LightAssessmentRepository(dataSource: mockDataSource);
    mockPhotoStore = MockPhotoStore();
    usecases = LightAssessmentUseCases(
      repository: repository,
      getLatestPhoto: (plantId) async {
        final timeline = await mockPhotoStore.getTimeline(plantId);
        return timeline.isNotEmpty ? timeline.first : null;
      },
      addPhoto: (plantId, image) => mockPhotoStore.addPhoto(plantId, image),
    );
  });

  group('LightAssessmentUseCases', () {
    test('getLightLevel returns null when not set', () async {
      final level = await usecases.getLightLevel('plant-1');
      expect(level, isNull);
    });

    test('setLightLevel persists the value', () async {
      await usecases.setLightLevel('plant-1', LightLevel.brightIndirect);
      final level = await usecases.getLightLevel('plant-1');
      expect(level, LightLevel.brightIndirect);
    });

    test('setLightLevel overwrites previous value', () async {
      await usecases.setLightLevel('plant-1', LightLevel.low);
      await usecases.setLightLevel('plant-1', LightLevel.direct);
      final level = await usecases.getLightLevel('plant-1');
      expect(level, LightLevel.direct);
    });

    test('clearLightLevel resets to null', () async {
      await usecases.setLightLevel('plant-1', LightLevel.medium);
      await usecases.clearLightLevel('plant-1');
      final level = await usecases.getLightLevel('plant-1');
      expect(level, isNull);
    });

    test('light levels are independent per plant', () async {
      await usecases.setLightLevel('plant-1', LightLevel.low);
      await usecases.setLightLevel('plant-2', LightLevel.direct);
      expect(await usecases.getLightLevel('plant-1'), LightLevel.low);
      expect(await usecases.getLightLevel('plant-2'), LightLevel.direct);
    });

    test('all light level enum values can be set and retrieved', () async {
      for (final level in LightLevel.values) {
        await usecases.setLightLevel('plant-test', level);
        final retrieved = await usecases.getLightLevel('plant-test');
        expect(retrieved, level);
      }
    });
  });

  group('LightLevel enum', () {
    test('toJson returns the enum name', () {
      expect(LightLevel.low.toJson(), 'low');
      expect(LightLevel.medium.toJson(), 'medium');
      expect(LightLevel.brightIndirect.toJson(), 'brightIndirect');
      expect(LightLevel.direct.toJson(), 'direct');
    });

    test('label returns human-readable string', () {
      expect(LightLevel.low.label, 'Low');
      expect(LightLevel.medium.label, 'Medium');
      expect(LightLevel.brightIndirect.label, 'Bright Indirect');
      expect(LightLevel.direct.label, 'Direct');
    });
  });

  group('PlantEntity lightLevel serialization', () {
    test('toJson includes lightLevel when set', () {
      final plant = PlantEntity(
        id: '1',
        name: 'Test Plant',
        lightLevel: LightLevel.brightIndirect,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final json = plant.toJson();
      expect(json['lightLevel'], 'brightIndirect');
    });

    test('toJson includes null lightLevel', () {
      final plant = PlantEntity(
        id: '1',
        name: 'Test Plant',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final json = plant.toJson();
      expect(json['lightLevel'], isNull);
    });

    test('fromJson deserializes lightLevel', () {
      final json = {
        'id': '1',
        'name': 'Test Plant',
        'careStatus': 'happy',
        'lightLevel': 'direct',
        'photos': <dynamic>[],
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-01-01T00:00:00.000',
      };
      final plant = PlantEntity.fromJson(json);
      expect(plant.lightLevel, LightLevel.direct);
    });

    test('fromJson deserializes null lightLevel', () {
      final json = {
        'id': '1',
        'name': 'Test Plant',
        'careStatus': 'happy',
        'photos': <dynamic>[],
        'createdAt': '2025-01-01T00:00:00.000',
        'updatedAt': '2025-01-01T00:00:00.000',
      };
      final plant = PlantEntity.fromJson(json);
      expect(plant.lightLevel, isNull);
    });

    test('copyWith preserves lightLevel when not specified', () {
      final plant = PlantEntity(
        id: '1',
        name: 'Test Plant',
        lightLevel: LightLevel.medium,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final copy = plant.copyWith(name: 'Updated');
      expect(copy.lightLevel, LightLevel.medium);
    });

    test('copyWith can change lightLevel', () {
      final plant = PlantEntity(
        id: '1',
        name: 'Test Plant',
        lightLevel: LightLevel.medium,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final copy = plant.copyWith(lightLevel: LightLevel.direct);
      expect(copy.lightLevel, LightLevel.direct);
    });

    test('copyWith can clear lightLevel', () {
      final plant = PlantEntity(
        id: '1',
        name: 'Test Plant',
        lightLevel: LightLevel.medium,
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );
      final copy = plant.copyWith(clearLightLevel: true);
      expect(copy.lightLevel, isNull);
    });
  });
}
