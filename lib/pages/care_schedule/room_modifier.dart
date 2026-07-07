import 'package:open_plant/pages/care_schedule/care_task_type.dart';
import 'package:open_plant/pages/care_schedule/room_config.dart';

/// Applies room-context modifiers to watering and misting intervals.
class RoomModifier {
  /// Returns the combined room modifier for a task type.
  ///
  /// Only applies to watering and misting. Returns 1.0 for other types.
  static double compute({
    required BuiltInTaskType taskType,
    required RoomConfig? room,
  }) {
    if (room == null) return 1;
    if (taskType != BuiltInTaskType.watering && taskType != BuiltInTaskType.misting) {
      return 1;
    }

    double modifier = 1;

    // Sunlight modifier (only affects watering)
    if (taskType == BuiltInTaskType.watering) {
      switch (room.sunlightLevel) {
        case SunlightLevel.low:
          modifier *= 1.3; // Less frequent — less evaporation
          break;
        case SunlightLevel.medium:
          modifier *= 1; // Baseline
          break;
        case SunlightLevel.high:
          modifier *= 0.8; // More frequent — more evaporation
          break;
        case SunlightLevel.fullSun:
          modifier *= 0.7; // Most frequent — maximum evaporation
          break;
      }
    }

    // Humidity modifier (affects both watering and misting)
    switch (room.humidityLevel) {
      case HumidityLevel.low:
        modifier *= 0.8; // More frequent — dry air
        break;
      case HumidityLevel.medium:
        modifier *= 1; // Baseline
        break;
      case HumidityLevel.high:
        modifier *= 1.3; // Less frequent — moist air
        break;
    }

    return modifier;
  }
}
