import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import 'package:open_plant/pages/lightAssessment/brightness_mapper.dart';
import 'package:open_plant/pages/lightAssessment/camera_estimation_service.dart';
import 'package:open_plant/pages/lightAssessment/light_assessment_item_entity.dart';
import 'package:open_plant/pages/lightAssessment/light_assessment_usecases.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_photo_timeline/plant_photo_timeline_item_entity.dart';
import 'package:open_plant/shared/widgets/inline_camera_preview.dart';

/// Page for assessing and setting a plant's light level.
///
/// Estimates light from the plant's most recent photo. If no photo exists,
/// prompts the user to take one (which is also saved to the plant's timeline).
class LightAssessmentPage extends StatefulWidget {
  final String plantId;
  final String plantName;
  final LightAssessmentUseCases usecases;

  const LightAssessmentPage({
    super.key,
    required this.plantId,
    required this.plantName,
    required this.usecases,
  });

  @override
  State<LightAssessmentPage> createState() => _LightAssessmentPageState();
}

class _LightAssessmentPageState extends State<LightAssessmentPage> {
  LightLevel? _currentLevel;
  bool _loading = true;
  PlantPhoto? _latestPhoto;
  bool _hasPhoto = false;

  LightLevel? _estimatedLevel;
  double? _estimatedBrightness;
  bool _estimating = false;
  String? _estimationError;

  bool _showCamera = false;

  final CameraEstimationService _cameraService = CameraEstimationService();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _cameraService.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final level = await widget.usecases.getLightLevel(widget.plantId);
    final photo = await widget.usecases.getLatestPhoto(widget.plantId);
    if (!mounted) return;
    setState(() {
      _currentLevel = level;
      _latestPhoto = photo;
      _hasPhoto = photo != null;
      _loading = false;
    });

    // Auto-analyze if photo exists
    if (photo != null) {
      unawaited(_analyzePhoto(File(photo.filePath)));
    }
  }

  Future<void> _selectLevel(LightLevel level) async {
    await widget.usecases.setLightLevel(widget.plantId, level);
    if (!mounted) return;
    setState(() => _currentLevel = level);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Light level set to ${level.label}')),
      );
    }
  }

  Future<void> _clearLevel() async {
    await widget.usecases.clearLightLevel(widget.plantId);
    if (!mounted) return;
    setState(() => _currentLevel = null);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Light level cleared')),
      );
    }
  }

  void _acceptEstimate() {
    if (_estimatedLevel != null) {
      _selectLevel(_estimatedLevel!);
      setState(() {
        _estimatedLevel = null;
        _estimatedBrightness = null;
      });
    }
  }

  void _dismissEstimate() {
    setState(() {
      _estimatedLevel = null;
      _estimatedBrightness = null;
    });
  }

  /// Analyze a photo file for brightness.
  Future<void> _analyzePhoto(File photoFile) async {
    if (!mounted) return;
    setState(() {
      _estimating = true;
      _estimationError = null;
      _estimatedLevel = null;
      _estimatedBrightness = null;
    });

    try {
      final result = await _cameraService.estimateFromFile(photoFile);
      if (!mounted) return;
      setState(() {
        _estimating = false;
        _estimatedLevel = result.level;
        _estimatedBrightness = result.brightness;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _estimating = false;
        _estimationError = 'Failed to analyze photo: $e';
      });
    }
  }

  /// Handle photo captured from inline camera or gallery.
  Future<void> _onCaptured(Uint8List imageBytes) async {
    if (!mounted) return;

    setState(() {
      _showCamera = false;
      _estimating = true;
      _estimationError = null;
      _estimatedLevel = null;
      _estimatedBrightness = null;
    });

    try {
      // Save bytes to a temporary file
      final dir = await getTemporaryDirectory();
      final photoPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(photoPath);
      await file.writeAsBytes(imageBytes);

      // Save photo to plant timeline
      final photo = await widget.usecases.addPhoto(widget.plantId, file);
      if (!mounted) return;
      setState(() {
        _latestPhoto = photo;
        _hasPhoto = true;
      });

      // Analyze the new photo
      await _analyzePhoto(file);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _estimating = false;
        _estimationError = 'Failed to process photo: $e';
      });
    }
  }

  /// Pick a photo from gallery, save it to timeline, and analyze it.
  Future<void> _pickPhotoAndEstimate() async {
    if (!mounted) return;
    setState(() {
      _estimating = true;
      _estimationError = null;
      _estimatedLevel = null;
      _estimatedBrightness = null;
    });

    try {
      final xFile = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (xFile == null || !mounted) {
        setState(() => _estimating = false);
        return;
      }

      final file = File(xFile.path);

      // Save photo to plant timeline
      final photo = await widget.usecases.addPhoto(widget.plantId, file);
      if (!mounted) return;
      setState(() {
        _latestPhoto = photo;
        _hasPhoto = true;
      });

      // Analyze the new photo
      await _analyzePhoto(file);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _estimating = false;
        _estimationError = 'Failed to pick photo: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Light Assessment — ${widget.plantName}'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Current status
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.light_mode,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Current Light Level',
                                style: theme.textTheme.labelMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _currentLevel?.label ?? 'Not set',
                                style: theme.textTheme.titleMedium,
                              ),
                            ],
                          ),
                        ),
                        if (_currentLevel != null)
                          TextButton(
                            onPressed: _clearLevel,
                            child: const Text('Clear'),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Light level options
                Text(
                  'Select Light Level',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 12),

                ...LightAssessmentItem.options.map((option) {
                  final isSelected = _currentLevel == option.level;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Card(
                      color: isSelected ? theme.colorScheme.primaryContainer : null,
                      child: ListTile(
                        leading: Icon(
                          option.icon,
                          color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
                        ),
                        title: Text(
                          option.label,
                          style: TextStyle(
                            fontWeight: isSelected ? FontWeight.bold : null,
                          ),
                        ),
                        subtitle: Text(option.description),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_circle,
                                color: theme.colorScheme.onPrimaryContainer,
                              )
                            : null,
                        onTap: () => _selectLevel(option.level),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 24),

                // Photo-based estimation section
                Card(
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.photo_camera,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Estimate from Photo',
                              style: theme.textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Info message
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Light level is estimated from your plant's photo. "
                                  'For best results, use a photo that shows the plant '
                                  'in its usual spot.',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Error message
                        if (_estimationError != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _estimationError!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onErrorContainer,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Photo preview (if available)
                        if (_latestPhoto != null && !_estimating) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              File(_latestPhoto!.filePath),
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Estimation result
                        if (_estimatedLevel != null) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  BrightnessMapper.describeEstimate(_estimatedLevel!),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onPrimaryContainer,
                                  ),
                                ),
                                if (_estimatedBrightness != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Brightness: ${(_estimatedBrightness! * 100).round()}%',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    FilledButton(
                                      onPressed: _acceptEstimate,
                                      child: const Text('Use this'),
                                    ),
                                    const SizedBox(width: 8),
                                    OutlinedButton(
                                      onPressed: _dismissEstimate,
                                      child: const Text('Dismiss'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],

                        // Action buttons
                        if (_estimating) ...[
                          const SizedBox(height: 8),
                          const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ] else if (_showCamera) ...[
                          // Show inline camera preview
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 300,
                            child: InlineCameraPreview(
                              onCaptured: _onCaptured,
                            ),
                          ),
                        ] else if (_hasPhoto) ...[
                          // Has photo: show retake options
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => setState(() => _showCamera = true),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Take new photo'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickPhotoAndEstimate,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Choose from gallery'),
                            ),
                          ),
                        ] else ...[
                          // No photo: prompt to take one
                          Text(
                            'No photo yet. Take a photo of your plant to estimate '
                            'its light level.',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: FilledButton.icon(
                              onPressed: () => setState(() => _showCamera = true),
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Take photo'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _pickPhotoAndEstimate,
                              icon: const Icon(Icons.photo_library),
                              label: const Text('Choose from gallery'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
