/// A single species prediction from the plant classifier.
class SpeciesPrediction {
  final String name;
  final double confidence;
  final int index;

  const SpeciesPrediction({
    required this.name,
    required this.confidence,
    required this.index,
  });
}

/// Result of a plant classification inference.
class ClassificationResult {
  final List<SpeciesPrediction> predictions;

  const ClassificationResult({required this.predictions});

  /// Returns the top-k predictions sorted by confidence descending.
  List<SpeciesPrediction> topK(int k) {
    final sorted = List<SpeciesPrediction>.from(predictions)
      ..sort((a, b) => b.confidence.compareTo(a.confidence));
    return sorted.take(k).toList();
  }
}
