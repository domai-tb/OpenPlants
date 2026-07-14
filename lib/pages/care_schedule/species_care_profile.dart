import 'package:open_plants/pages/care_schedule/care_task_type.dart';

/// Default care intervals and seasonal modifiers for a plant species.
class SpeciesCareProfile {
  final String id;
  final String name;

  /// Default interval in days for each built-in task type. Key is task type name.
  /// Null or 0 means the task is not applicable for this species.
  final Map<String, int> defaultIntervals;

  /// Monthly modifier tables per task type. Key is task type name.
  /// Each entry is a 12-element list (index 0 = January) of multipliers.
  /// 1 = baseline, <1 = more frequent, >1 = less frequent.
  final Map<String, List<double>> seasonalModifiers;

  const SpeciesCareProfile({
    required this.id,
    required this.name,
    required this.defaultIntervals,
    this.seasonalModifiers = const {},
  });

  /// Get the default interval for a task type, or null if not applicable.
  int? getDefaultInterval(BuiltInTaskType taskType) {
    final interval = defaultIntervals[taskType.name];
    if (interval == null || interval <= 0) return null;
    return interval;
  }

  /// Get the seasonal multiplier for a task type in the given month (1-12).
  /// Returns 1 if no modifier is defined.
  double getSeasonalModifier(BuiltInTaskType taskType, int month) {
    final table = seasonalModifiers[taskType.name];
    if (table == null || table.length != 12) return 1;
    return table[month - 1];
  }
}
