import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Loads and caches the species label mapping from `labels.json`.
class LabelsLoader {
  Map<int, String>? _labels;

  /// Returns the label map (index → Latin species name).
  /// Loads from asset on first call, cached for subsequent calls.
  Future<Map<int, String>> load() async {
    if (_labels != null) return _labels!;

    final jsonStr = await rootBundle.loadString(
      'assets/ml/plant-identification/labels.json',
    );
    final Map<String, dynamic> raw = json.decode(jsonStr);

    _labels = raw.map((key, value) => MapEntry(int.parse(key), value as String));
    return _labels!;
  }

  /// Returns the species name for a given index, or 'Unknown' if not found.
  Future<String> labelFor(int index) async {
    final labels = await load();
    return labels[index] ?? 'Unknown species';
  }
}
