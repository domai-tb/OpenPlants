import 'package:open_plants/pages/diagnosis/diagnosis_item_entity.dart';

// SymptomType enum has been removed — use PlantSymptom from diagnosis_item_entity.dart instead.

/// Severity level of a symptom.
enum Severity {
  mild,
  moderate,
  severe,
}

/// Plant parts that can be affected by symptoms.
enum AffectedPart {
  leaves,
  stems,
  roots,
  soil,
  flowers,
  multipleAreas,
}

/// When the symptom was first noticed.
enum OnsetTiming {
  today,
  fewDaysAgo,
  aboutAWeekAgo,
  moreThanAWeekAgo,
}

/// Soil moisture observation.
enum SoilMoisture {
  dry,
  moist,
  wet,
  soggy,
}

/// Light condition observation.
enum LightCondition {
  fullSun,
  partialShade,
  lowLight,
  unknown,
}

/// Extension for JSON serialization of [Severity].
extension SeverityExtension on Severity {
  String toJson() => name;

  static Severity fromJson(String json) {
    return Severity.values.firstWhere(
      (e) => e.name == json,
      orElse: () => Severity.mild,
    );
  }
}

/// Extension for JSON serialization of [OnsetTiming].
extension OnsetTimingExtension on OnsetTiming {
  String toJson() => name;

  static OnsetTiming fromJson(String json) {
    return OnsetTiming.values.firstWhere(
      (e) => e.name == json,
      orElse: () => OnsetTiming.today,
    );
  }
}

/// Extension for JSON serialization of [SoilMoisture].
extension SoilMoistureExtension on SoilMoisture {
  String toJson() => name;

  static SoilMoisture fromJson(String json) {
    return SoilMoisture.values.firstWhere(
      (e) => e.name == json,
      orElse: () => SoilMoisture.dry,
    );
  }
}

/// Extension for JSON serialization of [LightCondition].
extension LightConditionExtension on LightCondition {
  String toJson() => name;

  static LightCondition fromJson(String json) {
    return LightCondition.values.firstWhere(
      (e) => e.name == json,
      orElse: () => LightCondition.unknown,
    );
  }
}

/// Immutable entity representing a single symptom log entry for a plant.
class SymptomLogEntry {
  final String id;
  final String plantId;
  final List<PlantSymptom> symptomTypes;
  final Severity severity;
  final List<AffectedPart> affectedParts;
  final OnsetTiming onsetTiming;
  final SoilMoisture? soilMoisture;
  final LightCondition? lightConditions;
  final String? notes;
  final String? photoPath;
  final DateTime createdAt;
  final bool resolved;
  final DateTime? resolvedAt;
  final String? diagnosisResultId;

  const SymptomLogEntry({
    required this.id,
    required this.plantId,
    required this.symptomTypes,
    required this.severity,
    required this.affectedParts,
    required this.onsetTiming,
    this.soilMoisture,
    this.lightConditions,
    this.notes,
    this.photoPath,
    required this.createdAt,
    this.resolved = false,
    this.resolvedAt,
    this.diagnosisResultId,
  });

  /// Creates a copy with optional field overrides.
  SymptomLogEntry copyWith({
    String? id,
    String? plantId,
    List<PlantSymptom>? symptomTypes,
    Severity? severity,
    List<AffectedPart>? affectedParts,
    OnsetTiming? onsetTiming,
    SoilMoisture? soilMoisture,
    bool clearSoilMoisture = false,
    LightCondition? lightConditions,
    bool clearLightConditions = false,
    String? notes,
    bool clearNotes = false,
    String? photoPath,
    bool clearPhoto = false,
    DateTime? createdAt,
    bool? resolved,
    DateTime? resolvedAt,
    bool clearResolvedAt = false,
    String? diagnosisResultId,
    bool clearDiagnosisResultId = false,
  }) {
    return SymptomLogEntry(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      symptomTypes: symptomTypes ?? this.symptomTypes,
      severity: severity ?? this.severity,
      affectedParts: affectedParts ?? this.affectedParts,
      onsetTiming: onsetTiming ?? this.onsetTiming,
      soilMoisture: clearSoilMoisture ? null : (soilMoisture ?? this.soilMoisture),
      lightConditions: clearLightConditions ? null : (lightConditions ?? this.lightConditions),
      notes: clearNotes ? null : (notes ?? this.notes),
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      createdAt: createdAt ?? this.createdAt,
      resolved: resolved ?? this.resolved,
      resolvedAt: clearResolvedAt ? null : (resolvedAt ?? this.resolvedAt),
      diagnosisResultId: clearDiagnosisResultId ? null : (diagnosisResultId ?? this.diagnosisResultId),
    );
  }

  /// Serializes this entry to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'symptomTypes': symptomTypes.map((e) => e.name).toList(),
      'severity': severity.name,
      'affectedParts': affectedParts.map((e) => e.name).toList(),
      'onsetTiming': onsetTiming.name,
      'soilMoisture': soilMoisture?.name,
      'lightConditions': lightConditions?.name,
      'notes': notes,
      'photoPath': photoPath,
      'createdAt': createdAt.toIso8601String(),
      'resolved': resolved,
      'resolvedAt': resolvedAt?.toIso8601String(),
      if (diagnosisResultId != null) 'diagnosisResultId': diagnosisResultId,
    };
  }

  /// Deserializes from a JSON map.
  factory SymptomLogEntry.fromJson(Map<String, dynamic> json) {
    return SymptomLogEntry(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      symptomTypes: (json['symptomTypes'] as List<dynamic>).map((e) => _migrateSymptomType(e as String)).toList(),
      severity: SeverityExtension.fromJson(json['severity'] as String),
      affectedParts: (json['affectedParts'] as List<dynamic>)
          .map((e) => AffectedPart.values.firstWhere((a) => a.name == e as String))
          .toList(),
      onsetTiming: OnsetTimingExtension.fromJson(json['onsetTiming'] as String),
      soilMoisture:
          json['soilMoisture'] != null ? SoilMoistureExtension.fromJson(json['soilMoisture'] as String) : null,
      lightConditions:
          json['lightConditions'] != null ? LightConditionExtension.fromJson(json['lightConditions'] as String) : null,
      notes: json['notes'] as String?,
      photoPath: json['photoPath'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      resolved: json['resolved'] as bool? ?? false,
      resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
      diagnosisResultId: json['diagnosisResultId'] as String?,
    );
  }

  /// Migrates old SymptomType names to the unified [PlantSymptom] names.
  static PlantSymptom _migrateSymptomType(String name) {
    // Map old SymptomType names to new PlantSymptom names
    const migrationMap = <String, String>{
      'yellowLeaves': 'yellowingLeaves',
      'drooping': 'droopingWilt',
      'pests': 'visibleInsects',
      'mold': 'moldOnSoil',
    };
    final migratedName = migrationMap[name] ?? name;
    return PlantSymptom.values.firstWhere(
      (s) => s.name == migratedName,
      orElse: () => PlantSymptom.yellowingLeaves,
    );
  }
}
