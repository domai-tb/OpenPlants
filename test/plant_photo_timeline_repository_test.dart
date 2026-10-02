import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:openplants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:openplants/pages/plant_collection/plant_collection_repository.dart';
import 'package:openplants/pages/plant_photo_timeline/plant_photo_timeline_datasource.dart';
import 'package:openplants/pages/plant_photo_timeline/plant_photo_timeline_item_entity.dart';
import 'package:openplants/pages/plant_photo_timeline/plant_photo_timeline_repository.dart';

void main() {
  test('commits photo removal before deleting the image file', () async {
    final events = <String>[];
    final plantCollection = _MemoryPlantCollection(events);
    final photoDataSource = _RecordingPhotoDataSource(events)..failDeletes = true;
    final repository = PlantPhotoTimelineRepository(
      dataSource: photoDataSource,
      plantCollection: plantCollection,
    );

    await repository.deletePhoto('plant-1', 'photo-1');

    expect(events, ['save-plant', 'delete-photo-file']);
    expect(plantCollection.plant.photos, isEmpty);
  });

  test('reports file cleanup failure after clearing metadata so plant deletion can retry', () async {
    final events = <String>[];
    final plantCollection = _MemoryPlantCollection(events);
    final photoDataSource = _RecordingPhotoDataSource(events)..failDeleteAll = true;
    final repository = PlantPhotoTimelineRepository(
      dataSource: photoDataSource,
      plantCollection: plantCollection,
    );

    await expectLater(
      () => repository.deleteAllPhotos('plant-1'),
      throwsA(isA<StateError>()),
    );

    expect(plantCollection.plant.photos, isEmpty);
    expect(events, ['save-plant', 'delete-all-photo-files']);
  });

  test('keeps the image when photo metadata cannot be saved', () async {
    final events = <String>[];
    final plantCollection = _MemoryPlantCollection(events)..failSave = true;
    final photoDataSource = _RecordingPhotoDataSource(events);
    final repository = PlantPhotoTimelineRepository(
      dataSource: photoDataSource,
      plantCollection: plantCollection,
    );

    await expectLater(
      () => repository.deletePhoto('plant-1', 'photo-1'),
      throwsA(isA<StateError>()),
    );

    expect(events, ['save-plant']);
    expect(plantCollection.plant.photos, hasLength(1));
  });
}

class _MemoryPlantCollection extends PlantCollectionRepository {
  final List<String> events;
  late PlantEntity plant = PlantEntity(
    id: 'plant-1',
    name: 'Plant',
    photos: [PlantPhoto(id: 'photo-1', date: DateTime(2026), filePath: '/photo.jpg')],
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
  );
  bool failSave = false;

  _MemoryPlantCollection(this.events) : super(dataSource: PlantCollectionDataSource());

  @override
  Future<List<PlantEntity>> loadPlants() async => [plant];

  @override
  Future<void> replacePlant(PlantEntity updatedPlant) async {
    events.add('save-plant');
    if (failSave) throw StateError('Persistence failed');
    plant = updatedPlant;
  }
}

class _RecordingPhotoDataSource extends PlantPhotoTimelineDataSource {
  final List<String> events;
  bool failDeletes = false;
  bool failDeleteAll = false;

  _RecordingPhotoDataSource(this.events);

  @override
  Future<void> deletePhotoFile(String filePath) async {
    events.add('delete-photo-file');
    if (failDeletes) throw StateError('Photo cleanup failed');
  }

  @override
  Future<void> deleteAllPhotoFiles(String plantId) async {
    events.add('delete-all-photo-files');
    if (failDeleteAll) throw StateError('Photo cleanup failed');
  }

  @override
  Future<String> savePhotoFile(File image, String plantId) async => '/new/photo.jpg';
}
