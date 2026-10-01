import 'package:flutter_test/flutter_test.dart';

import 'package:openplants/pages/plant_collection/plant_collection_datasource.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:openplants/pages/plant_collection/plant_collection_repository.dart';
import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/room_profiles/room_profiles_datasource.dart';
import 'package:openplants/pages/room_profiles/room_profiles_entity.dart';
import 'package:openplants/pages/room_profiles/room_profiles_repository.dart';
import 'package:openplants/pages/room_profiles/room_profiles_usecases.dart';

void main() {
  late RoomEntity room;
  late PlantEntity assignedPlant;

  setUp(() {
    room = RoomEntity(
      id: 'room-1',
      name: 'Living room',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    assignedPlant = PlantEntity(
      id: 'plant-1',
      name: 'Monstera',
      roomId: room.id,
      notes: 'Keep leaves clean',
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
  });

  test('deletes a room after clearing all assignments in one plant write', () async {
    final plants = _MemoryPlantDataSource([
      assignedPlant,
      assignedPlant.copyWith(id: 'plant-2', name: 'Fern'),
      assignedPlant.copyWith(id: 'plant-3', name: 'Ficus', roomId: 'room-2'),
    ]);
    final roomDataSource = _MemoryRoomDataSource([room]);
    final usecases = _roomUsecases(roomDataSource);

    await usecases.deleteAndUnassignPlants(
      room.id,
      plantCollection: _plantUsecases(plants),
    );

    expect(roomDataSource.rooms, isEmpty);
    expect(plants.writeCount, 1);
    expect(plants.plants.map((plant) => plant.roomId), [null, null, 'room-2']);
    expect(plants.plants.first.notes, assignedPlant.notes);
  });

  test('restores plant assignments when room deletion fails', () async {
    final plants = _MemoryPlantDataSource([assignedPlant, assignedPlant.copyWith(id: 'plant-2', name: 'Fern')]);
    final usecases = _roomUsecases(_MemoryRoomDataSource([room], failSave: true));

    await expectLater(
      usecases.deleteAndUnassignPlants(
        room.id,
        plantCollection: _plantUsecases(plants),
      ),
      throwsA(isA<StateError>()),
    );

    expect(plants.writeCount, 2);
    expect(plants.plants.map((plant) => plant.roomId), [room.id, room.id]);
  });

  test('reports when room deletion and assignment restoration both fail', () async {
    final plants = _MemoryPlantDataSource(
      [assignedPlant, assignedPlant.copyWith(id: 'plant-2', name: 'Fern')],
      failOnWrites: {2},
    );
    final usecases = _roomUsecases(_MemoryRoomDataSource([room], failSave: true));

    await expectLater(
      usecases.deleteAndUnassignPlants(
        room.id,
        plantCollection: _plantUsecases(plants),
      ),
      throwsA(isA<RoomDeletionCompensationFailure>()),
    );

    expect(plants.writeCount, 2);
    expect(plants.plants.map((plant) => plant.roomId), [null, null]);
  });
}

RoomProfilesUsecases _roomUsecases(RoomProfilesDatasource dataSource) =>
    RoomProfilesUsecases(repository: RoomProfilesRepository(dataSource: dataSource));

PlantCollectionUsecases _plantUsecases(PlantCollectionDataSource dataSource) =>
    PlantCollectionUsecases(repository: PlantCollectionRepository(dataSource: dataSource));

class _MemoryRoomDataSource extends RoomProfilesDatasource {
  final List<RoomEntity> rooms;
  final bool failSave;

  _MemoryRoomDataSource(this.rooms, {this.failSave = false});

  @override
  Future<List<RoomEntity>> loadRooms() async => List.of(rooms);

  @override
  Future<void> saveRooms(List<RoomEntity> value) async {
    if (failSave) throw StateError('Room write failed');
    rooms
      ..clear()
      ..addAll(value);
  }
}

class _MemoryPlantDataSource extends PlantCollectionDataSource {
  List<PlantEntity> plants;
  final Set<int> failOnWrites;
  int writeCount = 0;

  _MemoryPlantDataSource(this.plants, {this.failOnWrites = const {}});

  @override
  Future<List<PlantEntity>> loadPlants() async => List.of(plants);

  @override
  Future<void> savePlants(List<PlantEntity> value) async {
    writeCount++;
    if (failOnWrites.contains(writeCount)) throw StateError('Plant write failed');
    plants = List.of(value);
  }
}
