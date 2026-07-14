import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:open_plants/pages/plant_identification/classifier/model_asset_cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late Directory cacheDir;
  late ModelAssetCache cache;

  setUp(() async {
    // Use a temporary directory as the cache directory
    tempDir = await Directory.systemTemp.createTemp('model_cache_test_');
    cacheDir = Directory('${tempDir.path}/cache');
    await cacheDir.create();

    // Mock path_provider to return our temp directory
    PathProviderPlatform.instance = MockPathProvider(cacheDir);

    cache = ModelAssetCache(
      modelAssetPath: 'assets/ml/plant-identification/model.onnx',
      dataAssetPath: 'assets/ml/plant-identification/model.onnx.data',
      identityAssetPath: 'assets/ml/plant-identification/model_identity.json',
    );
  });

  tearDown(() async {
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ModelAssetCache', () {
    test('returns cached files when identity matches', () async {
      // Setup: Create cached files with matching identity
      final modelFile = File('${cacheDir.path}/model.onnx');
      final dataFile = File('${cacheDir.path}/model.onnx.data');
      final identityFile = File('${cacheDir.path}/model_identity.json');

      await modelFile.writeAsBytes([1, 2, 3]);
      await dataFile.writeAsBytes([4, 5, 6]);
      await identityFile.writeAsString('{"version": "1.0.0"}');

      // Create a mock asset loader that returns the same identity
      final assetLoader = MockAssetLoader(
        modelBytes: [1, 2, 3],
        dataBytes: [4, 5, 6],
        identityContent: '{"version": "1.0.0"}',
      );

      // Act
      final result = await cache.ensureModelCached(
        assetLoader: assetLoader,
        cacheDir: cacheDir,
      );

      // Assert: Should not overwrite existing files
      expect(result.path, equals(cacheDir.path));
      expect(modelFile.lengthSync(), equals(3));
      expect(dataFile.lengthSync(), equals(3));
    });

    test('refreshes cache when identity changes', () async {
      // Setup: Create cached files with old identity
      final modelFile = File('${cacheDir.path}/model.onnx');
      final dataFile = File('${cacheDir.path}/model.onnx.data');
      final identityFile = File('${cacheDir.path}/model_identity.json');

      await modelFile.writeAsBytes([1, 2, 3]);
      await dataFile.writeAsBytes([4, 5, 6]);
      await identityFile.writeAsString('{"version": "1.0.0"}');

      // Create a mock asset loader that returns new identity
      final assetLoader = MockAssetLoader(
        modelBytes: [7, 8, 9],
        dataBytes: [10, 11, 12],
        identityContent: '{"version": "2.0.0"}',
      );

      // Act
      final result = await cache.ensureModelCached(
        assetLoader: assetLoader,
        cacheDir: cacheDir,
      );

      // Assert: Should overwrite with new files
      expect(result.path, equals(cacheDir.path));
      expect(modelFile.readAsBytesSync(), equals([7, 8, 9]));
      expect(dataFile.readAsBytesSync(), equals([10, 11, 12]));
      expect(identityFile.readAsStringSync(), equals('{"version": "2.0.0"}'));
    });

    test('refreshes cache when model file is missing', () async {
      // Setup: Only data file exists
      final dataFile = File('${cacheDir.path}/model.onnx.data');
      await dataFile.writeAsBytes([4, 5, 6]);

      final assetLoader = MockAssetLoader(
        modelBytes: [1, 2, 3],
        dataBytes: [4, 5, 6],
        identityContent: '{"version": "1.0.0"}',
      );

      // Act
      await cache.ensureModelCached(
        assetLoader: assetLoader,
        cacheDir: cacheDir,
      );

      // Assert: Both files should be created
      final modelFile = File('${cacheDir.path}/model.onnx');
      expect(modelFile.existsSync(), isTrue);
      expect(modelFile.readAsBytesSync(), equals([1, 2, 3]));
    });

    test('refreshes cache when data file is missing', () async {
      // Setup: Only model file exists
      final modelFile = File('${cacheDir.path}/model.onnx');
      await modelFile.writeAsBytes([1, 2, 3]);

      final assetLoader = MockAssetLoader(
        modelBytes: [1, 2, 3],
        dataBytes: [4, 5, 6],
        identityContent: '{"version": "1.0.0"}',
      );

      // Act
      await cache.ensureModelCached(
        assetLoader: assetLoader,
        cacheDir: cacheDir,
      );

      // Assert: Both files should be created
      final dataFile = File('${cacheDir.path}/model.onnx.data');
      expect(dataFile.existsSync(), isTrue);
      expect(dataFile.readAsBytesSync(), equals([4, 5, 6]));
    });

    test('refreshes cache when model file is empty', () async {
      // Setup: Empty model file
      final modelFile = File('${cacheDir.path}/model.onnx');
      await modelFile.writeAsBytes([]);

      final assetLoader = MockAssetLoader(
        modelBytes: [1, 2, 3],
        dataBytes: [4, 5, 6],
        identityContent: '{"version": "1.0.0"}',
      );

      // Act
      await cache.ensureModelCached(
        assetLoader: assetLoader,
        cacheDir: cacheDir,
      );

      // Assert: File should be overwritten
      expect(modelFile.readAsBytesSync(), equals([1, 2, 3]));
    });

    test('refreshes cache when identity file is missing', () async {
      // Setup: Model files exist but no identity
      final modelFile = File('${cacheDir.path}/model.onnx');
      final dataFile = File('${cacheDir.path}/model.onnx.data');
      await modelFile.writeAsBytes([1, 2, 3]);
      await dataFile.writeAsBytes([4, 5, 6]);

      final assetLoader = MockAssetLoader(
        modelBytes: [1, 2, 3],
        dataBytes: [4, 5, 6],
        identityContent: '{"version": "1.0.0"}',
      );

      // Act
      await cache.ensureModelCached(
        assetLoader: assetLoader,
        cacheDir: cacheDir,
      );

      // Assert: Identity file should be created
      final identityFile = File('${cacheDir.path}/model_identity.json');
      expect(identityFile.existsSync(), isTrue);
      expect(identityFile.readAsStringSync(), equals('{"version": "1.0.0"}'));
    });

    test('handles interrupted temporary files by retrying', () async {
      // Setup: Create a temporary file that wasn't cleaned up
      final tempModel = File('${cacheDir.path}/model.onnx.tmp');
      await tempModel.writeAsBytes([1, 2, 3]);

      final assetLoader = MockAssetLoader(
        modelBytes: [7, 8, 9],
        dataBytes: [10, 11, 12],
        identityContent: '{"version": "1.0.0"}',
      );

      // Act
      await cache.ensureModelCached(
        assetLoader: assetLoader,
        cacheDir: cacheDir,
      );

      // Assert: Temporary file should be cleaned up, new files created
      expect(tempModel.existsSync(), isFalse);
      final modelFile = File('${cacheDir.path}/model.onnx');
      expect(modelFile.readAsBytesSync(), equals([7, 8, 9]));
    });

    test('throws on copy failure', () async {
      // Setup: Create a mock asset loader that throws
      final assetLoader = ThrowingAssetLoader(
        modelBytes: [1, 2, 3],
        dataBytes: [4, 5, 6],
        identityContent: '{"version": "1.0.0"}',
        throwOnLoad: true,
      );

      // Act & Assert
      expect(
        () => cache.ensureModelCached(
          assetLoader: assetLoader,
          cacheDir: cacheDir,
        ),
        throwsA(isA<Exception>()),
      );
    });
  });
}

/// Mock AssetLoader for testing
class MockAssetLoader implements AssetLoader {
  final List<int> modelBytes;
  final List<int> dataBytes;
  final String identityContent;

  MockAssetLoader({
    required this.modelBytes,
    required this.dataBytes,
    required this.identityContent,
  });

  @override
  Future<List<int>> loadModelBytes() async => modelBytes;

  @override
  Future<List<int>> loadDataBytes() async => dataBytes;

  @override
  Future<String> loadIdentityContent() async => identityContent;
}

/// Mock PathProvider for testing
class MockPathProvider extends PathProviderPlatform {
  final Directory cacheDir;

  MockPathProvider(this.cacheDir);

  @override
  Future<String?> getApplicationCachePath() async => cacheDir.path;
}

/// Mock AssetLoader that throws on load
class ThrowingAssetLoader implements AssetLoader {
  final List<int> modelBytes;
  final List<int> dataBytes;
  final String identityContent;
  final bool throwOnLoad;

  ThrowingAssetLoader({
    required this.modelBytes,
    required this.dataBytes,
    required this.identityContent,
    this.throwOnLoad = false,
  });

  @override
  Future<List<int>> loadModelBytes() async {
    if (throwOnLoad) throw Exception('Failed to load model');
    return modelBytes;
  }

  @override
  Future<List<int>> loadDataBytes() async => dataBytes;

  @override
  Future<String> loadIdentityContent() async => identityContent;
}
