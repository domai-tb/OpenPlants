import 'package:flutter/foundation.dart';

/// Built-in care task types.
enum BuiltInTaskType {
  watering,
  fertilizing,
  misting,
  pruning,
  rotating,
  repotting,
  leafCleaning,
  pestInspection,
}

/// Extension for JSON serialization.
extension BuiltInTaskTypeExtension on BuiltInTaskType {
  String toJson() => name;

  static BuiltInTaskType fromJson(String json) {
    return BuiltInTaskType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => BuiltInTaskType.watering,
    );
  }

  /// Human-readable label.
  String get label {
    switch (this) {
      case BuiltInTaskType.watering:
        return 'Watering';
      case BuiltInTaskType.fertilizing:
        return 'Fertilizing';
      case BuiltInTaskType.misting:
        return 'Misting';
      case BuiltInTaskType.pruning:
        return 'Pruning';
      case BuiltInTaskType.rotating:
        return 'Rotating';
      case BuiltInTaskType.repotting:
        return 'Repotting';
      case BuiltInTaskType.leafCleaning:
        return 'Leaf Cleaning';
      case BuiltInTaskType.pestInspection:
        return 'Pest Inspection';
    }
  }
}

/// A care task type — either one of the 8 built-in types or a user-defined custom type.
@immutable
class CareTaskType {
  /// If non-null, this is a built-in type.
  final BuiltInTaskType? builtIn;

  /// If non-null, this is a custom user-defined type.
  final String? customName;

  const CareTaskType.builtIn(this.builtIn) : customName = null;

  const CareTaskType.custom(this.customName) : builtIn = null;

  /// Factory for creating a custom type.
  factory CareTaskType.fromCustom(String name) => CareTaskType.custom(name);

  /// The display name of the task type.
  String get label {
    if (builtIn != null) return builtIn!.label;
    return customName ?? 'Unknown';
  }

  /// Unique key for storage and comparison.
  String get key {
    if (builtIn != null) return builtIn!.name;
    return 'custom_$customName';
  }

  bool get isBuiltIn => builtIn != null;
  bool get isCustom => customName != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CareTaskType &&
          runtimeType == other.runtimeType &&
          builtIn == other.builtIn &&
          customName == other.customName;

  @override
  int get hashCode => builtIn.hashCode ^ customName.hashCode;

  /// Serialize to JSON string.
  String toJson() {
    if (builtIn != null) return builtIn!.toJson();
    return 'custom:$customName';
  }

  /// Deserialize from JSON string.
  factory CareTaskType.fromJson(String json) {
    if (json.startsWith('custom:')) {
      return CareTaskType.custom(json.substring(7));
    }
    return CareTaskType.builtIn(BuiltInTaskTypeExtension.fromJson(json));
  }
}
