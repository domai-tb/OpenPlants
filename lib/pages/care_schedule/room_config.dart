/// Sunlight level for a room.
enum SunlightLevel {
  low,
  medium,
  high,
  fullSun,
}

/// Extension for JSON serialization.
extension SunlightLevelExtension on SunlightLevel {
  String toJson() => name;

  static SunlightLevel fromJson(String json) {
    return SunlightLevel.values.firstWhere(
      (e) => e.name == json,
      orElse: () => SunlightLevel.medium,
    );
  }
}

/// Humidity level for a room.
enum HumidityLevel {
  low,
  medium,
  high,
}

/// Extension for JSON serialization.
extension HumidityLevelExtension on HumidityLevel {
  String toJson() => name;

  static HumidityLevel fromJson(String json) {
    return HumidityLevel.values.firstWhere(
      (e) => e.name == json,
      orElse: () => HumidityLevel.medium,
    );
  }
}

/// Room-level attributes that modulate care schedules.
class RoomConfig {
  final String roomName;
  final SunlightLevel sunlightLevel;
  final HumidityLevel humidityLevel;
  final String? temperatureLabel;

  const RoomConfig({
    required this.roomName,
    this.sunlightLevel = SunlightLevel.medium,
    this.humidityLevel = HumidityLevel.medium,
    this.temperatureLabel,
  });

  RoomConfig copyWith({
    String? roomName,
    SunlightLevel? sunlightLevel,
    HumidityLevel? humidityLevel,
    String? temperatureLabel,
    bool clearTemperatureLabel = false,
  }) {
    return RoomConfig(
      roomName: roomName ?? this.roomName,
      sunlightLevel: sunlightLevel ?? this.sunlightLevel,
      humidityLevel: humidityLevel ?? this.humidityLevel,
      temperatureLabel: clearTemperatureLabel ? null : (temperatureLabel ?? this.temperatureLabel),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roomName': roomName,
      'sunlightLevel': sunlightLevel.toJson(),
      'humidityLevel': humidityLevel.toJson(),
      'temperatureLabel': temperatureLabel,
    };
  }

  factory RoomConfig.fromJson(Map<String, dynamic> json) {
    return RoomConfig(
      roomName: json['roomName'] as String,
      sunlightLevel: SunlightLevelExtension.fromJson(json['sunlightLevel'] as String? ?? 'medium'),
      humidityLevel: HumidityLevelExtension.fromJson(json['humidityLevel'] as String? ?? 'medium'),
      temperatureLabel: json['temperatureLabel'] as String?,
    );
  }
}
