import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:path_provider/path_provider.dart';

/// Manages the ONNX Runtime session for plant classification.
///
/// The model is split into two files (model.onnx + model.onnx.data) which
/// must be co-located on the filesystem. This class copies both to the
/// app's cache directory on first use, then loads the session from there.
class PlantClassifier {
  OnnxRuntime? _ort;
  OrtSession? _session;

  static const String _modelAsset = 'assets/ml/plant-identification/model.onnx';
  static const String _dataAsset = 'assets/ml/plant-identification/model.onnx.data';

  /// Copies model assets to the cache directory if not already present,
  /// then creates and returns the ONNX session.
  Future<OrtSession> get session async {
    if (_session != null) return _session!;

    final cacheDir = await _ensureModelCached();

    _ort = OnnxRuntime();
    final modelPath = '${cacheDir.path}/model.onnx';
    _session = await _ort!.createSession(modelPath);
    return _session!;
  }

  /// Copies model.onnx and model.onnx.data to the cache directory.
  /// Skips if both files already exist.
  Future<Directory> _ensureModelCached() async {
    final cacheDir = await getApplicationCacheDirectory();
    final modelFile = File('${cacheDir.path}/model.onnx');
    final dataFile = File('${cacheDir.path}/model.onnx.data');

    // Use synchronous file checks to avoid slow async IO lint.
    if (modelFile.existsSync() && dataFile.existsSync()) {
      final modelSize = modelFile.lengthSync();
      final dataSize = dataFile.lengthSync();
      if (modelSize > 0 && dataSize > 0) {
        return cacheDir;
      }
    }

    final modelBytes = await rootBundle.load(_modelAsset);
    final dataBytes = await rootBundle.load(_dataAsset);

    await modelFile.writeAsBytes(
      modelBytes.buffer.asUint8List(),
      flush: true,
    );
    await dataFile.writeAsBytes(
      dataBytes.buffer.asUint8List(),
      flush: true,
    );

    return cacheDir;
  }

  /// Runs inference on the given input tensor and returns raw logits.
  ///
  /// [inputName] is the model's input tensor name (e.g., 'pixel_values').
  /// [inputData] is the preprocessed float32 tensor.
  /// [inputShape] is the tensor shape (e.g., [1, 3, 224, 224]).
  Future<List<double>> runInference({
    required String inputName,
    required List<double> inputData,
    required List<int> inputShape,
  }) async {
    final sess = await session;

    final inputTensor = await OrtValue.fromList(inputData, inputShape);

    try {
      final outputs = await sess.run({inputName: inputTensor});

      if (outputs.isEmpty) {
        throw Exception('Model returned empty output');
      }

      final output = outputs.values.first;
      final flat = await output.asFlattenedList();
      final logits = flat.map((e) => (e as num).toDouble()).toList();

      await inputTensor.dispose();
      for (final t in outputs.values) {
        await t.dispose();
      }

      return logits;
    } catch (e) {
      await inputTensor.dispose();
      rethrow;
    }
  }

  /// Releases the ONNX session and all associated native resources.
  Future<void> dispose() async {
    await _session?.close();
    _session = null;
    _ort = null;
  }
}
