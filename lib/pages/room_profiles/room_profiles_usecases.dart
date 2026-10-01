import 'package:openplants/pages/plant_collection/plant_collection_usecases.dart';
import 'package:openplants/pages/room_profiles/room_profiles_entity.dart';
import 'package:openplants/pages/room_profiles/room_profiles_repository.dart';

/// Business logic for room profiles management.
class RoomProfilesUsecases {
  final RoomProfilesRepository repository;
  const RoomProfilesUsecases({required this.repository});

  /// Load all rooms.
  Future<List<RoomEntity>> getAll() => repository.loadRooms();

  /// Get a room by ID.
  Future<RoomEntity?> getById(String id) => repository.getById(id);

  /// Create a new room with unique name enforcement.
  Future<RoomEntity> create({
    required String name,
    RoomLightLevel lightLevel = RoomLightLevel.medium,
    RoomHumidityLevel humidityLevel = RoomHumidityLevel.medium,
    String? notes,
  }) {
    return repository.createRoom(
      name: name,
      lightLevel: lightLevel,
      humidityLevel: humidityLevel,
      notes: notes,
    );
  }

  /// Update an existing room.
  Future<RoomEntity> update(RoomEntity room) => repository.updateRoom(room);

  /// Delete a room by ID.
  Future<RoomEntity> delete(String id) => repository.deleteRoom(id);

  /// Delete a room after clearing its plant assignments in one collection write.
  ///
  /// If deleting the room fails, the previous assignments are restored. A
  /// [RoomDeletionCompensationFailure] indicates that restoration also failed.
  Future<RoomEntity> deleteAndUnassignPlants(
    String id, {
    required PlantCollectionUsecases plantCollection,
  }) async {
    final plants = await plantCollection.loadPlants();
    final affectedPlantIds = plants.where((plant) => plant.roomId == id).map((plant) => plant.id).toSet();
    if (affectedPlantIds.isEmpty) return delete(id);

    final clearedPlants = plants
        .map(
          (plant) => affectedPlantIds.contains(plant.id)
              ? plant.copyWith(clearRoomId: true, updatedAt: DateTime.now())
              : plant,
        )
        .toList(growable: false);
    await plantCollection.replaceAllPlants(clearedPlants);

    try {
      return await delete(id);
    } catch (deletionError, deletionStackTrace) {
      try {
        final currentPlants = await plantCollection.loadPlants();
        final restoredPlants = currentPlants
            .map(
              (plant) =>
                  affectedPlantIds.contains(plant.id) ? plant.copyWith(roomId: id, updatedAt: DateTime.now()) : plant,
            )
            .toList(growable: false);
        await plantCollection.replaceAllPlants(restoredPlants);
      } catch (compensationError) {
        throw RoomDeletionCompensationFailure(
          roomId: id,
          deletionError: deletionError,
          compensationError: compensationError,
        );
      }
      Error.throwWithStackTrace(deletionError, deletionStackTrace);
    }
  }
}

/// Indicates that deleting a room and restoring its plant assignments failed.
class RoomDeletionCompensationFailure implements Exception {
  final String roomId;
  final Object deletionError;
  final Object compensationError;

  const RoomDeletionCompensationFailure({
    required this.roomId,
    required this.deletionError,
    required this.compensationError,
  });

  @override
  String toString() =>
      'Failed to delete room $roomId and restore its plant assignments: $deletionError; $compensationError';
}
