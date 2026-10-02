import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:openplants/pages/plant_collection/plant_data_cleanup.dart';
import 'package:openplants/pages/plant_collection/plant_deletion_coordinator.dart';

void main() {
  late SharedPreferences prefs;
  late _PartialCleanup cleanup;
  late _RecordingPlantCollection plantCollection;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    cleanup = _PartialCleanup();
    plantCollection = _RecordingPlantCollection();
  });

  test('removes the plant before partial cleanup and finishes it on startup retry', () async {
    final pendingDeletes = PendingPlantDeletionDataSource(prefs: prefs);
    final coordinator = PlantDeletionCoordinator(
      plantCollection: plantCollection,
      dataCleanup: cleanup,
      pendingDeletes: pendingDeletes,
    );

    await expectLater(() => coordinator.deletePlant('plant-1'), throwsA(isA<StateError>()));

    expect(cleanup.deletedStores, containsAll(['photos', 'journal']));
    expect(plantCollection.deletedPlantIds, ['plant-1']);
    expect(await pendingDeletes.loadPendingPlantIds(), ['plant-1']);

    cleanup.shouldFail = false;
    final restartedCoordinator = PlantDeletionCoordinator(
      plantCollection: plantCollection,
      dataCleanup: cleanup,
      pendingDeletes: PendingPlantDeletionDataSource(prefs: prefs),
    );

    await restartedCoordinator.retryPendingDeletions();

    expect(cleanup.attempts, 2);
    expect(plantCollection.deletedPlantIds, ['plant-1']);
    expect(await pendingDeletes.loadPendingPlantIds(), isEmpty);
  });

  test('does not delete plant data if the pending marker cannot be persisted', () async {
    final coordinator = PlantDeletionCoordinator(
      plantCollection: plantCollection,
      dataCleanup: cleanup,
      pendingDeletes: PendingPlantDeletionDataSource(prefs: _RejectingMarkerPreferences()),
    );

    await expectLater(() => coordinator.deletePlant('plant-1'), throwsA(isA<StateError>()));

    expect(cleanup.attempts, 0);
    expect(plantCollection.deletedPlantIds, isEmpty);
  });

  test('retains the main photo path so a failed file delete can be retried', () async {
    plantCollection.plant = PlantEntity(
      id: 'plant-1',
      name: 'Monstera',
      photoPath: '/photos/plant-1.jpg',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    plantCollection.failPhotoCleanup = true;
    final pendingDeletes = PendingPlantDeletionDataSource(prefs: prefs);
    final coordinator = PlantDeletionCoordinator(
      plantCollection: plantCollection,
      dataCleanup: cleanup,
      pendingDeletes: pendingDeletes,
    );

    await expectLater(() => coordinator.deletePlant('plant-1'), throwsA(isA<StateError>()));

    expect(await pendingDeletes.loadPhotoPath('plant-1'), '/photos/plant-1.jpg');
    expect(cleanup.attempts, 0);

    plantCollection.failPhotoCleanup = false;
    cleanup.shouldFail = false;
    await coordinator.retryPendingDeletions();

    expect(plantCollection.deletedPhotoPaths, ['/photos/plant-1.jpg', '/photos/plant-1.jpg']);
    expect(await pendingDeletes.loadPhotoPath('plant-1'), isNull);
    expect(await pendingDeletes.loadPendingPlantIds(), isEmpty);
    expect(cleanup.attempts, 1);
  });
}

class _PartialCleanup extends Fake implements PlantDataCleanup {
  final deletedStores = <String>{};
  int attempts = 0;
  bool shouldFail = true;

  @override
  Future<void> deleteAllForPlant(String plantId) async {
    attempts++;
    deletedStores.addAll(['photos', 'journal']);
    if (shouldFail) throw StateError('symptom storage unavailable');
    deletedStores.addAll(['symptoms', 'diagnosis', 'care', 'metrics']);
  }
}

class _RecordingPlantCollection extends Fake implements PlantCollectionUsecases {
  final deletedPlantIds = <String>[];
  final deletedPhotoPaths = <String>[];
  PlantEntity? plant;
  bool failPhotoCleanup = false;

  @override
  Future<PlantEntity?> getPlantById(String id) async => plant?.id == id ? plant : null;

  @override
  Future<void> deletePlant(String id) async {
    if (!deletedPlantIds.contains(id)) deletedPlantIds.add(id);
    if (plant?.id == id) plant = null;
  }

  @override
  Future<void> deletePhotoFile(String photoPath) async {
    deletedPhotoPaths.add(photoPath);
    if (failPhotoCleanup) throw StateError('Photo cleanup failed');
  }
}

class _RejectingMarkerPreferences implements SharedPreferences {
  @override
  String? getString(String key) => null;

  @override
  Future<bool> setBool(String key, bool value) async => false;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
