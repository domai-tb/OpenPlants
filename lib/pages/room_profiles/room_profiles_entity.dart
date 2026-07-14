/// Light level for a room.
enum RoomLightLevel {
  low,
  medium,
  bright,
  directSun,
}

/// Extension for JSON serialization and display.
extension RoomLightLevelExtension on RoomLightLevel {
  String toJson() => name;

  static RoomLightLevel fromJson(String json) {
    return RoomLightLevel.values.firstWhere(
      (e) => e.name == json,
      orElse: () => RoomLightLevel.medium,
    );
  }

  /// Human-readable label for display.
  String get label => switch (this) {
        RoomLightLevel.low => 'Low light',
        RoomLightLevel.medium => 'Medium light',
        RoomLightLevel.bright => 'Bright',
        RoomLightLevel.directSun => 'Direct sun',
      };
}

/// Humidity level for a room.
enum RoomHumidityLevel {
  low,
  medium,
  high,
}

/// Extension for JSON serialization and display.
extension RoomHumidityLevelExtension on RoomHumidityLevel {
  String toJson() => name;

  static RoomHumidityLevel fromJson(String json) {
    return RoomHumidityLevel.values.firstWhere(
      (e) => e.name == json,
      orElse: () => RoomHumidityLevel.medium,
    );
  }

  /// Human-readable label for display.
  String get label => switch (this) {
        RoomHumidityLevel.low => 'Low humidity',
        RoomHumidityLevel.medium => 'Medium humidity',
        RoomHumidityLevel.high => 'High humidity',
      };
}

/// Represents a room/location with environmental attributes.
class RoomEntity {
  final String id;
  final String name;
  final RoomLightLevel lightLevel;
  final RoomHumidityLevel humidityLevel;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const RoomEntity({
    required this.id,
    required this.name,
    this.lightLevel = RoomLightLevel.medium,
    this.humidityLevel = RoomHumidityLevel.medium,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  RoomEntity copyWith({
    String? id,
    String? name,
    RoomLightLevel? lightLevel,
    RoomHumidityLevel? humidityLevel,
    String? notes,
    bool clearNotes = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RoomEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      lightLevel: lightLevel ?? this.lightLevel,
      humidityLevel: humidityLevel ?? this.humidityLevel,
      notes: clearNotes ? null : (notes ?? this.notes),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'lightLevel': lightLevel.toJson(),
      'humidityLevel': humidityLevel.toJson(),
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory RoomEntity.fromJson(Map<String, dynamic> json) {
    return RoomEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      lightLevel: RoomLightLevelExtension.fromJson(json['lightLevel'] as String? ?? 'medium'),
      humidityLevel: RoomHumidityLevelExtension.fromJson(json['humidityLevel'] as String? ?? 'medium'),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }
}
