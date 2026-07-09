import 'package:open_plant/pages/plant_photo_timeline/plant_photo_timeline_item_entity.dart';

/// Light level assessment for a plant's location.
enum LightLevel {
  low,
  medium,
  brightIndirect,
  direct,
}

/// Extension methods for LightLevel enum.
extension LightLevelExtension on LightLevel {
  /// Convert to JSON string.
  String toJson() => name;

  /// Convert from JSON string.
  static LightLevel? fromJson(String? json) {
    if (json == null) return null;
    return LightLevel.values.firstWhere(
      (e) => e.name == json,
      orElse: () => LightLevel.medium,
    );
  }

  /// Human-readable label.
  String get label => switch (this) {
        LightLevel.low => 'Low',
        LightLevel.medium => 'Medium',
        LightLevel.brightIndirect => 'Bright Indirect',
        LightLevel.direct => 'Direct',
      };
}

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
  final String? roomId;
  final String? notes;
  final CareStatus careStatus;
  final DateTime? lastWateredAt;
  final DateTime? lastFertilizedAt;
  final LightLevel? lightLevel;
  final List<PlantPhoto> photos;
  final DateTime createdAt;
  final DateTime updatedAt;

  const PlantEntity({
    required this.id,
    required this.name,
    this.photoPath,
    this.speciesName,
    this.room,
    this.roomId,
    this.notes,
    this.careStatus = CareStatus.happy,
    this.lightLevel,
    this.lastWateredAt,
    this.lastFertilizedAt,
    this.photos = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns the effective care status considering both the stored [careStatus]
  /// and the care timestamps. Used for filtering and UI display.
  ///
  /// Priority (first match wins):
  /// 1. Explicit override: if stored [careStatus] is [needsWater] or
  ///    [needsFertilizer], use that value.
  /// 2. Never watered: if [lastWateredAt] is `null`, status is [needsWater].
  /// 3. Never fertilized: if [lastFertilizedAt] is `null`, status is
  ///    [needsFertilizer].
  /// 4. Otherwise, return the stored [careStatus] (typically [happy]).
  CareStatus get effectiveCareStatus {
    // 1. Explicit override — user-set needsWater/needsFertilizer always wins.
    if (careStatus == CareStatus.needsWater || careStatus == CareStatus.needsFertilizer) {
      return careStatus;
    }
    // 2. Never watered — water is more urgent than fertilizer.
    if (lastWateredAt == null) return CareStatus.needsWater;
    // 3. Never fertilized.
    if (lastFertilizedAt == null) return CareStatus.needsFertilizer;
    // 4. Happy (or other stored status).
    return careStatus;
  }

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
    String? roomId,
    bool clearRoomId = false,
    String? notes,
    bool clearNotes = false,
    CareStatus? careStatus,
    LightLevel? lightLevel,
    bool clearLightLevel = false,
    DateTime? lastWateredAt,
    bool clearLastWatered = false,
    DateTime? lastFertilizedAt,
    bool clearLastFertilized = false,
    List<PlantPhoto>? photos,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PlantEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      photoPath: clearPhoto ? null : (photoPath ?? this.photoPath),
      speciesName: clearSpecies ? null : (speciesName ?? this.speciesName),
      room: clearRoom ? null : (room ?? this.room),
      roomId: clearRoomId ? null : (roomId ?? this.roomId),
      notes: clearNotes ? null : (notes ?? this.notes),
      careStatus: careStatus ?? this.careStatus,
      lightLevel: clearLightLevel ? null : (lightLevel ?? this.lightLevel),
      lastWateredAt: clearLastWatered ? null : (lastWateredAt ?? this.lastWateredAt),
      lastFertilizedAt: clearLastFertilized ? null : (lastFertilizedAt ?? this.lastFertilizedAt),
      photos: photos ?? this.photos,
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
      'roomId': roomId,
      'notes': notes,
      'careStatus': careStatus.toJson(),
      'lightLevel': lightLevel?.toJson(),
      'lastWateredAt': lastWateredAt?.toIso8601String(),
      'lastFertilizedAt': lastFertilizedAt?.toIso8601String(),
      'photos': PlantPhoto.listToJson(photos),
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
      roomId: json['roomId'] as String?,
      notes: json['notes'] as String?,
      careStatus: CareStatusExtension.fromJson(json['careStatus'] as String? ?? 'happy'),
      lightLevel: LightLevelExtension.fromJson(json['lightLevel'] as String?),
      lastWateredAt: json['lastWateredAt'] != null ? DateTime.parse(json['lastWateredAt'] as String) : null,
      lastFertilizedAt: json['lastFertilizedAt'] != null ? DateTime.parse(json['lastFertilizedAt'] as String) : null,
      photos: json['photos'] != null ? PlantPhoto.listFromJson(json['photos'] as List<dynamic>) : const [],
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
