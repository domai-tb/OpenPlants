import 'package:shared_preferences/shared_preferences.dart';

import 'package:openplants/core/local_collection_codec.dart';
import 'package:openplants/pages/room_profiles/room_profiles_entity.dart';

/// Data source for room profiles persistence.
class RoomProfilesDatasource {
  static const String _prefsKey = 'room_profiles_v1';

  final SharedPreferences? _prefsOverride;
  LocalCollectionCodec<RoomEntity>? _codec;

  RoomProfilesDatasource({SharedPreferences? prefs}) : _prefsOverride = prefs;

  Future<LocalCollectionCodec<RoomEntity>> _getCodec() async {
    if (_codec == null) {
      final prefs = _prefsOverride ?? await SharedPreferences.getInstance();
      _codec = LocalCollectionCodec<RoomEntity>(
        prefs: prefs,
        key: _prefsKey,
        fromJson: RoomEntity.fromJson,
        toJson: (room) => room.toJson(),
        keyExtractor: (room) => room.id,
      );
    }
    return _codec!;
  }

  /// Loads rooms, throwing when stored JSON or any room record is malformed.
  Future<List<RoomEntity>> loadRooms() async {
    final result = await (await _getCodec()).load();
    if (result.isFailure) throw result.asFailure!;
    return result.asSuccess;
  }

  /// Saves rooms unless a previous load detected corrupt stored data.
  Future<void> saveRooms(List<RoomEntity> rooms) async {
    await (await _getCodec()).save(rooms);
  }
}
