import 'dart:typed_data';

import 'package:open_plant/pages/plant_identification/classifier/classification_result.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_repository.dart';

/// Exposes classification to the UI layer.
class PlantClassifierUsecases {
  final PlantClassifierRepository _repository;

  const PlantClassifierUsecases({
    required PlantClassifierRepository repository,
  }) : _repository = repository;

  /// Classifies a plant image from raw bytes.
  Future<ClassificationResult> classifyImage(Uint8List imageBytes) {
    return _repository.classifyImage(imageBytes);
  }

  /// Releases resources.
  void dispose() {
    _repository.dispose();
  }
}
