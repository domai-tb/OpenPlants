import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openplants/l10n/l10n_x.dart';

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
///   onCaptured: (Uint8List bytes) async {
///     // Handle captured image bytes
///   },
/// )
/// ```
class InlineCameraPreview extends StatefulWidget {
  /// Callback invoked when a photo is captured or selected from gallery.
  final Future<void> Function(Uint8List) onCaptured;

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
    final controller = _cameraController;
    if (controller != null) {
      unawaited(
        controller.dispose().catchError(
              (Object error) => debugPrint('Failed to dispose camera controller: $error'),
            ),
      );
    }
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
      if (!mounted) return;

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
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = context.l10n.cameraInitializationFailed;
          _isInitializing = false;
        });
      }
    }
  }

  Future<void> _setupCamera() async {
    final previousController = _cameraController;
    _cameraController = null;
    if (previousController != null) await previousController.dispose();

    final cameras = await availableCameras();
    if (!mounted) return;
    if (cameras.isEmpty) {
      throw Exception('No cameras available');
    }

    // Use back camera
    final backCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    final controller = CameraController(
      backCamera,
      ResolutionPreset.low,
      enableAudio: false,
    );
    _cameraController = controller;
    try {
      await controller.initialize();
    } catch (_) {
      if (identical(_cameraController, controller)) _cameraController = null;
      await controller.dispose();
      rethrow;
    }
  }

  Future<void> _requestPermission() async {
    if (!mounted || _isInitializing) return;
    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      final status = await Permission.camera.request();
      if (!mounted) return;

      if (status.isGranted) {
        await _setupCamera();
        if (!mounted) return;
        setState(() {
          _hasPermission = true;
          _permissionPermanentlyDenied = false;
          _isInitializing = false;
        });
      } else {
        setState(() {
          _hasPermission = false;
          _permissionPermanentlyDenied = status.isPermanentlyDenied;
          _isInitializing = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = context.l10n.cameraInitializationFailed;
          _isInitializing = false;
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
      if (mounted) await widget.onCaptured(bytes);
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = context.l10n.plantIdFailedToCapture;
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
        if (mounted) await widget.onCaptured(bytes);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _errorMessage = context.l10n.plantIdFailedToPick;
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
              context.l10n.cameraAccessNeeded,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _requestPermission,
              icon: const Icon(Icons.camera_alt),
              label: Text(context.l10n.cameraGrantAccess),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _pickFromGallery,
              child: Text(context.l10n.cameraUseGalleryInstead),
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
              context.l10n.cameraPermissionPermanentlyDenied,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _openSettings,
              icon: const Icon(Icons.settings),
              label: Text(context.l10n.cameraOpenSettings),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _pickFromGallery,
              child: Text(context.l10n.cameraUseGalleryInstead),
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
                context.l10n.cameraInitializing,
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
                  child: Text(context.l10n.plantIdTryAgain),
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
              label: context.l10n.plantIdGallery,
              onTap: _pickFromGallery,
            ),
            const SizedBox(width: 24),
          ],

          // Capture button
          if (widget.showCaptureButton)
            _CaptureButton(
              label: context.l10n.cameraCapturePhoto,
              onTap: _capturePhoto,
            ),
        ],
      ),
    );
  }
}

/// Circular capture button with white border.
class _CaptureButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _CaptureButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
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

    return Semantics(
      button: true,
      label: label,
      onTap: onTap,
      child: ExcludeSemantics(
        child: GestureDetector(
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
        ),
      ),
    );
  }
}
