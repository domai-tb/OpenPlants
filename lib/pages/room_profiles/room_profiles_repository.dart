import 'package:uuid/uuid.dart';

import 'package:open_plants/pages/room_profiles/room_profiles_datasource.dart';
import 'package:open_plants/pages/room_profiles/room_profiles_entity.dart';

/// Repository for room profiles CRUD operations.
///
/// Maps raw JSON to RoomEntity and enforces unique names.
class RoomProfilesRepository {
  final RoomProfilesDatasource dataSource;
  final Uuid _uuid;

  RoomProfilesRepository({required this.dataSource}) : _uuid = const Uuid();

  /// Load all rooms.
  Future<List<RoomEntity>> loadRooms() => dataSource.loadRooms();

  /// Create a new room. Throws if name already exists.
  Future<RoomEntity> createRoom({
    required String name,
    RoomLightLevel lightLevel = RoomLightLevel.medium,
    RoomHumidityLevel humidityLevel = RoomHumidityLevel.medium,
    String? notes,
  }) async {
    final rooms = await loadRooms();
    final duplicate = rooms.any(
      (r) => r.name.toLowerCase() == name.toLowerCase(),
    );
    if (duplicate) {
      throw RoomNameDuplicateException(name);
    }

    final now = DateTime.now();
    final room = RoomEntity(
      id: _uuid.v4(),
      name: name,
      lightLevel: lightLevel,
      humidityLevel: humidityLevel,
      notes: notes,
      createdAt: now,
      updatedAt: now,
    );

    rooms.add(room);
    await dataSource.saveRooms(rooms);
    return room;
  }

  /// Update an existing room. Throws if new name conflicts with another room.
  Future<RoomEntity> updateRoom(RoomEntity room) async {
    final rooms = await loadRooms();
    final duplicate = rooms.any(
      (r) => r.id != room.id && r.name.toLowerCase() == room.name.toLowerCase(),
    );
    if (duplicate) {
      throw RoomNameDuplicateException(room.name);
    }

    final updated = room.copyWith(updatedAt: DateTime.now());
    final index = rooms.indexWhere((r) => r.id == room.id);
    if (index == -1) {
      throw RoomNotFoundException(room.id);
    }

    rooms[index] = updated;
    await dataSource.saveRooms(rooms);
    return updated;
  }

  /// Delete a room by ID. Returns the deleted room.
  Future<RoomEntity> deleteRoom(String id) async {
    final rooms = await loadRooms();
    final index = rooms.indexWhere((r) => r.id == id);
    if (index == -1) {
      throw RoomNotFoundException(id);
    }

    final deleted = rooms.removeAt(index);
    await dataSource.saveRooms(rooms);
    return deleted;
  }

  /// Get a room by ID.
  Future<RoomEntity?> getById(String id) async {
    final rooms = await loadRooms();
    try {
      return rooms.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Exception thrown when a room name already exists.
class RoomNameDuplicateException implements Exception {
  final String name;
  const RoomNameDuplicateException(this.name);

  @override
  String toString() => 'A room with this name already exists: $name';
}

/// Exception thrown when a room is not found.
class RoomNotFoundException implements Exception {
  final String id;
  const RoomNotFoundException(this.id);

  @override
  String toString() => 'Room not found: $id';
}
