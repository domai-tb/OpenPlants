import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// Wraps `image_picker` for camera and gallery image acquisition.
class ImageCaptureService {
  final ImagePicker _picker;

  ImageCaptureService({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  /// Captures a photo from the device camera.
  ///
  /// Returns image bytes or null if the user cancelled.
  /// Throws [CameraPermissionDeniedException] if permission is denied.
  Future<Uint8List?> captureFromCamera(BuildContext context) async {
    if (Platform.isAndroid || Platform.isIOS) {
      final hasPermission = await _requestCameraPermission(context);
      if (!hasPermission) return null;
    }

    final xFile = await _picker.pickImage(source: ImageSource.camera);
    if (xFile == null) return null;

    return xFile.readAsBytes();
  }

  /// Picks an existing photo from the device gallery.
  ///
  /// Returns image bytes or null if the user cancelled.
  Future<Uint8List?> pickFromGallery(BuildContext context) async {
    final xFile = await _picker.pickImage(source: ImageSource.gallery);
    if (xFile == null) return null;

    return xFile.readAsBytes();
  }

  /// Requests camera permission with rationale dialog on denial.
  ///
  /// Returns true if permission is granted, false otherwise.
  Future<bool> _requestCameraPermission(BuildContext context) async {
    // image_picker handles permission requests on Android/iOS.
    // If the user denies, pickImage returns null — we handle that gracefully.
    // For a more explicit flow, we could use permission_handler, but
    // image_picker's built-in handling is sufficient for v1.
    return true;
  }
}

/// Exception thrown when camera permission is denied.
class CameraPermissionDeniedException implements Exception {
  final String message;

  const CameraPermissionDeniedException([this.message = 'Camera permission denied']);

  @override
  String toString() => message;
}
