import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';

/// Persistent representation of a diagnosis result.
///
/// Wraps the transient [DiagnosisResult] with persistence fields (id, plantId,
/// timestamps) so it can be stored in SharedPreferences as JSON.
class DiagnosisResultEntity {
  /// Unique identifier for this diagnosis record.
  final String id;

  /// The plant this diagnosis is associated with.
  final String plantId;

  /// The symptom log entry that originated this diagnosis, when applicable.
  final String? symptomLogEntryId;

  /// The symptoms the user reported.
  final List<PlantSymptom> plantSymptoms;

  /// Ranked causes returned by the diagnosis engine.
  final List<ScoredCause> causes;

  /// Semantic outcome of the evaluation.
  final DiagnosisResultType type;

  /// Full context the user provided during diagnosis.
  final DiagnosisContext context;

  /// When this diagnosis was performed.
  final DateTime createdAt;

  const DiagnosisResultEntity({
    required this.id,
    required this.plantId,
    this.symptomLogEntryId,
    required this.plantSymptoms,
    required this.causes,
    required this.type,
    required this.context,
    required this.createdAt,
  });

  /// Creates a copy with optional field overrides.
  DiagnosisResultEntity copyWith({
    String? id,
    String? plantId,
    String? symptomLogEntryId,
    bool clearSymptomLogEntryId = false,
    List<PlantSymptom>? plantSymptoms,
    List<ScoredCause>? causes,
    DiagnosisResultType? type,
    DiagnosisContext? context,
    DateTime? createdAt,
  }) {
    return DiagnosisResultEntity(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      symptomLogEntryId: clearSymptomLogEntryId ? null : (symptomLogEntryId ?? this.symptomLogEntryId),
      plantSymptoms: plantSymptoms ?? this.plantSymptoms,
      causes: causes ?? this.causes,
      type: type ?? this.type,
      context: context ?? this.context,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Serializes to a JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'plantId': plantId,
        if (symptomLogEntryId != null) 'symptomLogEntryId': symptomLogEntryId,
        'plantSymptoms': plantSymptoms.map((e) => e.toJson()).toList(),
        'causes': causes.map((e) => e.toJson()).toList(),
        'type': type.name,
        'context': context.toMap(),
        'createdAt': createdAt.toIso8601String(),
      };

  /// Creates a DiagnosisResultEntity from a JSON map.
  factory DiagnosisResultEntity.fromJson(Map<String, dynamic> json) {
    return DiagnosisResultEntity(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      symptomLogEntryId: json['symptomLogEntryId'] as String?,
      plantSymptoms:
          (json['plantSymptoms'] as List<dynamic>).map((e) => PlantSymptomJson.fromJson(e as String)).toList(),
      causes: (json['causes'] as List<dynamic>).map((e) => ScoredCause.fromJson(e as Map<String, dynamic>)).toList(),
      type: DiagnosisResultType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      context: DiagnosisContext.fromMap(json['context'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
