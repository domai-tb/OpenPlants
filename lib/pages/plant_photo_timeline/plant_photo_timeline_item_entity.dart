/// A dated photo in a plant's growth timeline.
class PlantPhoto {
  final String id;
  final DateTime date;
  final String filePath;
  final String? caption;

  const PlantPhoto({
    required this.id,
    required this.date,
    required this.filePath,
    this.caption,
  });

  /// Create a copy with optional field overrides.
  PlantPhoto copyWith({
    String? id,
    DateTime? date,
    String? filePath,
    bool clearCaption = false,
    String? caption,
  }) {
    return PlantPhoto(
      id: id ?? this.id,
      date: date ?? this.date,
      filePath: filePath ?? this.filePath,
      caption: clearCaption ? null : (caption ?? this.caption),
    );
  }

  /// Serialize to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'filePath': filePath,
      'caption': caption,
    };
  }

  /// Deserialize from JSON map.
  factory PlantPhoto.fromJson(Map<String, dynamic> json) {
    return PlantPhoto(
      id: json['id'] as String,
      date: DateTime.parse(json['date'] as String),
      filePath: json['filePath'] as String,
      caption: json['caption'] as String?,
    );
  }

  /// Deserialize a list of photos from JSON.
  static List<PlantPhoto> listFromJson(List<dynamic> json) {
    return json.map((item) => PlantPhoto.fromJson(item as Map<String, dynamic>)).toList();
  }

  /// Serialize a list of photos to JSON.
  static List<Map<String, dynamic>> listToJson(List<PlantPhoto> photos) {
    return photos.map((p) => p.toJson()).toList();
  }
}
