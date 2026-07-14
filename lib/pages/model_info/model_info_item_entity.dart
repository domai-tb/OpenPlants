/// Immutable entity representing the ONNX model metadata.
class ModelInfoItem {
  final String name;
  final String version;
  final String license;
  final String inputSize;
  final int labelCount;
  final String confidenceDescription;
  final String url;

  const ModelInfoItem({
    required this.name,
    required this.version,
    required this.license,
    required this.inputSize,
    required this.labelCount,
    required this.confidenceDescription,
    required this.url,
  });

  /// Creates a [ModelInfoItem] from a parsed JSON map.
  factory ModelInfoItem.fromJson(Map<String, dynamic> json) {
    return ModelInfoItem(
      name: json['name'] as String,
      version: json['version'] as String,
      license: json['license'] as String,
      inputSize: json['inputSize'] as String,
      labelCount: json['labelCount'] as int,
      confidenceDescription: json['confidenceDescription'] as String,
      url: json['url'] as String,
    );
  }
}
