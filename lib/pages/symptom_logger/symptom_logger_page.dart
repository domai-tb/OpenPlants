import 'dart:async' show unawaited;
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_extensions.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_item_entity.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_usecases.dart';
import 'package:open_plant/widgets/inline_camera_preview.dart';

/// Multi-step symptom logging form for recording plant health issues.
class SymptomLoggerPage extends StatefulWidget {
  /// The plant ID to associate this symptom entry with.
  final String plantId;

  /// Optional plant name for display purposes.
  final String? plantName;

  /// Existing symptom entry to edit instead of creating a new one.
  final SymptomLogEntry? entry;

  const SymptomLoggerPage({
    super.key,
    required this.plantId,
    this.plantName,
    this.entry,
  });

  @override
  State<SymptomLoggerPage> createState() => _SymptomLoggerPageState();
}

/// Form data collected across all steps.
class _SymptomFormData {
  Set<PlantSymptom> symptomTypes = {};
  Severity? severity;
  Set<AffectedPart> affectedParts = {};
  OnsetTiming? onsetTiming;
  SoilMoisture? soilMoisture;
  LightCondition? lightCondition;
  String notes = '';
  String? photoPath;
}

class _SymptomLoggerPageState extends State<SymptomLoggerPage> {
  late SymptomLoggerUseCases _usecases;
  bool _wired = false;
  bool _loaded = false;

  final _formData = _SymptomFormData();
  final _pageController = PageController();
  int _currentStep = 0;
  static const int _totalSteps = 7;

  bool _showCamera = false;
  bool _submitting = false;

  /// Controller for the notes field; kept as a field to avoid recreating it
  /// on every build and losing cursor position.
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.symptomLogger;
    _wired = true;
    if (widget.entry != null) {
      _loadEntry(widget.entry!);
    } else {
      _resumeDraft();
    }
  }

  void _loadEntry(SymptomLogEntry entry) {
    _formData.symptomTypes = entry.symptomTypes.toSet();
    _formData.severity = entry.severity;
    _formData.affectedParts = entry.affectedParts.toSet();
    _formData.onsetTiming = entry.onsetTiming;
    _formData.soilMoisture = entry.soilMoisture;
    _formData.lightCondition = entry.lightConditions;
    _formData.notes = entry.notes ?? '';
    _formData.photoPath = entry.photoPath;
    _notesController.text = _formData.notes;
    _loaded = true;
  }

  Future<void> _resumeDraft() async {
    final draft = await _usecases.getDraft(widget.plantId);
    if (draft != null && mounted) {
      setState(() {
        if (draft['symptomTypes'] != null) {
          _formData.symptomTypes = (draft['symptomTypes'] as List<dynamic>)
              .map((e) => PlantSymptom.values.firstWhere((s) => s.name == e as String))
              .toSet();
        }
        if (draft['severity'] != null) {
          _formData.severity = Severity.values.firstWhere(
            (s) => s.name == draft['severity'] as String,
          );
        }
        if (draft['affectedParts'] != null) {
          _formData.affectedParts = (draft['affectedParts'] as List<dynamic>)
              .map((e) => AffectedPart.values.firstWhere((a) => a.name == e as String))
              .toSet();
        }
        if (draft['onsetTiming'] != null) {
          _formData.onsetTiming = OnsetTiming.values.firstWhere(
            (o) => o.name == draft['onsetTiming'] as String,
          );
        }
        if (draft['soilMoisture'] != null) {
          _formData.soilMoisture = SoilMoisture.values.firstWhere(
            (s) => s.name == draft['soilMoisture'] as String,
          );
        }
        if (draft['lightCondition'] != null) {
          _formData.lightCondition = LightCondition.values.firstWhere(
            (l) => l.name == draft['lightCondition'] as String,
          );
        }
        _formData.notes = draft['notes'] as String? ?? '';
        _formData.photoPath = draft['photoPath'] as String?;
        _notesController.text = _formData.notes;
        _loaded = true;
      });
    } else {
      setState(() => _loaded = true);
    }
  }

  Future<void> _autoSaveDraft() async {
    final draft = <String, dynamic>{
      'symptomTypes': _formData.symptomTypes.map((e) => e.name).toList(),
      if (_formData.severity != null) 'severity': _formData.severity!.name,
      'affectedParts': _formData.affectedParts.map((e) => e.name).toList(),
      if (_formData.onsetTiming != null) 'onsetTiming': _formData.onsetTiming!.name,
      if (_formData.soilMoisture != null) 'soilMoisture': _formData.soilMoisture!.name,
      if (_formData.lightCondition != null) 'lightCondition': _formData.lightCondition!.name,
      'notes': _formData.notes,
      if (_formData.photoPath != null) 'photoPath': _formData.photoPath,
    };
    await _usecases.saveDraft(widget.plantId, draft);
  }

  Future<void> _onCaptured(Uint8List imageBytes) async {
    if (!mounted) return;

    setState(() => _showCamera = false);

    // Save photo to app documents
    final dir = await getApplicationDocumentsDirectory();
    final photoDir = Directory('${dir.path}/symptom_photos');
    if (!photoDir.existsSync()) {
      await photoDir.create(recursive: true);
    }
    final photoPath = '${photoDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(photoPath);
    await file.writeAsBytes(imageBytes);

    if (mounted) {
      setState(() => _formData.photoPath = photoPath);
    }
  }

  bool _canProceedFromStep(int step) {
    switch (step) {
      case 0:
        return _formData.symptomTypes.isNotEmpty;
      case 1:
        return _formData.severity != null;
      case 2:
        return _formData.affectedParts.isNotEmpty;
      case 3:
        return _formData.onsetTiming != null;
      case 4:
      case 5:
        return true; // Optional fields
      case 6:
        return true; // Review — always proceed to submit
      default:
        return true;
    }
  }

  Future<void> _goNext() async {
    if (!_canProceedFromStep(_currentStep)) {
      _showValidationError();
      return;
    }
    // Sync notes from controller before saving draft
    _formData.notes = _notesController.text;
    await _autoSaveDraft();
    if (!mounted) return;
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _goBack() async {
    _formData.notes = _notesController.text;
    await _autoSaveDraft();
    if (!mounted) return;
    await _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _showValidationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.symptomLoggerSelectRequired)),
    );
  }

  Future<void> _submit() async {
    if (_submitting) return;
    if (!_canProceedFromStep(0) ||
        _formData.severity == null ||
        _formData.affectedParts.isEmpty ||
        _formData.onsetTiming == null) {
      _showValidationError();
      return;
    }

    _submitting = true;
    try {
      // Sync notes from controller
      _formData.notes = _notesController.text;

      final entry = SymptomLogEntry(
        id: widget.entry?.id ?? '', // Repository assigns a UUID for new entries.
        plantId: widget.plantId,
        symptomTypes: _formData.symptomTypes.toList(),
        severity: _formData.severity!,
        affectedParts: _formData.affectedParts.toList(),
        onsetTiming: _formData.onsetTiming!,
        soilMoisture: _formData.soilMoisture,
        lightConditions: _formData.lightCondition,
        notes: _formData.notes.isNotEmpty ? _formData.notes : null,
        photoPath: _formData.photoPath,
        createdAt: widget.entry?.createdAt ?? DateTime.now(),
        resolved: widget.entry?.resolved ?? false,
        resolvedAt: widget.entry?.resolvedAt,
        diagnosisResultId: widget.entry?.diagnosisResultId,
      );

      if (widget.entry == null) {
        await _usecases.logSymptom(entry);
        await _usecases.deleteDraft(widget.plantId);
      } else {
        await _usecases.updateSymptom(entry);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.symptomLoggerSaved)),
      );
      Navigator.of(context).pop();
    } finally {
      _submitting = false;
    }
  }

  void _onStepChanged(int page) {
    setState(() => _currentStep = page);
  }

  @override
  void dispose() {
    _notesController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return Scaffold(
        appBar: AppBar(title: Text(context.l10n.symptomLoggerTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.symptomLoggerTitle),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (widget.entry != null) {
              Navigator.of(context).pop();
              return;
            }
            _formData.notes = _notesController.text;
            final navigator = Navigator.of(context);
            unawaited(
              _autoSaveDraft().then((_) {
                if (mounted) navigator.pop();
              }),
            );
          },
        ),
      ),
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;
          if (widget.entry != null) {
            Navigator.of(context).pop();
            return;
          }
          _formData.notes = _notesController.text;
          final navigator = Navigator.of(context);
          await _autoSaveDraft();
          if (mounted) navigator.pop();
        },
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: _onStepChanged,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildSymptomTypeStep(),
                  _buildSeverityStep(),
                  _buildAffectedPartsStep(),
                  _buildOnsetTimingStep(),
                  _buildEnvironmentStep(),
                  _buildNotesAndPhotoStep(),
                  _buildReviewStep(),
                ],
              ),
            ),
            _buildNavigationBar(),
          ],
        ),
      ),
    );
  }

  // --- Progress Indicator ---

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${context.l10n.symptomLoggerStep} ${_currentStep + 1}/$_totalSteps',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const Spacer(),
              Text(
                _stepTitle(_currentStep),
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (_currentStep + 1) / _totalSteps,
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(int step) {
    switch (step) {
      case 0:
        return context.l10n.symptomLoggerStepSymptoms;
      case 1:
        return context.l10n.symptomLoggerStepSeverity;
      case 2:
        return context.l10n.symptomLoggerStepParts;
      case 3:
        return context.l10n.symptomLoggerStepOnset;
      case 4:
        return context.l10n.symptomLoggerStepEnvironment;
      case 5:
        return context.l10n.symptomLoggerStepNotes;
      case 6:
        return context.l10n.symptomLoggerStepReview;
      default:
        return '';
    }
  }

  // --- Step 1: Symptom Type Selection ---

  Widget _buildSymptomTypeStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.symptomLoggerSelectSymptoms,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: PlantSymptom.values.map((type) {
              final selected = _formData.symptomTypes.contains(type);
              return FilterChip(
                selected: selected,
                avatar: Icon(type.icon, size: 18),
                label: Text(type.label(context)),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _formData.symptomTypes.add(type);
                    } else {
                      _formData.symptomTypes.remove(type);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Step 2: Severity ---

  Widget _buildSeverityStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.symptomLoggerSelectSeverity,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ...Severity.values.map((severity) {
            final selected = _formData.severity == severity;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: selected ? theme.colorScheme.primaryContainer : theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _formData.severity = severity),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          severity.icon,
                          color: severity.color,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                severity.label(context),
                                style: theme.textTheme.titleSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                severity.description(context),
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        if (selected)
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Step 3: Affected Parts ---

  Widget _buildAffectedPartsStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.symptomLoggerSelectParts,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AffectedPart.values.map((part) {
              final selected = _formData.affectedParts.contains(part);
              return FilterChip(
                selected: selected,
                avatar: Icon(part.icon, size: 18),
                label: Text(part.label(context)),
                onSelected: (value) {
                  setState(() {
                    if (value) {
                      _formData.affectedParts.add(part);
                    } else {
                      _formData.affectedParts.remove(part);
                    }
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Step 4: Onset Timing ---

  Widget _buildOnsetTimingStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.symptomLoggerSelectOnset,
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          ...OnsetTiming.values.map((timing) {
            final selected = _formData.onsetTiming == timing;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: selected ? theme.colorScheme.primaryContainer : theme.cardColor,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => setState(() => _formData.onsetTiming = timing),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(timing.icon),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            timing.label(context),
                            style: theme.textTheme.titleSmall,
                          ),
                        ),
                        if (selected)
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // --- Step 5: Environment (Soil Moisture + Light) ---

  Widget _buildEnvironmentStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Soil Moisture
          Text(
            context.l10n.symptomLoggerSoilMoisture,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: SoilMoisture.values.map((moisture) {
              final selected = _formData.soilMoisture == moisture;
              return ChoiceChip(
                selected: selected,
                label: Text(moisture.label(context)),
                onSelected: (value) {
                  setState(() {
                    _formData.soilMoisture = value ? moisture : null;
                  });
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Light Condition
          Text(
            context.l10n.symptomLoggerLightCondition,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: LightCondition.values.map((light) {
              final selected = _formData.lightCondition == light;
              return ChoiceChip(
                selected: selected,
                label: Text(light.label(context)),
                onSelected: (value) {
                  setState(() {
                    _formData.lightCondition = value ? light : null;
                  });
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // --- Step 6: Notes & Photo ---

  Widget _buildNotesAndPhotoStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.symptomLoggerNotesLabel,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          TextField(
            maxLength: 500,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: context.l10n.symptomLoggerNotesHint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            controller: _notesController,
          ),
          const SizedBox(height: 24),
          Text(
            context.l10n.symptomLoggerPhotoLabel,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          if (_showCamera) ...[
            // Show inline camera preview
            SizedBox(
              height: 300,
              child: InlineCameraPreview(
                onCaptured: _onCaptured,
              ),
            ),
          ] else if (_formData.photoPath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_formData.photoPath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () => setState(() => _formData.photoPath = null),
              icon: const Icon(Icons.delete),
              label: Text(context.l10n.symptomLoggerRemovePhoto),
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: () => setState(() => _showCamera = true),
              icon: const Icon(Icons.camera_alt),
              label: Text(context.l10n.symptomLoggerAddPhoto),
            ),
          ],
        ],
      ),
    );
  }

  // --- Step 7: Review ---

  Widget _buildReviewStep() {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.symptomLoggerReviewTitle,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 16),

          // Symptoms
          _buildReviewSection(
            theme,
            icon: Icons.healing,
            title: context.l10n.symptomLoggerStepSymptoms,
            value: _formData.symptomTypes.map((t) => t.label(context)).join(', '),
          ),
          const SizedBox(height: 16),

          // Severity
          if (_formData.severity != null)
            _buildReviewSection(
              theme,
              icon: _formData.severity!.icon,
              title: context.l10n.symptomLoggerStepSeverity,
              value: _formData.severity!.label(context),
            ),
          const SizedBox(height: 16),

          // Affected Parts
          _buildReviewSection(
            theme,
            icon: Icons.select_all,
            title: context.l10n.symptomLoggerStepParts,
            value: _formData.affectedParts.map((p) => p.label(context)).join(', '),
          ),
          const SizedBox(height: 16),

          // Onset Timing
          if (_formData.onsetTiming != null)
            _buildReviewSection(
              theme,
              icon: Icons.schedule,
              title: context.l10n.symptomLoggerStepOnset,
              value: _formData.onsetTiming!.label(context),
            ),
          const SizedBox(height: 16),

          // Soil Moisture
          if (_formData.soilMoisture != null)
            _buildReviewSection(
              theme,
              icon: Icons.water_drop,
              title: context.l10n.symptomLoggerSoilMoisture,
              value: _formData.soilMoisture!.label(context),
            ),
          const SizedBox(height: 16),

          // Light Condition
          if (_formData.lightCondition != null)
            _buildReviewSection(
              theme,
              icon: Icons.light_mode,
              title: context.l10n.symptomLoggerLightCondition,
              value: _formData.lightCondition!.label(context),
            ),
          const SizedBox(height: 16),

          // Notes
          if (_formData.notes.isNotEmpty)
            _buildReviewSection(
              theme,
              icon: Icons.notes,
              title: context.l10n.symptomLoggerNotesLabel,
              value: _formData.notes,
            ),
          const SizedBox(height: 16),

          // Photo
          if (_formData.photoPath != null) ...[
            _buildReviewSection(
              theme,
              icon: Icons.photo,
              title: context.l10n.symptomLoggerPhotoLabel,
              value: context.l10n.symptomLoggerPhotoAttached,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_formData.photoPath!),
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReviewSection(
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(value, style: theme.textTheme.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  // --- Navigation Bar ---

  Widget _buildNavigationBar() {
    final isLastStep = _currentStep == _totalSteps - 1;
    final isFirstStep = _currentStep == 0;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            if (!isFirstStep)
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _submitting ? null : _goBack,
                  icon: const Icon(Icons.arrow_back),
                  label: Text(context.l10n.back),
                ),
              ),
            if (!isFirstStep) const SizedBox(width: 16),
            Expanded(
              child: FilledButton.icon(
                onPressed: _submitting ? null : (isLastStep ? _submit : _goNext),
                icon: Icon(isLastStep ? Icons.check : Icons.arrow_forward),
                label: Text(isLastStep ? context.l10n.symptomLoggerSave : context.l10n.next),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
