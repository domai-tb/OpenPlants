import 'package:open_plants/pages/care_schedule/care_task_type.dart';
import 'package:open_plants/pages/care_schedule/room_config.dart';
import 'package:open_plants/pages/room_profiles/room_profiles_entity.dart';

/// Applies room-context modifiers to watering and misting intervals.
class RoomModifier {
  /// Returns the combined room modifier for a task type.
  ///
  /// Only applies to watering and misting. Returns 1.0 for other types.
  /// Accepts either a RoomConfig (legacy) or a RoomEntity (new).
  static double compute({
    required BuiltInTaskType taskType,
    RoomConfig? room,
    RoomEntity? roomEntity,
  }) {
    // Use RoomEntity if provided, otherwise fall back to RoomConfig
    if (roomEntity != null) {
      return _computeFromEntity(taskType: taskType, room: roomEntity);
    }
    return _computeFromConfig(taskType: taskType, room: room);
  }

  /// Returns only the light modifier for a task type.
  ///
  /// Used when the plant has a user-set light level that overrides room sunlight.
  static double computeLightModifier({
    required BuiltInTaskType taskType,
    RoomConfig? room,
    RoomEntity? roomEntity,
  }) {
    if (taskType != BuiltInTaskType.watering && taskType != BuiltInTaskType.misting) {
      return 1;
    }

    if (roomEntity != null) {
      return _lightModifier(roomEntity.lightLevel);
    }
    if (room != null) {
      return _legacyLightModifier(room.sunlightLevel);
    }
    return 1;
  }

  /// Returns only the humidity modifier for a task type.
  ///
  /// Used when the plant has a user-set light level that overrides room sunlight.
  static double computeHumidityModifier({
    required BuiltInTaskType taskType,
    RoomConfig? room,
    RoomEntity? roomEntity,
  }) {
    if (taskType != BuiltInTaskType.watering && taskType != BuiltInTaskType.misting) {
      return 1;
    }

    if (roomEntity != null) {
      return _humidityModifier(roomEntity.humidityLevel);
    }
    if (room != null) {
      return _legacyHumidityModifier(room.humidityLevel);
    }
    return 1;
  }

  static double _computeFromEntity({
    required BuiltInTaskType taskType,
    required RoomEntity room,
  }) {
    if (taskType != BuiltInTaskType.watering && taskType != BuiltInTaskType.misting) {
      return 1;
    }

    final lightModifier = _lightModifier(room.lightLevel);
    final humidityModifier = _humidityModifier(room.humidityLevel);

    return _applyModifiers(taskType, lightModifier, humidityModifier);
  }

  static double _computeFromConfig({
    required BuiltInTaskType taskType,
    required RoomConfig? room,
  }) {
    if (room == null) return 1;
    if (taskType != BuiltInTaskType.watering && taskType != BuiltInTaskType.misting) {
      return 1;
    }

    final lightModifier = _legacyLightModifier(room.sunlightLevel);
    final humidityModifier = _legacyHumidityModifier(room.humidityLevel);

    return _applyModifiers(taskType, lightModifier, humidityModifier);
  }

  static double _applyModifiers(BuiltInTaskType taskType, double light, double humidity) {
    double modifier = 1;
    if (taskType == BuiltInTaskType.watering) {
      modifier *= light;
    }
    if (taskType == BuiltInTaskType.watering || taskType == BuiltInTaskType.misting) {
      modifier *= humidity;
    }
    return modifier;
  }

  // --- New RoomEntity modifiers ---

  static double _lightModifier(RoomLightLevel level) => switch (level) {
        RoomLightLevel.low => 1.3,
        RoomLightLevel.medium => 1.0,
        RoomLightLevel.bright => 0.85,
        RoomLightLevel.directSun => 0.7,
      };

  static double _humidityModifier(RoomHumidityLevel level) => switch (level) {
        RoomHumidityLevel.low => 0.7,
        RoomHumidityLevel.medium => 1.0,
        RoomHumidityLevel.high => 1.3,
      };

  // --- Legacy RoomConfig modifiers ---

  static double _legacyLightModifier(SunlightLevel level) => switch (level) {
        SunlightLevel.low => 1.3,
        SunlightLevel.medium => 1.0,
        SunlightLevel.high => 0.8,
        SunlightLevel.fullSun => 0.7,
      };

  static double _legacyHumidityModifier(HumidityLevel level) => switch (level) {
        HumidityLevel.low => 0.8,
        HumidityLevel.medium => 1.0,
        HumidityLevel.high => 1.3,
      };
}
