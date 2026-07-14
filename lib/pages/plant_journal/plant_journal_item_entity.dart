/// Types of journal entries a user can create.
enum JournalEntryType {
  text,
  photo,
  task,
  growth,
  repotting,
  pest,
  symptom,
  diagnosis,
}

/// Extension methods for JournalEntryType enum.
extension JournalEntryTypeExtension on JournalEntryType {
  /// Convert to JSON string.
  String toJson() => name;

  /// Convert from JSON string.
  static JournalEntryType fromJson(String json) {
    return JournalEntryType.values.firstWhere(
      (e) => e.name == json,
      orElse: () => JournalEntryType.text,
    );
  }
}

/// Represents a single journal entry tied to a specific plant.
class JournalEntry {
  final String id;
  final String plantId;
  final JournalEntryType type;
  final DateTime timestamp;
  final String? notes;
  final String? photoPath;
  final String? referenceId;
  final Map<String, dynamic>? structuredData;

  const JournalEntry({
    required this.id,
    required this.plantId,
    required this.type,
    required this.timestamp,
    this.notes,
    this.photoPath,
    this.referenceId,
    this.structuredData,
  });

  /// Create a copy with optional field overrides.
  JournalEntry copyWith({
    String? id,
    String? plantId,
    JournalEntryType? type,
    DateTime? timestamp,
    String? notes,
    bool clearNotes = false,
    String? photoPath,
    bool clearPhoto = false,
    String? referenceId,
    bool clearReferenceId = false,
    Map<String, dynamic>? structuredData,
    bool clearStructuredData = false,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      plantId: plantId ?? this.plantId,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      notes: clearNotes ? null : (notes ?? this.notes),
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      referenceId: clearReferenceId ? null : (referenceId ?? this.referenceId),
      structuredData: clearStructuredData ? null : (structuredData ?? this.structuredData),
    );
  }

  /// Serialize to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'plantId': plantId,
      'type': type.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
      'photoPath': photoPath,
      if (referenceId != null) 'referenceId': referenceId,
      if (structuredData != null) 'structuredData': structuredData,
    };
  }

  /// Deserialize from JSON map.
  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      type: JournalEntryTypeExtension.fromJson(json['type'] as String? ?? 'text'),
      timestamp: DateTime.parse(json['timestamp'] as String),
      notes: json['notes'] as String?,
      photoPath: json['photoPath'] as String?,
      referenceId: json['referenceId'] as String?,
      structuredData: json['structuredData'] as Map<String, dynamic>?,
    );
  }
}
