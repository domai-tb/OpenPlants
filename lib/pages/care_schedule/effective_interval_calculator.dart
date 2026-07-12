import 'package:open_plants/pages/care_schedule/care_task_type.dart';
import 'package:open_plants/pages/care_schedule/schedule_config.dart';
import 'package:open_plants/pages/care_schedule/species_care_profile.dart';

/// Merges species defaults with user overrides and applies seasonal modifiers.
class EffectiveIntervalCalculator {
  /// Compute the effective interval for a task type.
  ///
  /// Priority: user override → species default → null (skip).
  /// Then applies the seasonal monthly multiplier.
  static int? compute({
    required CareTaskType taskType,
    required ScheduleConfig config,
    required SpeciesCareProfile profile,
    required DateTime today,
  }) {
    // Only built-in types have species defaults
    if (!taskType.isBuiltIn) {
      // Custom types: use the override if set, otherwise skip
      final override = config.intervalOverrides[taskType.key];
      if (override == null || override <= 0) return null;
      return override;
    }

    final builtIn = taskType.builtIn!;

    // 1. Get user override or species default
    final userOverride = config.intervalOverrides[taskType.key];
    final speciesDefault = profile.getDefaultInterval(builtIn);

    final baseInterval = userOverride ?? speciesDefault;
    if (baseInterval == null || baseInterval <= 0) return null;

    // 2. Apply seasonal modifier
    final month = today.month;
    final modifier = profile.getSeasonalModifier(builtIn, month);
    final adjusted = (baseInterval * modifier).round();

    return adjusted > 0 ? adjusted : 1;
  }
}
