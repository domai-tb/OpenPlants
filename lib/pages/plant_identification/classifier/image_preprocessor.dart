import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Preprocesses raw image bytes into an NCHW float32 tensor for the ONNX model.
///
/// Contract (from preprocessor_config.json):
/// - Resize to 224×224
/// - Rescale by 1/255
/// - Normalize: (x - 0.5) / 0.5
/// - Layout: NCHW [1, 3, 224, 224]
class ImagePreprocessor {
  static const int _size = 224;

  /// Converts raw image bytes into a [Float32List] shaped [1, 3, 224, 224].
  Future<Float32List> preprocess(Uint8List imageBytes) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw Exception('Failed to decode image');
    }

    // Apply EXIF orientation correction
    final oriented = img.bakeOrientation(decoded);

    // Resize to 224×224
    final resized = img.copyResize(
      oriented,
      width: _size,
      height: _size,
      interpolation: img.Interpolation.linear,
    );

    // Build NCHW float32 tensor: [1, 3, 224, 224]
    final tensor = Float32List(1 * 3 * _size * _size);
    var offset = 0;

    for (var c = 0; c < 3; c++) {
      for (var y = 0; y < _size; y++) {
        for (var x = 0; x < _size; x++) {
          final pixel = resized.getPixel(x, y);

          // Extract channel value (0-255) then rescale and normalize
          final raw = switch (c) {
            0 => pixel.r,
            1 => pixel.g,
            _ => pixel.b,
          };

          // Rescale ×(1/255) then normalize (x - 0.5) / 0.5
          final value = (raw / 255.0 - 0.5) / 0.5;
          tensor[offset++] = value;
        }
      }
    }

    return tensor;
  }
}
