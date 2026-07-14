import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:open_plants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_repository.dart';

@GenerateMocks([PlantCollectionDataSource])
import 'plant_collection_repository_test.mocks.dart';

void main() {
  late PlantCollectionRepository repository;
  late MockPlantCollectionDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockPlantCollectionDataSource();
    repository = PlantCollectionRepository(dataSource: mockDataSource);
  });

  group('updatePlant photo lifecycle', () {
    test('replaces photo: saves new before deleting old', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'My Plant',
        photoPath: '/old/photo.jpg',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      when(mockDataSource.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockDataSource.savePlants(any)).thenAnswer((_) async {});
      when(mockDataSource.savePhoto(any, any)).thenAnswer((_) async => '/new/photo.jpg');
      when(mockDataSource.deletePhoto(any)).thenAnswer((_) async {});

      final newPhotoFile = File('/tmp/new_photo.jpg');
      final updated = await repository.updatePlant(plant, photoFile: newPhotoFile);

      expect(updated.photoPath, '/new/photo.jpg');

      // Verify savePhoto was called before deletePhoto
      verify(mockDataSource.savePhoto(newPhotoFile, 'plant-1')).called(1);
      verify(mockDataSource.deletePhoto('/old/photo.jpg')).called(1);
    });

    test('clears photo: deletes old file after persistence', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'My Plant',
        photoPath: '/old/photo.jpg',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      when(mockDataSource.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockDataSource.savePlants(any)).thenAnswer((_) async {});
      when(mockDataSource.deletePhoto(any)).thenAnswer((_) async {});

      final updated = await repository.updatePlant(
        plant.copyWith(clearPhoto: true),
      );

      expect(updated.photoPath, isNull);

      // Verify persistence happened before file deletion
      verify(mockDataSource.savePlants(any)).called(1);
      verify(mockDataSource.deletePhoto('/old/photo.jpg')).called(1);
    });

    test('persistence failure: retains old photo, removes staged replacement', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'My Plant',
        photoPath: '/old/photo.jpg',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      when(mockDataSource.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockDataSource.savePlants(any)).thenThrow(Exception('Storage failure'));
      when(mockDataSource.savePhoto(any, any)).thenAnswer((_) async => '/new/photo.jpg');
      when(mockDataSource.deletePhoto(any)).thenAnswer((_) async {});

      final newPhotoFile = File('/tmp/new_photo.jpg');

      // Should throw but not delete old photo
      await expectLater(
        () => repository.updatePlant(plant, photoFile: newPhotoFile),
        throwsException,
      );

      // Old photo should NOT be deleted
      verifyNever(mockDataSource.deletePhoto('/old/photo.jpg'));
      // New staged photo should be cleaned up
      verify(mockDataSource.deletePhoto('/new/photo.jpg')).called(1);
    });

    test('persistence failure on clear: retains old photo', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'My Plant',
        photoPath: '/old/photo.jpg',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      when(mockDataSource.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockDataSource.savePlants(any)).thenThrow(Exception('Storage failure'));
      when(mockDataSource.deletePhoto(any)).thenAnswer((_) async {});

      await expectLater(
        () => repository.updatePlant(
          plant.copyWith(clearPhoto: true),
        ),
        throwsException,
      );

      // Old photo should NOT be deleted
      verifyNever(mockDataSource.deletePhoto('/old/photo.jpg'));
    });

    test('no photo change: does not touch files', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'My Plant',
        photoPath: '/existing/photo.jpg',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      when(mockDataSource.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockDataSource.savePlants(any)).thenAnswer((_) async {});

      final updated = await repository.updatePlant(
        plant.copyWith(name: 'New Name'),
      );

      expect(updated.name, 'New Name');
      expect(updated.photoPath, '/existing/photo.jpg');

      // No file operations should occur
      verifyNever(mockDataSource.savePhoto(any, any));
      verifyNever(mockDataSource.deletePhoto(any));
    });
  });

  group('deletePlant photo cleanup', () {
    test('deletes photo file before removing record', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'My Plant',
        photoPath: '/photo.jpg',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      when(mockDataSource.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockDataSource.savePlants(any)).thenAnswer((_) async {});
      when(mockDataSource.deletePhoto(any)).thenAnswer((_) async {});

      await repository.deletePlant('plant-1');

      verify(mockDataSource.deletePhoto('/photo.jpg')).called(1);
      verify(mockDataSource.savePlants(any)).called(1);
    });

    test('deleting plant without photo succeeds', () async {
      final plant = PlantEntity(
        id: 'plant-1',
        name: 'My Plant',
        createdAt: DateTime(2025),
        updatedAt: DateTime(2025),
      );

      when(mockDataSource.loadPlants()).thenAnswer((_) async => [plant]);
      when(mockDataSource.savePlants(any)).thenAnswer((_) async {});

      await repository.deletePlant('plant-1');

      verifyNever(mockDataSource.deletePhoto(any));
      verify(mockDataSource.savePlants(any)).called(1);
    });
  });
}
