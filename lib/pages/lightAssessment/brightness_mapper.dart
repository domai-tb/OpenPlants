import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';

/// Maps ambient brightness values to light levels.
///
/// Brightness is a normalized value from 0.0 (dark) to 1.0 (very bright).
/// These thresholds are approximate and based on typical indoor lighting.
class BrightnessMapper {
  /// Map a normalized brightness value (0.0–1.0) to a [LightLevel].
  ///
  /// Thresholds:
  /// - 0.0–0.25: low
  /// - 0.25–0.50: medium
  /// - 0.50–0.75: brightIndirect
  /// - 0.75–1.0: direct
  static LightLevel mapToLightLevel(double brightness) {
    final clamped = brightness.clamp(0.0, 1.0);
    if (clamped < 0.25) return LightLevel.low;
    if (clamped < 0.50) return LightLevel.medium;
    if (clamped < 0.75) return LightLevel.brightIndirect;
    return LightLevel.direct;
  }

  /// Human-readable description of the estimated light level.
  static String describeEstimate(LightLevel level) {
    return switch (level) {
      LightLevel.low => 'Looks like low light',
      LightLevel.medium => 'Looks like medium light',
      LightLevel.brightIndirect => 'Looks like bright indirect light',
      LightLevel.direct => 'Looks like direct sunlight',
    };
  }
}
