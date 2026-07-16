import 'dart:convert';

import 'package:flutter/services.dart';

/// Loads bundled model metadata JSON asset lazily with in-memory caching.
class ModelInfoDatasource {
  final AssetBundle _bundle;

  /// Defaults to [rootBundle], injectable for testing.
  ModelInfoDatasource({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  Map<String, dynamic>? _cachedMeta;

  /// Returns the parsed model metadata from the bundled JSON asset.
  ///
  /// Loads `onnx_export_info.json` and maps its fields to the
  /// [ModelInfoItem] format expected by the UI.
  Future<Map<String, dynamic>> loadModelMeta() async {
    if (_cachedMeta != null) return _cachedMeta!;

    final jsonString = await _bundle.loadString(
      'assets/ml/plant-identification/onnx_export_info.json',
    );
    final raw = json.decode(jsonString) as Map<String, dynamic>;

    _cachedMeta = {
      'name': raw['source_model'] as String? ?? 'Unknown Model',
      'version': 'opset ${raw['opset'] ?? 'unknown'}',
      'license': 'See model source',
      'inputSize': _formatInputSize(raw['input_shape']),
      'labelCount': _extractLabelCount(raw['output_shape']),
      'confidenceDescription': raw['output_semantics'] as String? ?? '',
      'url': 'https://huggingface.co/${raw['source_model'] ?? ''}',
    };

    return _cachedMeta!;
  }

  String _formatInputSize(dynamic shape) {
    if (shape is List && shape.length >= 3) {
      return '${shape[2]}x${shape[3]}';
    }
    return 'unknown';
  }

  int _extractLabelCount(dynamic shape) {
    if (shape is List && shape.length >= 2) {
      return shape[1] as int;
    }
    return 0;
  }
}
