import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

/// A reusable inline camera preview widget with capture and gallery support.
///
/// Displays a live camera viewfinder from the back camera with:
/// - Capture button overlay
/// - Gallery button for picking existing photos
/// - In-page permission handling with rationale
/// - Loading state while camera initializes
///
/// Usage:
/// ```dart
/// InlineCameraPreview(
///   onCaptured: (Uint8List bytes) {
///     // Handle captured image bytes
///   },
/// )
/// ```
class InlineCameraPreview extends StatefulWidget {
  /// Callback invoked when a photo is captured or selected from gallery.
  final ValueChanged<Uint8List> onCaptured;

  /// Optional height constraint for the preview. Defaults to filling available space.
  final double? height;

  /// Whether to show the capture button. Defaults to true.
  final bool showCaptureButton;

  /// Whether to show the gallery button. Defaults to true.
  final bool showGalleryButton;

  const InlineCameraPreview({
    super.key,
    required this.onCaptured,
    this.height,
    this.showCaptureButton = true,
    this.showGalleryButton = true,
  });

  @override
  State<InlineCameraPreview> createState() => _InlineCameraPreviewState();
}

class _InlineCameraPreviewState extends State<InlineCameraPreview> {
  CameraController? _cameraController;
  bool _isInitializing = true;
  bool _hasPermission = false;
  bool _permissionPermanentlyDenied = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (!mounted) return;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      // Check permission status
      final status = await Permission.camera.status;

      if (status.isGranted) {
        await _setupCamera();
        if (mounted) {
          setState(() {
            _hasPermission = true;
            _isInitializing = false;
          });
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            _hasPermission = false;
            _permissionPermanentlyDenied = true;
            _isInitializing = false;
          });
        }
      } else {
        // Permission not yet granted - show in-page UI
        if (mounted) {
          setState(() {
            _hasPermission = false;
            _isInitializing = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to initialize camera: $e';
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _setupCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }

    // Use back camera
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.low,
      enableAudio: false,
    );

    await _cameraController!.initialize();
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();

    if (status.isGranted) {
      await _setupCamera();
      if (mounted) {
        setState(() {
          _hasPermission = true;
          _permissionPermanentlyDenied = false;
        });
      }
    } else if (status.isPermanentlyDenied) {
      if (mounted) {
        setState(() {
          _permissionPermanentlyDenied = true;
        });
      }
    }
  }

  Future<void> _openSettings() async {
    await openAppSettings();
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      final bytes = await photo.readAsBytes();
      widget.onCaptured(bytes);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to capture photo: $e';
        });
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        widget.onCaptured(bytes);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to pick image: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview or permission UI
            _buildContent(theme),

            // Loading overlay
            if (_isInitializing) _buildLoadingOverlay(theme),

            // Error overlay
            if (_errorMessage != null) _buildErrorOverlay(theme),

            // Control buttons (only show when camera is ready)
            if (_hasPermission && !_isInitializing && _errorMessage == null) _buildControlOverlay(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_hasPermission && _cameraController != null && _cameraController!.value.isInitialized) {
      return CameraPreview(_cameraController!);
    }

    if (_permissionPermanentlyDenied) {
      return _buildPermissionPermanentlyDeniedUI(theme);
    }

    if (!_hasPermission && !_isInitializing) {
      return _buildPermissionRequestUI(theme);
    }

    // Default: empty container while initializing
    return Container(color: theme.colorScheme.surfaceContainerHighest);
  }

  Widget _buildPermissionRequestUI(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Camera access is needed to take photos of your plants.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _requestPermission,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Grant access'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _pickFromGallery,
              child: const Text('Use gallery instead'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionPermanentlyDeniedUI(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Camera permission was permanently denied. Please enable it in system settings.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings),
              label: const Text('Open settings'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _pickFromGallery,
              child: const Text('Use gallery instead'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                'Initializing camera...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay(ThemeData theme) {
    return Positioned.fill(
      child: Container(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.9),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: _initializeCamera,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControlOverlay(ThemeData theme) {
    return Positioned(
      bottom: 16,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Gallery button
          if (widget.showGalleryButton) ...[
            _ControlButton(
              icon: Icons.photo_library,
              label: 'Gallery',
              onTap: _pickFromGallery,
            ),
            const SizedBox(width: 24),
          ],

          // Capture button
          if (widget.showCaptureButton)
            _CaptureButton(
              onTap: _capturePhoto,
            ),
        ],
      ),
    );
  }
}

/// Circular capture button with white border.
class _CaptureButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CaptureButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white,
            width: 4,
          ),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Small control button with icon and label.
class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.8),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 24,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
