import 'package:open_plants/pages/room_profiles/room_profiles_entity.dart';
import 'package:open_plants/pages/room_profiles/room_profiles_repository.dart';

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
}
