import 'dart:io';

import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:open_plants/pages/plant_identification/classifier/model_asset_cache.dart';
import 'package:path_provider/path_provider.dart';

/// Manages the ONNX Runtime session for plant classification.
///
/// Uses [ModelAssetCache] to copy model assets to the cache directory,
/// with identity-based invalidation to detect model updates.
class PlantClassifier {
  OnnxRuntime? _ort;
  OrtSession? _session;

  late final ModelAssetCache _cache = ModelAssetCache(
    modelAssetPath: _modelAsset,
    dataAssetPath: _dataAsset,
    identityAssetPath: _identityAsset,
  );

  static const String _modelAsset = 'assets/ml/plant-identification/model.onnx';
  static const String _dataAsset = 'assets/ml/plant-identification/model.onnx.data';
  static const String _identityAsset = 'assets/ml/plant-identification/onnx_export_info.json';

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

  /// Uses [ModelAssetCache] to ensure model is cached with identity tracking.
  Future<Directory> _ensureModelCached() async {
    final cacheDir = await getApplicationCacheDirectory();
    final assetLoader = BundleAssetLoader(
      modelAssetPath: _modelAsset,
      dataAssetPath: _dataAsset,
      identityAssetPath: _identityAsset,
    );

    await _cache.ensureModelCached(
      assetLoader: assetLoader,
      cacheDir: cacheDir,
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
