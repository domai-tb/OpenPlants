import 'dart:io';
import 'dart:math';

import 'package:camera/camera.dart';
import 'package:image/image.dart' as img;

import 'package:open_plant/pages/lightAssessment/brightness_mapper.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';

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
/// Captures a single frame from the viewfinder, analyzes average brightness,
/// and maps it to one of the four light levels.
class CameraEstimationService {
  CameraController? _controller;
  List<CameraDescription>? _cameras;

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

  /// Release camera resources.
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  /// Compute average brightness from an image.
  ///
  /// Converts each pixel to grayscale using the luminance formula:
  /// `L = 0.299R + 0.587G + 0.114B`
  ///
  /// Returns a normalized value between 0.0 (dark) and 1.0 (bright).
  double _computeAverageBrightness(img.Image image) {
    final int width = image.width;
    final int height = image.height;

    // Sample every Nth pixel for performance on large images
    final int step = max(1, min(width, height) ~/ 100);

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
}

/// Exception thrown by camera estimation operations.
class CameraEstimationException implements Exception {
  final String message;
  const CameraEstimationException(this.message);

  @override
  String toString() => 'CameraEstimationException: $message';
}
