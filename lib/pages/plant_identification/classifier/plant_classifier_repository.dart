import 'dart:typed_data';

import 'package:open_plant/pages/plant_identification/classifier/classification_result.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_datasource.dart';

/// Wraps the datasource and maps to domain entities.
class PlantClassifierRepository {
  final PlantClassifierDatasource _dataSource;

  const PlantClassifierRepository({
    required PlantClassifierDatasource dataSource,
  }) : _dataSource = dataSource;

  /// Classifies a plant image from raw bytes.
  Future<ClassificationResult> classifyImage(Uint8List imageBytes) {
    return _dataSource.classifyImage(imageBytes);
  }

  /// Releases resources.
  void dispose() {
    _dataSource.dispose();
  }
}
