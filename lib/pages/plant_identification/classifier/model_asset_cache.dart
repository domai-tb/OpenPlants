import 'dart:io';

import 'package:flutter/services.dart' show rootBundle;

/// Interface for loading model assets from Flutter bundle.
abstract class AssetLoader {
  Future<List<int>> loadModelBytes();
  Future<List<int>> loadDataBytes();
  Future<String> loadIdentityContent();
}

/// Default implementation that loads from Flutter rootBundle.
class BundleAssetLoader implements AssetLoader {
  final String modelAssetPath;
  final String dataAssetPath;
  final String identityAssetPath;

  BundleAssetLoader({
    required this.modelAssetPath,
    required this.dataAssetPath,
    required this.identityAssetPath,
  });

  @override
  Future<List<int>> loadModelBytes() async {
    final data = await rootBundle.load(modelAssetPath);
    return data.buffer.asUint8List();
  }

  @override
  Future<List<int>> loadDataBytes() async {
    final data = await rootBundle.load(dataAssetPath);
    return data.buffer.asUint8List();
  }

  @override
  Future<String> loadIdentityContent() async {
    return rootBundle.loadString(identityAssetPath);
  }
}

/// Manages versioned ONNX model assets with identity-based cache invalidation.
///
/// The model consists of three assets:
/// - model.onnx: The ONNX model graph
/// - model.onnx.data: External data for the model
/// - onnx_export_info.json: Version/metadata for cache invalidation
///
/// The cache is invalidated when:
/// - Any cached file is missing
/// - Any cached file is empty
/// - The identity content changes
class ModelAssetCache {
  final String modelAssetPath;
  final String dataAssetPath;
  final String identityAssetPath;

  ModelAssetCache({
    required this.modelAssetPath,
    required this.dataAssetPath,
    required this.identityAssetPath,
  });

  /// Ensures the model is cached and returns the cache directory.
  ///
  /// If the cache is valid (identity matches), returns immediately.
  /// Otherwise, copies all assets to the cache directory.
  Future<Directory> ensureModelCached({
    required AssetLoader assetLoader,
    Directory? cacheDir,
  }) async {
    final dir = cacheDir ?? await _getDefaultCacheDir();
    final modelFile = File('${dir.path}/model.onnx');
    final dataFile = File('${dir.path}/model.onnx.data');
    final identityFile = File('${dir.path}/onnx_export_info.json');

    // Check if cache is valid
    if (await _isCacheValid(modelFile, dataFile, identityFile, assetLoader)) {
      return dir;
    }

    // Clean up any temporary files from interrupted copies
    await _cleanupTempFiles(dir);

    // Copy all assets to cache
    await _copyAssetsToCache(dir, assetLoader);

    return dir;
  }

  Future<Directory> _getDefaultCacheDir() async {
    // This will be injected via path_provider in production
    // For testing, we pass cacheDir directly
    throw StateError('cacheDir must be provided in production');
  }

  Future<bool> _isCacheValid(
    File modelFile,
    File dataFile,
    File identityFile,
    AssetLoader assetLoader,
  ) async {
    // Check if all files exist and are non-empty
    if (!modelFile.existsSync() || modelFile.lengthSync() == 0) return false;
    if (!dataFile.existsSync() || dataFile.lengthSync() == 0) return false;
    if (!identityFile.existsSync()) return false;

    // Check if identity matches
    try {
      final cachedIdentity = await identityFile.readAsString();
      final assetIdentity = await assetLoader.loadIdentityContent();
      return cachedIdentity == assetIdentity;
    } catch (e) {
      return false;
    }
  }

  Future<void> _cleanupTempFiles(Directory dir) async {
    await for (final entity in dir.list()) {
      if (entity is File && entity.path.endsWith('.tmp')) {
        try {
          await entity.delete();
        } catch (_) {
          // Ignore cleanup errors
        }
      }
    }
  }

  Future<void> _copyAssetsToCache(Directory dir, AssetLoader assetLoader) async {
    // Load all assets first (fail fast if assets are missing)
    final modelBytes = await assetLoader.loadModelBytes();
    final dataBytes = await assetLoader.loadDataBytes();
    final identityContent = await assetLoader.loadIdentityContent();

    // Write to temporary files first, then rename (atomic operation)
    final modelFile = File('${dir.path}/model.onnx');
    final dataFile = File('${dir.path}/model.onnx.data');
    final identityFile = File('${dir.path}/onnx_export_info.json');

    final tempModel = File('${dir.path}/model.onnx.tmp');
    final tempData = File('${dir.path}/model.onnx.data.tmp');
    final tempIdentity = File('${dir.path}/onnx_export_info.json.tmp');

    try {
      await tempModel.writeAsBytes(modelBytes, flush: true);
      await tempData.writeAsBytes(dataBytes, flush: true);
      await tempIdentity.writeAsString(identityContent, flush: true);

      // Atomic rename
      await tempModel.rename(modelFile.path);
      await tempData.rename(dataFile.path);
      await tempIdentity.rename(identityFile.path);
    } catch (e) {
      // Clean up temp files on failure
      await _cleanupTempFiles(dir);
      rethrow;
    }
  }
}
