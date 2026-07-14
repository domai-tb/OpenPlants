import 'dart:typed_data';

import 'package:open_plants/pages/plant_identification/classifier/classification_result.dart';

/// Represents the state of the plant identification page.
sealed class IdentificationState {
  const IdentificationState();
}

/// Initial state — no image captured yet.
class IdentificationIdle extends IdentificationState {
  const IdentificationIdle();
}

/// Inference in progress.
class IdentificationIdentifying extends IdentificationState {
  final Uint8List imageBytes;

  const IdentificationIdentifying({required this.imageBytes});
}

/// Classification complete with results.
class IdentificationResult extends IdentificationState {
  final Uint8List imageBytes;
  final ClassificationResult result;

  const IdentificationResult({
    required this.imageBytes,
    required this.result,
  });
}

/// Error occurred during identification.
class IdentificationError extends IdentificationState {
  final String message;

  const IdentificationError({required this.message});
}
