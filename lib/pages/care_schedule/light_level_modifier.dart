import 'package:open_plant/pages/care_schedule/care_task_type.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';

/// Applies plant-level light assessment modifiers to watering and misting intervals.
///
/// When a plant has a user-set light level, it takes precedence over the room's
/// sunlight attribute for watering and misting modifiers.
class LightLevelModifier {
  /// Returns the light-level modifier for a task type.
  ///
  /// Only applies to watering and misting. Returns 1.0 for other types.
  /// If [lightLevel] is null, returns 1.0 (no modifier — falls back to room behavior).
  static double compute({
    required BuiltInTaskType taskType,
    LightLevel? lightLevel,
  }) {
    if (lightLevel == null) return 1;
    if (taskType != BuiltInTaskType.watering) {
      return 1;
    }

    return switch (lightLevel) {
      LightLevel.low => 1.3,
      LightLevel.medium => 1,
      LightLevel.brightIndirect => 0.85,
      LightLevel.direct => 0.7,
    };
  }
}
