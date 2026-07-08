/// Care status for a plant.
enum CareStatus {
  happy,
  needsWater,
  needsFertilizer,
  needsAttention,
}

/// Extension methods for CareStatus enum.
extension CareStatusExtension on CareStatus {
  /// Convert to JSON string.
  String toJson() => name;

  /// Convert from JSON string.
  static CareStatus fromJson(String json) {
    return CareStatus.values.firstWhere(
      (e) => e.name == json,
      orElse: () => CareStatus.happy,
    );
  }
}

/// Represents a plant in the user's collection.
class PlantEntity {
  final String id;
  final String name;
  final String? photoPath;
  final String? speciesName;
  final String? room;
  final String? notes;
  final CareStatus careStatus;
  final DateTime? lastWateredAt;
  final DateTime? lastFertilizedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlantEntity({
    required this.id,
    required this.name,
    this.photoPath,
    this.speciesName,
    this.room,
    this.notes,
    this.careStatus = CareStatus.happy,
    this.lastWateredAt,
    this.lastFertilizedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create a copy with optional field overrides.
  PlantEntity copyWith({
    String? id,
    String? name,
    String? photoPath,
    bool clearPhoto = false,
    String? speciesName,
    bool clearSpecies = false,
    String? room,
    bool clearRoom = false,
    String? notes,
    bool clearNotes = false,
    CareStatus? careStatus,
    DateTime? lastWateredAt,
    bool clearLastWatered = false,
    DateTime? lastFertilizedAt,
    bool clearLastFertilized = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlantEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      speciesName: clearSpecies ? null : (speciesName ?? this.speciesName),
      room: clearRoom ? null : (room ?? this.room),
      notes: clearNotes ? null : (notes ?? this.notes),
      careStatus: careStatus ?? this.careStatus,
      lastWateredAt: clearLastWatered ? null : (lastWateredAt ?? this.lastWateredAt),
      lastFertilizedAt: clearLastFertilized ? null : (lastFertilizedAt ?? this.lastFertilizedAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Serialize to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'photoPath': photoPath,
      'speciesName': speciesName,
      'room': room,
      'notes': notes,
      'careStatus': careStatus.toJson(),
      'lastWateredAt': lastWateredAt?.toIso8601String(),
      'lastFertilizedAt': lastFertilizedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Deserialize from JSON map.
  factory PlantEntity.fromJson(Map<String, dynamic> json) {
    return PlantEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      photoPath: json['photoPath'] as String?,
      speciesName: json['speciesName'] as String?,
      room: json['room'] as String?,
      notes: json['notes'] as String?,
      careStatus: CareStatusExtension.fromJson(json['careStatus'] as String? ?? 'happy'),
      lastWateredAt: json['lastWateredAt'] != null ? DateTime.parse(json['lastWateredAt'] as String) : null,
      lastFertilizedAt: json['lastFertilizedAt'] != null ? DateTime.parse(json['lastFertilizedAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
