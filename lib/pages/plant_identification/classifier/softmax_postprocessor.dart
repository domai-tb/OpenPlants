import 'dart:math';

import 'package:open_plants/pages/plant_identification/classifier/classification_result.dart';
import 'package:open_plants/pages/plant_identification/classifier/labels_loader.dart';

/// Post-processes raw logits into classification results.
class SoftmaxPostprocessor {
  final LabelsLoader _labelsLoader;

  const SoftmaxPostprocessor({required LabelsLoader labelsLoader}) : _labelsLoader = labelsLoader;

  /// Applies softmax to raw logits and returns the top-k predictions.
  Future<ClassificationResult> postprocess({
    required List<double> logits,
    int topK = 5,
  }) async {
    final probabilities = _softmax(logits);
    final labels = await _labelsLoader.load();

    // Build predictions from all indices, then sort by confidence
    final predictions = <SpeciesPrediction>[];
    for (var i = 0; i < probabilities.length; i++) {
      predictions.add(
        SpeciesPrediction(
          name: labels[i] ?? 'Unknown species',
          confidence: probabilities[i],
          index: i,
        ),
      );
    }

    predictions.sort((a, b) => b.confidence.compareTo(a.confidence));

    return ClassificationResult(
      predictions: predictions.take(topK).toList(),
    );
  }

  /// Numerically stable softmax: subtract max before exponentiation.
  List<double> _softmax(List<double> logits) {
    if (logits.isEmpty) return const [];

    final maxLogit = logits.reduce(max);
    final exps = logits.map((x) => exp(x - maxLogit)).toList();
    final sumExps = exps.reduce((a, b) => a + b);

    return exps.map((e) => e / sumExps).toList();
  }
}
