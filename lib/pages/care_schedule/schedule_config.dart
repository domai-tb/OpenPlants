import 'package:open_plants/pages/care_schedule/care_task_type.dart';

/// Pot type affects watering interval.
enum PotType {
  terracotta,
  plastic,
  selfWatering,
}

/// Extension for JSON serialization.
extension PotTypeExtension on PotType {
  String toJson() => name;

  static PotType fromJson(String json) {
    return PotType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => PotType.plastic,
    );
  }
}

/// Per-plant schedule configuration.
///
/// Stores per-task-type interval overrides (null = use species default),
/// pot type, and species profile ID.
class ScheduleConfig {
  /// Per-task-type interval overrides in days. Key is [CareTaskType.key].
  /// Null means use species default.
  final Map<String, int?> intervalOverrides;

  /// The pot type for this plant.
  final PotType potType;

  /// The species care profile ID (null = use general fallback).
  final String? speciesProfileId;

  const ScheduleConfig({
    this.intervalOverrides = const {},
    this.potType = PotType.plastic,
    this.speciesProfileId,
  });

  /// Default config for new plants.
  factory ScheduleConfig.defaults() => const ScheduleConfig();

  ScheduleConfig copyWith({
    Map<String, int?>? intervalOverrides,
    PotType? potType,
    String? speciesProfileId,
    bool clearSpeciesProfile = false,
  }) {
    return ScheduleConfig(
      intervalOverrides: intervalOverrides ?? this.intervalOverrides,
      potType: potType ?? this.potType,
      speciesProfileId: clearSpeciesProfile ? null : (speciesProfileId ?? this.speciesProfileId),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'intervalOverrides': intervalOverrides,
      'potType': potType.toJson(),
      'speciesProfileId': speciesProfileId,
    };
  }

  factory ScheduleConfig.fromJson(Map<String, dynamic> json) {
    final overridesRaw = json['intervalOverrides'] as Map<String, dynamic>?;
    final overrides = overridesRaw?.map(
      (key, value) => MapEntry(key, value as int?),
    );

    return ScheduleConfig(
      intervalOverrides: overrides ?? const {},
      potType: PotTypeExtension.fromJson(json['potType'] as String? ?? 'plastic'),
      speciesProfileId: json['speciesProfileId'] as String?,
    );
  }
}
