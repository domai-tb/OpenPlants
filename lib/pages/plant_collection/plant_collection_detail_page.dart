import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/core/date_utils.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_form_page.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_page.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_usecases.dart';
import 'package:open_plant/pages/plant_photo_timeline/plant_photo_timeline_item_entity.dart';
import 'package:open_plant/pages/plant_photo_timeline/plant_photo_timeline_page.dart';
import 'package:open_plant/pages/plant_photo_timeline/plant_photo_timeline_usecases.dart';
import 'package:open_plant/pages/care_schedule/custom_care_rule_usecases.dart';
import 'package:open_plant/pages/care_schedule/widgets/care_rules_section.dart';
import 'package:open_plant/pages/lightAssessment/light_assessment_page.dart';
import 'package:open_plant/pages/lightAssessment/light_assessment_usecases.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_history_usecases.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_page.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_result_page.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_usecases.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_extensions.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_item_entity.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_page.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_usecases.dart';
import 'package:open_plant/widgets/confirm_dialog.dart';

class PlantCollectionDetailPage extends StatefulWidget {
  final PlantEntity plant;

  const PlantCollectionDetailPage({super.key, required this.plant});

  @override
  State<PlantCollectionDetailPage> createState() => _PlantCollectionDetailPageState();
}

class _PlantCollectionDetailPageState extends State<PlantCollectionDetailPage> {
  late PlantCollectionUsecases _usecases;
  late PlantPhotoTimelineUseCases _photoTimelineUsecases;
  late SymptomLoggerUseCases _symptomUsecases;
  late PlantJournalUseCases _journalUsecases;
  late RoomProfilesUsecases _roomUsecases;
  late CustomCareRuleUsecases _careRuleUsecases;
  late LightAssessmentUseCases _lightAssessmentUsecases;
  late DiagnosisHistoryUseCases _diagnosisHistoryUsecases;
  bool _wired = false;
  late PlantEntity _plant;
  List<SymptomLogEntry> _symptomHistory = const [];
  bool _loadingSymptoms = true;
  String? _roomName;
  List<PlantPhoto> _photos = [];
  DiagnosisResultEntity? _latestDiagnosis;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    final services = AppScope.of(context).services;
    _usecases = services.plantCollection;
    _photoTimelineUsecases = services.plantPhotoTimeline;
    _symptomUsecases = services.symptomLogger;
    _journalUsecases = services.plantJournal;
    _roomUsecases = services.roomProfiles;
    _careRuleUsecases = services.customCareRules;
    _lightAssessmentUsecases = services.lightAssessment;
    _diagnosisHistoryUsecases = services.diagnosisHistory;
    _wired = true;
    _loadSymptomHistory();
    _loadRoomName();
    _loadPhotos();
    _loadLatestDiagnosis();
  }

  Future<void> _loadRoomName() async {
    if (_plant.roomId == null) return;
    final room = await _roomUsecases.getById(_plant.roomId!);
    if (!mounted) return;
    setState(() => _roomName = room?.name);
  }

  Future<void> _loadPhotos() async {
    try {
      final photos = await _photoTimelineUsecases.getTimeline(_plant.id);
      if (!mounted) return;
      setState(() => _photos = photos);
    } catch (_) {
      // Silently handle — photos will remain empty
    }
  }

  Future<void> _loadLatestDiagnosis() async {
    try {
      final results = await _diagnosisHistoryUsecases.getResultsForPlant(_plant.id);
      if (!mounted) return;
      if (results.isNotEmpty) {
        setState(() => _latestDiagnosis = results.first);
      }
    } catch (_) {
      // Silently handle — badge will not be shown
    }
  }

  void _openLatestDiagnosis() {
    if (_latestDiagnosis == null) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DiagnosisResultPage(entity: _latestDiagnosis),
      ),
    );
  }

  Future<void> _addPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(context.l10n.growthPhotoCamera),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(context.l10n.growthPhotoGallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final xFile = await _imagePicker.pickImage(source: source);
      if (xFile == null || !mounted) return;

      final file = File(xFile.path);
      final photo = await _photoTimelineUsecases.addPhoto(
        _plant.id,
        file,
        date: DateTime.now(),
      );

      if (mounted) {
        setState(() => _photos = [photo, ..._photos]);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add photo: $e')),
        );
      }
    }
  }

  void _openTimeline() {
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => PlantPhotoTimelinePage(
              plantId: _plant.id,
              plantName: _plant.name,
            ),
          ),
        )
        .then((_) => _loadPhotos());
  }

  Future<void> _loadSymptomHistory() async {
    // Only show the loading indicator on the initial load (when the list is
    // empty) to avoid a flickering progress indicator on subsequent refreshes.
    if (_symptomHistory.isEmpty) {
      setState(() => _loadingSymptoms = true);
    }
    final history = await _symptomUsecases.getSymptomHistory(_plant.id);
    if (!mounted) return;
    setState(() {
      _symptomHistory = history;
      _loadingSymptoms = false;
    });
  }

  Future<void> _editPlant() async {
    final result = await Navigator.of(context).push<PlantEntity>(
      MaterialPageRoute(
        builder: (_) => PlantCollectionFormPage(plant: _plant),
      ),
    );

    if (result != null && mounted) {
      setState(() => _plant = result);
    }
  }

  Future<void> _deletePlant() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: context.l10n.deletePlantTitle,
        message: context.l10n.deletePlantConfirm(_plant.name),
        confirmLabel: context.l10n.deletePlant,
      ),
    );

    if (confirmed == true && mounted) {
      // Delete growth photo files before deleting the plant
      await _photoTimelineUsecases.deleteAllPhotos(_plant.id);
      await _journalUsecases.deleteEntriesForPlant(_plant.id);
      await _usecases.deletePlant(_plant.id);
      if (mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _markAsWatered() async {
    final updated = await _usecases.markAsWatered(_plant);
    if (mounted) {
      setState(() => _plant = updated);
    }
  }

  Future<void> _markAsFertilized() async {
    final updated = await _usecases.markAsFertilized(_plant);
    if (mounted) {
      setState(() => _plant = updated);
    }
  }

  Future<void> _logSymptom() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SymptomLoggerPage(
          plantId: _plant.id,
          plantName: _plant.name,
        ),
      ),
    );
    if (mounted) {
      unawaited(_loadSymptomHistory());
    }
  }

  Future<void> _openJournal() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlantJournalPage(
          plantId: _plant.id,
          plantName: _plant.name,
        ),
      ),
    );
  }

  Future<void> _openLightAssessment() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LightAssessmentPage(
          plantId: _plant.id,
          plantName: _plant.name,
          usecases: _lightAssessmentUsecases,
        ),
      ),
    );
    // Reload plant to reflect updated light level
    final updatedPlants = await _usecases.loadPlants();
    final matching = updatedPlants.where((p) => p.id == _plant.id);
    final updated = matching.isNotEmpty ? matching.first : null;
    if (updated != null && mounted) {
      setState(() => _plant = updated);
    }
  }

  void _openDiagnosis() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DiagnosisPage(
          plantSpecies: _plant.speciesName,
          initialLightExposure: _mapLightLevelToExposure(_plant.lightLevel),
        ),
      ),
    );
  }

  LightExposure? _mapLightLevelToExposure(LightLevel? level) {
    if (level == null) return null;
    return switch (level) {
      LightLevel.low => LightExposure.low,
      LightLevel.medium => LightExposure.indirect,
      LightLevel.brightIndirect => LightExposure.indirect,
      LightLevel.direct => LightExposure.direct,
    };
  }

  Future<void> _markSymptomResolved(SymptomLogEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: context.l10n.symptomLoggerMarkResolved,
        message: context.l10n.symptomLoggerMarkResolvedConfirm,
        confirmLabel: context.l10n.confirm,
      ),
    );

    if (confirmed == true && mounted) {
      await _symptomUsecases.markResolved(entry.id);
      unawaited(_loadSymptomHistory());
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_plant.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.book),
            tooltip: context.l10n.journalTitle,
            onPressed: _openJournal,
          ),
          IconButton(
            icon: const Icon(Icons.healing),
            tooltip: context.l10n.symptomLoggerLogSymptom,
            onPressed: _logSymptom,
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _editPlant,
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletePlant,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Photo
          if (_plant.photoPath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_plant.photoPath!),
                width: double.infinity,
                height: 250,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Growth Photos
          _buildGrowthPhotosSection(theme),
          const SizedBox(height: 24),

          // Care status
          _buildInfoRow(
            theme,
            icon: Icons.circle,
            iconColor: _getCareStatusColor(_plant.effectiveCareStatus),
            label: context.l10n.careStatus,
            value: _getCareStatusText(_plant.effectiveCareStatus),
          ),
          const Divider(height: 32),

          // Species
          if (_plant.speciesName != null) ...[
            _buildInfoRow(
              theme,
              icon: Icons.spa,
              label: context.l10n.species,
              value: _plant.speciesName!,
            ),
            const Divider(height: 32),
          ],

          // Room
          if (_plant.roomId != null || _plant.room != null) ...[
            _buildInfoRow(
              theme,
              icon: Icons.room,
              label: context.l10n.room,
              value: _roomName ?? _plant.room ?? 'Unknown room',
            ),
            const Divider(height: 32),
          ],

          // Light Level
          _buildInfoRow(
            theme,
            icon: Icons.light_mode,
            label: 'Light Level',
            value: _plant.lightLevel?.label ?? 'Not set',
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _openLightAssessment,
              icon: const Icon(Icons.edit, size: 18),
              label: const Text('Assess Light Level'),
            ),
          ),
          const Divider(height: 32),

          // Notes
          if (_plant.notes != null) ...[
            _buildInfoRow(
              theme,
              icon: Icons.notes,
              label: context.l10n.notes,
              value: _plant.notes!,
            ),
            const Divider(height: 32),
          ],

          // Last watered
          _buildInfoRow(
            theme,
            icon: Icons.water_drop,
            label: context.l10n.lastWatered,
            value: _plant.lastWateredAt != null ? _formatDate(_plant.lastWateredAt!) : context.l10n.never,
          ),
          const Divider(height: 32),

          // Last fertilized
          _buildInfoRow(
            theme,
            icon: Icons.grass,
            label: context.l10n.lastFertilized,
            value: _plant.lastFertilizedAt != null ? _formatDate(_plant.lastFertilizedAt!) : context.l10n.never,
          ),
          const SizedBox(height: 24),

          // Care Rules
          CareRulesSection(
            plantId: _plant.id,
            usecases: _careRuleUsecases,
          ),
          const SizedBox(height: 24),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _markAsWatered,
                  icon: const Icon(Icons.water_drop),
                  label: Text(context.l10n.markAsWatered),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _markAsFertilized,
                  icon: const Icon(Icons.grass),
                  label: Text(context.l10n.markAsFertilized),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Log Symptom button
          OutlinedButton.icon(
            onPressed: _logSymptom,
            icon: const Icon(Icons.healing),
            label: Text(context.l10n.symptomLoggerLogSymptom),
          ),
          const SizedBox(height: 12),

          // Diagnose this plant button
          OutlinedButton.icon(
            onPressed: _openDiagnosis,
            icon: const Icon(Icons.search),
            label: Text(context.l10n.diagnosisDiagnoseThisPlant),
          ),
          const SizedBox(height: 12),

          // View Journal / Timeline button
          OutlinedButton.icon(
            onPressed: _openJournal,
            icon: const Icon(Icons.book_outlined),
            label: Text(context.l10n.journalTitle),
          ),
          const SizedBox(height: 24),

          // Latest diagnosis badge
          if (_latestDiagnosis != null) _buildDiagnosisBadge(theme),

          // === Symptom History Section ===
          Text(
            context.l10n.symptomLoggerHistory,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 12),

          if (_loadingSymptoms)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_symptomHistory.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                context.l10n.symptomLoggerNoEntries,
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            ..._symptomHistory.map((entry) => _buildSymptomEntry(theme, entry)),
        ],
      ),
    );
  }

  // --- Latest Diagnosis Badge ---

  Widget _buildDiagnosisBadge(ThemeData theme) {
    final entity = _latestDiagnosis!;
    final topCause = entity.causes.isNotEmpty ? entity.causes.first : null;
    final causeName = topCause != null ? _causeNameFromId(topCause.causeId) : 'No clear match';
    final confidence = topCause?.confidence.name ?? 'unknown';

    return GestureDetector(
      onTap: _openLatestDiagnosis,
      child: Card(
        color: theme.colorScheme.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.medical_information,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.healthTimelineBadge,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$causeName (${confidence[0].toUpperCase()}${confidence.substring(1)})',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _causeNameFromId(String causeId) {
    return switch (causeId) {
      'overwatering' => 'Overwatering',
      'underwatering' => 'Underwatering',
      'low_light' => 'Insufficient Light',
      'sunburn' => 'Sunburn',
      'low_humidity' => 'Low Humidity',
      'nutrient_problem' => 'Nutrient Deficiency',
      'root_issue' => 'Root Problems',
      'pests' => 'Pest Infestation',
      _ => 'Unknown',
    };
  }

  // --- Symptom History Entry ---

  Widget _buildSymptomEntry(ThemeData theme, SymptomLogEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Symptom type icons
                ...entry.symptomTypes.take(3).map(
                      (type) => Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Icon(
                          type.icon,
                          size: 18,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                if (entry.symptomTypes.length > 3)
                  Text(
                    ' +${entry.symptomTypes.length - 3}',
                    style: theme.textTheme.bodySmall,
                  ),
                const SizedBox(width: 8),
                // Severity badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: entry.severity.color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.severity.label(context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: entry.severity.color,
                    ),
                  ),
                ),
                const Spacer(),
                // Resolved status
                if (entry.resolved)
                  const Icon(Icons.check_circle, size: 18, color: Colors.green)
                else
                  const Icon(Icons.circle_outlined, size: 18, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 8),

            // Affected parts
            Text(
              entry.affectedParts.map((p) => p.label(context)).join(', '),
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 4),

            // Date
            Text(
              _formatDate(entry.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            // Photo thumbnail
            if (entry.photoPath != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(entry.photoPath!),
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],

            // Notes preview
            if (entry.notes != null && entry.notes!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                entry.notes!,
                style: theme.textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            // Mark Resolved button
            if (!entry.resolved) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () => _markSymptomResolved(entry),
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(context.l10n.symptomLoggerMarkResolved),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // --- Growth Photos Section ---

  Widget _buildGrowthPhotosSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.timeline, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              context.l10n.growthPhotosTitle,
              style: theme.textTheme.titleMedium,
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addPhoto,
              icon: const Icon(Icons.add, size: 18),
              label: Text(context.l10n.growthPhotosAdd),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_photos.isEmpty)
          GestureDetector(
            onTap: _addPhoto,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outlineVariant,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    context.l10n.growthPhotosEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 100,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _photos.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final photo = _photos[index];
                return GestureDetector(
                  onTap: _openTimeline,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(photo.filePath),
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 80,
                        height: 80,
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.broken_image,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // --- Shared helpers ---

  Widget _buildInfoRow(
    ThemeData theme, {
    required IconData icon,
    Color? iconColor,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: iconColor ?? theme.colorScheme.primary,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: theme.textTheme.bodyLarge,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCareStatusColor(CareStatus status) {
    switch (status) {
      case CareStatus.happy:
        return Colors.green;
      case CareStatus.needsWater:
        return Colors.blue;
      case CareStatus.needsFertilizer:
        return Colors.orange;
      case CareStatus.needsAttention:
        return Colors.red;
    }
  }

  String _getCareStatusText(CareStatus status) {
    switch (status) {
      case CareStatus.happy:
        return context.l10n.careStatusHappy;
      case CareStatus.needsWater:
        return context.l10n.careStatusNeedsWater;
      case CareStatus.needsFertilizer:
        return context.l10n.careStatusNeedsFertilizer;
      case CareStatus.needsAttention:
        return context.l10n.careStatusNeedsAttention;
    }
  }

  String _formatDate(DateTime date) => formatDateFull(date);
}
