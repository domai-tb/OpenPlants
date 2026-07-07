import 'package:open_plant/pages/care_schedule/care_task_type.dart';
import 'package:open_plant/pages/care_schedule/schedule_config.dart';

/// Applies pot-type modifiers to watering intervals.
class PotTypeModifier {
  /// Returns the pot-type multiplier for a task type.
  ///
  /// Only affects watering. Returns 1.0 for other types.
  static double compute({
    required BuiltInTaskType taskType,
    required PotType potType,
  }) {
    if (taskType != BuiltInTaskType.watering) return 1;

    switch (potType) {
      case PotType.terracotta:
        return 0.8; // Clay breathes — dries faster
      case PotType.plastic:
        return 1; // Baseline
      case PotType.selfWatering:
        return 1.5; // Reservoir — dries slower
    }
  }
}
