import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:open_plants/pages/room_profiles/room_profiles_entity.dart';

/// Data source for room profiles persistence.
///
/// Stores rooms as a JSON list in shared_preferences.
class RoomProfilesDatasource {
  static const String _prefsKey = 'room_profiles_v1';

  /// Load all rooms from shared_preferences.
  Future<List<RoomEntity>> loadRooms() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);

    if (raw == null || raw.trim().isEmpty) {
      return [];
    }

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((item) => RoomEntity.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Save room list to shared_preferences.
  Future<void> saveRooms(List<RoomEntity> rooms) async {
    final prefs = await SharedPreferences.getInstance();
    final json = rooms.map((r) => r.toJson()).toList();
    await prefs.setString(_prefsKey, jsonEncode(json));
  }
}
