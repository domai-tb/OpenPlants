import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

import 'package:open_plants/pages/light_assessment/brightness_mapper.dart';
import 'package:open_plants/pages/plant_collection/plant_collection_item_entity.dart';

/// Result of a camera-based light estimation.
class CameraEstimationResult {
  final LightLevel level;
  final double brightness;
  final String description;

  const CameraEstimationResult({
    required this.level,
    required this.brightness,
    required this.description,
  });
}

/// Service that estimates light level using the device camera.
///
/// Supports two modes:
/// 1. **Frame stream** — processes live camera frames at 1–2 FPS for
///    real-time brightness feedback via [startFrameStream].
/// 2. **Single frame / file** — captures a photo or analyses an existing
///    image via [estimate] / [estimateFromFile].
class CameraEstimationService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  DateTime _lastFrameProcessed = DateTime(2000);
  bool _frameStreamActive = false;

  /// Minimum interval between frame processing (1–2 FPS target).
  static const Duration _frameInterval = Duration(milliseconds: 600);

  /// Check if camera is available on this device.
  Future<bool> isAvailable() async {
    try {
      _cameras = await availableCameras();
      return _cameras != null && _cameras!.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Initialize the camera for brightness estimation.
  ///
  /// Uses the back camera at low resolution for fast analysis.
  Future<void> initialize() async {
    if (_cameras == null || _cameras!.isEmpty) {
      _cameras = await availableCameras();
    }

    if (_cameras == null || _cameras!.isEmpty) {
      throw const CameraEstimationException('No cameras available');
    }

    // Use the back camera (first in list)
    final camera = _cameras!.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras!.first,
    );

    _controller = CameraController(
      camera,
      ResolutionPreset.low, // Low resolution is sufficient for brightness
      enableAudio: false,
    );

    await _controller!.initialize();
  }

  /// Start processing live camera frames for real-time brightness estimation.
  ///
  /// Frames are processed at approximately 1–2 FPS. [onFrame] is called
  /// with the brightness (0.0–1.0), mapped [LightLevel], and a confidence
  /// value (0.0–1.0) based on frame quality.
  Future<void> startFrameStream({
    required void Function(double brightness, LightLevel level, double confidence) onFrame,
  }) async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw const CameraEstimationException('Camera not initialized');
    }

    if (_frameStreamActive) return;

    _frameStreamActive = true;
    await _controller!.startImageStream(
      (CameraImage image) => _processFrame(image, onFrame),
    );
  }

  /// Stop the live frame stream.
  Future<void> stopFrameStream() async {
    _frameStreamActive = false;

    if (_controller != null && _controller!.value.isStreamingImages) {
      await _controller!.stopImageStream();
    }
  }

  /// Process a single [CameraImage] frame, throttled to ~1–2 FPS.
  void _processFrame(
    CameraImage image,
    void Function(double brightness, LightLevel level, double confidence) onFrame,
  ) {
    final now = DateTime.now();
    if (now.difference(_lastFrameProcessed) < _frameInterval) return;
    _lastFrameProcessed = now;

    try {
      final brightness = _computeLuminanceFromYuv(image);
      final level = BrightnessMapper.mapToLightLevel(brightness);
      final confidence = _estimateConfidence(brightness, image);

      onFrame(brightness, level, confidence);
    } catch (_) {
      // Silently skip unprocessable frames
    }
  }

  /// Estimate the light level from the current camera view.
  ///
  /// Captures a single frame, computes average brightness,
  /// and returns the estimated light level.
  Future<CameraEstimationResult> estimate() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw const CameraEstimationException('Camera not initialized');
    }

    // Capture an image from the viewfinder
    final XFile xFile = await _controller!.takePicture();
    final bytes = await xFile.readAsBytes();

    // Decode the image
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw const CameraEstimationException('Failed to decode camera image');
    }

    // Compute average brightness
    final brightness = _computeAverageBrightness(image);

    // Map to light level
    final level = BrightnessMapper.mapToLightLevel(brightness);
    final description = BrightnessMapper.describeEstimate(level);

    return CameraEstimationResult(
      level: level,
      brightness: brightness,
      description: description,
    );
  }

  /// Estimate light level from an existing photo file.
  ///
  /// Decodes the image and computes average brightness,
  /// returning the estimated light level.
  Future<CameraEstimationResult> estimateFromFile(File photoFile) async {
    final bytes = await photoFile.readAsBytes();
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw const CameraEstimationException('Failed to decode photo');
    }

    final brightness = _computeAverageBrightness(image);
    final level = BrightnessMapper.mapToLightLevel(brightness);
    final description = BrightnessMapper.describeEstimate(level);

    return CameraEstimationResult(
      level: level,
      brightness: brightness,
      description: description,
    );
  }

  /// Provide a rough confidence score (0.0–1.0) for the current estimate
  /// based on how widely pixel values are spread.
  double _estimateConfidence(double brightness, CameraImage image) {
    // Simple heuristic: higher resolution samples give more confidence
    final pixelCount = image.width * image.height;
    if (pixelCount < 10_000) return 0.5;
    if (pixelCount < 50_000) return 0.7;

    // Consistent brightness (not at the extremes) is more reliable
    if (brightness < 0.05 || brightness > 0.95) return 0.6;

    return 0.85;
  }

  /// Whether the underlying camera controller is initialized and ready.
  bool get isControllerInitialized => _controller != null && _controller!.value.isInitialized;

  /// Expose the camera controller for use with [CameraPreview].
  CameraController? get controller => _controller;

  /// Release camera resources and stop frame stream.
  Future<void> dispose() async {
    await stopFrameStream();
    await _controller?.dispose();
    _controller = null;
  }

  // ---------------------------------------------------------------------------
  // Brightness computation
  // ---------------------------------------------------------------------------

  /// Compute average luminance directly from a YUV_420_888 [CameraImage].
  ///
  /// Only the Y (luminance) plane is sampled — no RGB conversion needed.
  /// Returns a value between 0.0 (dark) and 1.0 (bright).
  double _computeLuminanceFromYuv(CameraImage image) {
    final Plane plane = image.planes[0]; // Y plane
    final Uint8List yBuffer = plane.bytes;
    final int width = image.width;
    final int height = image.height;

    // Stride may be wider than logical width — account for it.
    final int rowStride = plane.bytesPerRow;
    final int step = _sampleStep(width, height);

    double total = 0;
    int count = 0;

    for (int y = 0; y < height; y += step) {
      final int rowOffset = y * rowStride;
      for (int x = 0; x < width; x += step) {
        total += yBuffer[rowOffset + x];
        count++;
      }
    }

    if (count == 0) return 0;
    return (total / count) / 255.0;
  }

  /// Compute average brightness from an already-decoded image.
  ///
  /// Converts each pixel to grayscale using the luminance formula:
  /// `L = 0.299R + 0.587G + 0.114B`
  ///
  /// Returns a normalized value between 0.0 (dark) and 1.0 (bright).
  double _computeAverageBrightness(img.Image image) {
    final int width = image.width;
    final int height = image.height;

    // Sample every Nth pixel for performance on large images
    final int step = _sampleStep(width, height);

    double totalLuminance = 0;
    int sampleCount = 0;

    for (int y = 0; y < height; y += step) {
      for (int x = 0; x < width; x += step) {
        final pixel = image.getPixel(x, y);

        // Compute luminance using ITU-R BT.601
        final double luminance = 0.299 * pixel.r + 0.587 * pixel.g + 0.114 * pixel.b;

        totalLuminance += luminance;
        sampleCount++;
      }
    }

    if (sampleCount == 0) return 0;

    // Normalize to 0.0–1.0 (pixel values are 0–255)
    return (totalLuminance / sampleCount) / 255.0;
  }

  /// Calculate a sampling step that keeps the number of samples manageable.
  int _sampleStep(int width, int height) {
    return max(1, min(width, height) ~/ 100);
  }
}

/// Exception thrown by camera estimation operations.
class CameraEstimationException implements Exception {
  final String message;
  const CameraEstimationException(this.message);

  @override
  String toString() => 'CameraEstimationException: $message';
}
