import 'dart:typed_data';

import 'package:open_plant/pages/plant_identification/classifier/classification_result.dart';
import 'package:open_plant/pages/plant_identification/classifier/image_preprocessor.dart';
import 'package:open_plant/pages/plant_identification/classifier/labels_loader.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier.dart';
import 'package:open_plant/pages/plant_identification/classifier/softmax_postprocessor.dart';

/// Orchestrates the full classification pipeline: preprocess → infer → postprocess.
class PlantClassifierDatasource {
  final PlantClassifier _classifier;
  final ImagePreprocessor _preprocessor;
  final SoftmaxPostprocessor _postprocessor;

  PlantClassifierDatasource({
    PlantClassifier? classifier,
    ImagePreprocessor? preprocessor,
    LabelsLoader? labelsLoader,
  })  : _classifier = classifier ?? PlantClassifier(),
        _preprocessor = preprocessor ?? ImagePreprocessor(),
        _postprocessor = SoftmaxPostprocessor(
          labelsLoader: labelsLoader ?? LabelsLoader(),
        );

  /// Classifies a plant image from raw bytes.
  Future<ClassificationResult> classifyImage(Uint8List imageBytes) async {
    // Preprocess: decode → resize → normalize → NCHW tensor
    final tensor = await _preprocessor.preprocess(imageBytes);

    // Inference: run ONNX model
    final logits = await _classifier.runInference(
      inputName: 'pixel_values',
      inputData: tensor,
      inputShape: [1, 3, 224, 224],
    );

    // Postprocess: softmax → top-k label mapping
    return _postprocessor.postprocess(logits: logits);
  }

  /// Releases the ONNX session.
  void dispose() {
    _classifier.dispose();
  }
}
