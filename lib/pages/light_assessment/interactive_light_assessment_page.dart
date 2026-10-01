import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:openplants/core/app_scope.dart';
import 'package:openplants/l10n/l10n_x.dart';
import 'package:openplants/pages/light_assessment/camera_estimation_service.dart';
import 'package:openplants/pages/light_assessment/light_assessment_item_entity.dart';
import 'package:openplants/pages/light_assessment/light_assessment_usecases.dart';
import 'package:openplants/pages/plant_collection/plant_collection_item_entity.dart';

/// A full-screen interactive camera view for real-time light level assessment.
///
/// Displays a live camera viewfinder as the background with overlaid controls:
/// - Real-time light level indicator (updates at ~1–2 FPS)
/// - Capture button to save a photo reference to the plant timeline
/// - "Set this level" button for direct level selection without a photo
/// - Gallery picker for assessment from existing photos
/// - 2-minute camera timeout with warning dialog
class InteractiveLightAssessmentPage extends StatefulWidget {
  /// Plant ID — null in standalone mode.
  final String? plantId;

  /// Plant name — null in standalone mode.
  final String? plantName;

  /// Use-cases for data persistence.
  final LightAssessmentUseCases usecases;

  /// Called with the selected [LightLevel] when the user confirms a level.
  final ValueChanged<LightLevel>? onLightLevelSet;

  /// Optional camera service — used for dependency injection in tests.
  /// Defaults to a fresh [CameraEstimationService] when omitted.
  final CameraEstimationService? cameraService;

  const InteractiveLightAssessmentPage({
    super.key,
    this.plantId,
    this.plantName,
    required this.usecases,
    this.onLightLevelSet,
    this.cameraService,
  });

  @override
  State<InteractiveLightAssessmentPage> createState() => _InteractiveLightAssessmentPageState();
}

class _InteractiveLightAssessmentPageState extends State<InteractiveLightAssessmentPage> {
  // ---- Services ----
  late final CameraEstimationService _cameraService = widget.cameraService ?? CameraEstimationService();
  CameraController? get _cameraController => _cameraService.controller;
  final ImagePicker _imagePicker = ImagePicker();

  // ---- Camera state ----
  bool _hasPermission = false;
  bool _permissionPermanentlyDenied = false;
  bool _initializing = true;
  bool _cameraInitializationFailed = false;

  // ---- Live estimation state ----
  double _currentBrightness = 0;
  LightLevel _currentLevel = LightLevel.medium;
  double _currentConfidence = 0;

  // ---- Capture / result state ----
  bool _capturing = false;
  bool _showCaptureFlash = false;
  CameraEstimationResult? _capturedResult;
  bool _showResult = false;

  // ---- Timer ----
  Timer? _cameraTimer;
  Timer? _autoCloseTimer;
  static const Duration _cameraTimeout = Duration(minutes: 2);
  bool _showTimeoutWarning = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraTimer?.cancel();
    _autoCloseTimer?.cancel();
    _cameraService.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Camera initialisation
  // ---------------------------------------------------------------------------

  Future<void> _initializeCamera() async {
    if (!mounted) return;
    setState(() {
      _initializing = true;
      _cameraInitializationFailed = false;
    });

    var permissionGranted = false;
    try {
      final status = await Permission.camera.status;

      if (status.isGranted) {
        permissionGranted = true;
        await _setupCameraAndStream();
        if (mounted) {
          setState(() {
            _hasPermission = true;
            _initializing = false;
            _cameraInitializationFailed = false;
          });
          _startCameraTimer();
        }
      } else if (status.isPermanentlyDenied) {
        if (mounted) {
          setState(() {
            _permissionPermanentlyDenied = true;
            _initializing = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasPermission = false;
            _initializing = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Failed to initialize light assessment camera: $e');
      if (mounted) {
        setState(() {
          _hasPermission = permissionGranted;
          _initializing = false;
          _cameraInitializationFailed = permissionGranted;
        });
      }
    }
  }

  Future<void> _requestPermission() async {
    var permissionGranted = false;
    setState(() {
      _initializing = true;
      _cameraInitializationFailed = false;
    });
    try {
      final status = await Permission.camera.request();
      if (status.isGranted) {
        permissionGranted = true;
        await _setupCameraAndStream();
        if (mounted) {
          setState(() {
            _hasPermission = true;
            _permissionPermanentlyDenied = false;
            _initializing = false;
          });
          _startCameraTimer();
        }
      } else if (mounted) {
        setState(() {
          _hasPermission = false;
          _permissionPermanentlyDenied = status.isPermanentlyDenied;
          _initializing = false;
        });
      }
    } catch (e) {
      debugPrint('Failed to initialize light assessment camera: $e');
      if (mounted) {
        setState(() {
          _hasPermission = permissionGranted;
          _cameraInitializationFailed = permissionGranted;
          _initializing = false;
        });
      }
    }
  }

  Future<void> _retryCameraInitialization() async {
    if (!mounted) return;
    setState(() {
      _initializing = true;
      _cameraInitializationFailed = false;
    });
    try {
      await _cameraService.dispose();
      await _setupCameraAndStream();
      if (!mounted) return;
      setState(() {
        _hasPermission = true;
        _initializing = false;
        _cameraInitializationFailed = false;
      });
      _startCameraTimer();
    } catch (e) {
      debugPrint('Failed to initialize light assessment camera: $e');
      if (!mounted) return;
      setState(() {
        _hasPermission = true;
        _initializing = false;
        _cameraInitializationFailed = true;
      });
    }
  }

  Future<void> _setupCameraAndStream() async {
    await _cameraService.initialize();

    if (!mounted) return;

    await _cameraService.startFrameStream(
      onFrame: (brightness, level, confidence) {
        if (!mounted) return;
        setState(() {
          _currentBrightness = brightness;
          _currentLevel = level;
          _currentConfidence = confidence;
        });
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Camera timeout
  // ---------------------------------------------------------------------------

  void _startCameraTimer() {
    _cameraTimer?.cancel();
    _cameraTimer = Timer(_cameraTimeout, _onCameraTimeout);
  }

  void _resetCameraTimer() {
    _cameraTimer?.cancel();
    _autoCloseTimer?.cancel();
    _startCameraTimer();
    if (_showTimeoutWarning && mounted) {
      setState(() => _showTimeoutWarning = false);
    }
  }

  void _onCameraTimeout() {
    if (!mounted) return;
    setState(() => _showTimeoutWarning = true);
    // Auto-close after 15 seconds of warning
    _autoCloseTimer?.cancel();
    _autoCloseTimer = Timer(const Duration(seconds: 15), () {
      if (mounted) _closeCamera();
    });
  }

  void _closeCamera() {
    Navigator.of(context).pop();
  }

  // ---------------------------------------------------------------------------
  // Capture
  // ---------------------------------------------------------------------------

  Future<void> _capturePhoto() async {
    if (_capturing) return;

    // Flash animation (Task 4.2)
    setState(() {
      _showCaptureFlash = true;
      _capturing = true;
    });

    // Brief flash feedback
    unawaited(
      Future.delayed(
        const Duration(milliseconds: 200),
        () {
          if (mounted) setState(() => _showCaptureFlash = false);
        },
      ),
    );

    try {
      final result = await _cameraService.estimate();
      if (!mounted) return;

      setState(() {
        _capturedResult = result;
        _capturing = false;
      });

      _resetCameraTimer();
      _showCaptureResult();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _capturing = false;
      });
      debugPrint('Failed to estimate light level: $e');
      _showError();
    }
  }

  void _showCaptureResult() {
    setState(() => _showResult = true);
  }

  Future<void> _acceptCapturedPhoto() async {
    if (_capturedResult == null) return;
    if (!mounted) return;

    try {
      // Take a fresh picture for the plant timeline (the previous one
      // was consumed internally by `estimate()`).
      final controller = _cameraController;
      if (widget.plantId != null && controller != null) {
        final xFile = await controller.takePicture();
        final file = File(xFile.path);
        await widget.usecases.addPhoto(widget.plantId!, file);
      }

      if (!mounted) return;

      // Save directly in plant context, or ask where to save in standalone mode.
      final level = _capturedResult!.level;
      if (widget.plantId != null) {
        await widget.usecases.setLightLevel(widget.plantId!, level);
        widget.onLightLevelSet?.call(level);
      } else if (!await _showPlantSelectionDialogIfNeeded(level)) {
        return;
      }

      if (mounted) {
        if (widget.plantId != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.lightAssessmentLevelSet(_lightLevelLabel(context, level)))),
          );
        }
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Failed to save light level: $e');
      _showError();
    }
  }

  void _dismissCaptureResult() {
    setState(() {
      _showResult = false;
      _capturedResult = null;
    });
    _resetCameraTimer();
  }

  // ---------------------------------------------------------------------------
  // Set this level (direct selection without photo)
  // ---------------------------------------------------------------------------

  Future<void> _setCurrentLevel() async {
    if (!_cameraService.isControllerInitialized) {
      _showError();
      return;
    }
    if (widget.plantId == null) {
      // Standalone mode — prompt to select a plant (Task 3.5)
      try {
        final saved = await _showPlantSelectionDialogIfNeeded(_currentLevel);
        if (saved && mounted) Navigator.of(context).pop();
      } catch (e) {
        if (mounted) {
          debugPrint('Failed to set light level: $e');
          _showError();
        }
      }
      return;
    }

    try {
      await widget.usecases.setLightLevel(widget.plantId!, _currentLevel);
      widget.onLightLevelSet?.call(_currentLevel);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.lightAssessmentLevelSet(_lightLevelLabel(context, _currentLevel))),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint('Failed to set level: $e');
      _showError();
    }
  }

  // ---------------------------------------------------------------------------
  // Plant selection dialog (standalone mode — Task 3.5)
  // ---------------------------------------------------------------------------

  /// Shows a plant selection dialog so the user can save the assessed light
  /// level to a specific plant. Returns `true` if a plant was selected and the
  /// level was saved.
  Future<bool> _showPlantSelectionDialogIfNeeded(LightLevel level) async {
    if (!mounted) return false;

    final services = AppScope.of(context).services;
    final plants = await services.plantCollection.loadPlants();

    if (!mounted) return false;

    if (plants.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.lightAssessmentNoPlants)),
      );
      return false;
    }

    if (plants.length == 1) {
      // Only one plant — save directly
      await services.lightAssessment.setLightLevel(plants.first.id, level);
      widget.onLightLevelSet?.call(level);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.lightAssessmentPlantLevelSet(plants.first.name, _lightLevelLabel(context, level)),
            ),
          ),
        );
      }
      return true;
    }

    // Multiple plants — show picker
    final plant = await showModalBottomSheet<PlantEntity>(
      context: context,
      builder: (ctx) {
        final sheetTheme = Theme.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  context.l10n.lightAssessmentSaveToPlant,
                  style: sheetTheme.textTheme.titleMedium,
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 300),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: plants.length,
                  itemBuilder: (ctx, index) {
                    final plant = plants[index];
                    return ListTile(
                      leading: plant.photoPath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(plant.photoPath!),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : const Icon(Icons.yard),
                      title: Text(plant.name),
                      subtitle: Text(context.l10n.lightAssessmentSetToLevel(_lightLevelLabel(context, level))),
                      onTap: () => Navigator.of(ctx).pop(plant),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (plant != null && mounted) {
      await services.lightAssessment.setLightLevel(plant.id, level);
      widget.onLightLevelSet?.call(level);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.lightAssessmentPlantLevelSet(plant.name, _lightLevelLabel(context, level))),
          ),
        );
      }
      return true;
    }

    return false;
  }

  void _showError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.generalFailureMessage)),
    );
  }

  // ---------------------------------------------------------------------------
  // Gallery
  // ---------------------------------------------------------------------------

  Future<void> _pickFromGallery() async {
    try {
      final xFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (xFile == null || !mounted) return;

      final file = File(xFile.path);
      final result = await _cameraService.estimateFromFile(file);
      if (!mounted) return;

      setState(() {
        _capturedResult = result;
      });

      // In plant context, also save the photo
      if (widget.plantId != null && mounted) {
        await widget.usecases.addPhoto(widget.plantId!, file);
      }

      _showCaptureResult();
    } catch (e) {
      if (!mounted) return;
      debugPrint('Failed to pick photo: $e');
      _showError();
    }
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: _buildBody(theme),
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (_initializing) {
      return _buildLoadingState(theme);
    }

    if (_cameraInitializationFailed) {
      return _buildCameraUnavailableState(theme);
    }

    if (_permissionPermanentlyDenied) {
      return _buildPermissionDeniedState(theme);
    }

    if (!_hasPermission) {
      return _buildPermissionRequestState(theme);
    }

    if (_showResult && _capturedResult != null) {
      return _buildResultView(theme);
    }

    return _buildCameraView(theme);
  }

  // ---------------------------------------------------------------------------
  // Loading state
  // ---------------------------------------------------------------------------

  Widget _buildLoadingState(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surface,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              context.l10n.cameraInitializing,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraUnavailableState(ThemeData theme) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.videocam_off, size: 64, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                context.l10n.cameraInitializationFailed,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _retryCameraInitialization,
                child: Text(context.l10n.plantIdTryAgain),
              ),
              TextButton.icon(
                onPressed: _pickFromGallery,
                icon: const Icon(Icons.photo_library),
                label: Text(context.l10n.cameraUseGalleryInstead),
              ),
              TextButton(onPressed: _closeCamera, child: Text(context.l10n.back)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Permission states
  // ---------------------------------------------------------------------------

  Widget _buildPermissionRequestState(ThemeData theme) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.camera_alt, size: 72, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
              const SizedBox(height: 24),
              Text(
                context.l10n.lightAssessmentCameraPermissionNeeded,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.camera_alt),
                label: Text(context.l10n.cameraGrantAccess),
              ),
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _pickFromGallery,
                icon: Icon(Icons.photo_library, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                label: Text(
                  context.l10n.cameraUseGalleryInstead,
                  style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _closeCamera,
                child: Text(context.l10n.cancel),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedState(ThemeData theme) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.block, size: 72, color: theme.colorScheme.error),
              const SizedBox(height: 24),
              Text(
                context.l10n.cameraPermissionPermanentlyDenied,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: openAppSettings,
                icon: const Icon(Icons.settings),
                label: Text(context.l10n.cameraOpenSettings),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _closeCamera,
                child: Text(context.l10n.back),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Full-screen camera view with overlays (Tasks 1.1–1.7, 4.1, 4.4, 4.5)
  // ---------------------------------------------------------------------------

  Widget _buildCameraView(ThemeData theme) {
    final cameraController = _cameraController;
    final lightItem = LightAssessmentItem.findByLevel(_currentLevel);

    // Matches plant identification page layout:
    //   SafeArea(bottom: false) > Column > [title bar, Expanded(Stack)]
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top bar — matches plant ID page layout
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.plantName != null
                        ? context.l10n.lightAssessmentPageTitle(widget.plantName!)
                        : context.l10n.moreLightAssessmentTitle,
                    style: theme.textTheme.displayMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _closeCamera,
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Camera area — rounded corners matching plant ID page
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Live camera preview
                    if (cameraController != null && _cameraService.isControllerInitialized)
                      CameraPreview(cameraController)
                    else
                      Container(color: theme.colorScheme.surfaceContainerHighest),

                    // Semi-transparent overlay gradient
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black54,
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black38,
                          ],
                          stops: [0.0, 0.15, 0.7, 1.0],
                        ),
                      ),
                    ),

                    // === Light level indicator overlay (Tasks 1.3, 4.1) ===
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: _buildLightLevelIndicator(theme, lightItem),
                    ),

                    // === Guidance text (Task 4.4) ===
                    Positioned(
                      top: 130,
                      left: 16,
                      right: 16,
                      child: _buildGuidanceText(theme),
                    ),

                    // === Bottom controls (Tasks 1.4, 1.5) ===
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 32,
                      child: _buildBottomControls(theme),
                    ),

                    // === Capture flash overlay (Task 4.2) ===
                    if (_showCaptureFlash)
                      Positioned.fill(
                        child: AnimatedOpacity(
                          opacity: _showCaptureFlash ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(color: Colors.white),
                        ),
                      ),

                    // === Timeout warning dialog (Task 1.6) ===
                    if (_showTimeoutWarning)
                      Positioned.fill(
                        child: _buildTimeoutOverlay(theme),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Light level indicator overlay (Tasks 1.3, 4.1)
  // ---------------------------------------------------------------------------

  Widget _buildLightLevelIndicator(ThemeData theme, LightAssessmentItem? lightItem) {
    final levelColor = _levelColor(_currentLevel);
    final brightnessPercent = (_currentBrightness * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.black54,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Level label + icon
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  lightItem?.icon ?? Icons.wb_sunny,
                  color: levelColor,
                  size: 28,
                ),
                const SizedBox(width: 10),
                Text(
                  _lightLevelLabel(context, _currentLevel),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: levelColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Brightness bar
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: Container(
                height: 6,
                width: double.infinity,
                color: Colors.white24,
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _currentBrightness.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      color: levelColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  context.l10n.lightAssessmentBrightness(brightnessPercent),
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
                ),
                // Confidence (Task 4.5)
                Text(
                  context.l10n.lightAssessmentConfidence((_currentConfidence * 100).round()),
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _levelColor(LightLevel level) {
    return switch (level) {
      LightLevel.low => Colors.blue,
      LightLevel.medium => Colors.orange,
      LightLevel.brightIndirect => Colors.amber,
      LightLevel.direct => Colors.red,
    };
  }

  String _lightLevelLabel(BuildContext context, LightLevel level) {
    return switch (level) {
      LightLevel.low => context.l10n.speciesLibraryLightLow,
      LightLevel.medium => context.l10n.speciesLibraryLightMedium,
      LightLevel.brightIndirect => context.l10n.speciesLibraryLightBright,
      LightLevel.direct => context.l10n.speciesLibraryLightDirect,
    };
  }

  String _estimateDescription(BuildContext context, LightLevel level) {
    return switch (level) {
      LightLevel.low => context.l10n.lightAssessmentEstimateLow,
      LightLevel.medium => context.l10n.lightAssessmentEstimateMedium,
      LightLevel.brightIndirect => context.l10n.lightAssessmentEstimateBright,
      LightLevel.direct => context.l10n.lightAssessmentEstimateDirect,
    };
  }

  // ---------------------------------------------------------------------------
  // Guidance text (Task 4.4)
  // ---------------------------------------------------------------------------

  Widget _buildGuidanceText(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        context.l10n.lightAssessmentLiveGuidance,
        style: theme.textTheme.bodySmall?.copyWith(
          color: Colors.white54,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Timeout overlay (Task 1.6)
  // ---------------------------------------------------------------------------

  Widget _buildTimeoutOverlay(ThemeData theme) {
    return Container(
      color: Colors.black87,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timer_off, size: 64, color: Colors.white54),
              const SizedBox(height: 24),
              Text(
                context.l10n.lightAssessmentCameraTimedOut,
                style: theme.textTheme.headlineSmall?.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.lightAssessmentCameraTimeoutDescription,
                style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: _resetCameraTimer,
                child: Text(context.l10n.lightAssessmentContinueAssessing),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _closeCamera,
                child: Text(MaterialLocalizations.of(context).closeButtonTooltip),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom controls (Tasks 1.4, 1.5)
  // ---------------------------------------------------------------------------

  Widget _buildBottomControls(ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // "Set this level" button (Task 1.5)
        Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: ElevatedButton.icon(
            onPressed: _setCurrentLevel,
            icon: const Icon(Icons.check, size: 20),
            label: Text(context.l10n.lightAssessmentSetThisLevel(_lightLevelLabel(context, _currentLevel))),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
              ),
            ),
          ),
        ),

        // Gallery + Capture buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gallery button
            _SmallControlButton(
              icon: Icons.photo_library,
              label: context.l10n.plantIdGallery,
              onTap: _pickFromGallery,
            ),
            const SizedBox(width: 40),

            // Capture button (Task 1.4)
            GestureDetector(
              key: const Key('capture_button'),
              onTap: _capturing ? null : _capturePhoto,
              child: Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                ),
                child: Center(
                  child: _capturing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(width: 40),

            // Spacer to balance layout
            const SizedBox(width: 48),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Result view (Task 2.4 — unified assessment result)
  // ---------------------------------------------------------------------------

  Widget _buildResultView(ThemeData theme) {
    final result = _capturedResult!;
    final lightItem = LightAssessmentItem.findByLevel(result.level);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        title: Text(context.l10n.lightAssessmentResultTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _dismissCaptureResult,
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Result card (matches plant-id card styling)
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Level icon
                    Icon(
                      lightItem?.icon ?? Icons.wb_sunny,
                      size: 80,
                      color: _levelColor(result.level),
                    ),
                    const SizedBox(height: 16),

                    // Level label
                    Text(
                      _lightLevelLabel(context, result.level),
                      style: theme.textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    // Description
                    const SizedBox(height: 8),
                    Text(
                      _estimateDescription(context, result.level),
                      style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white60),
                      textAlign: TextAlign.center,
                    ),

                    // Brightness
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.lightAssessmentBrightness((result.brightness * 100).round()),
                      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white38),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Guidance info
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white54, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        context.l10n.lightAssessmentResultGuidance,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Accept / Dismiss buttons
              FilledButton.icon(
                onPressed: widget.plantId != null ? _acceptCapturedPhoto : _acceptStandalone,
                icon: const Icon(Icons.check_circle),
                label: Text(context.l10n.lightAssessmentAcceptAndSave),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _dismissCaptureResult,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.lightAssessmentTakeNewPhoto),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white38),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _acceptStandalone() async {
    if (_capturedResult == null) return;
    try {
      final saved = await _showPlantSelectionDialogIfNeeded(_capturedResult!.level);
      if (saved && mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      debugPrint('Failed to save light assessment: $e');
      _showError();
    }
  }
}

/// Small circular control button used in the bottom control bar.
class _SmallControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SmallControlButton({
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
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
