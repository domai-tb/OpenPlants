import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_form_page.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
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
  late SymptomLoggerUseCases _symptomUsecases;
  bool _wired = false;
  late PlantEntity _plant;
  List<SymptomLogEntry> _symptomHistory = const [];
  bool _loadingSymptoms = true;

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
    _symptomUsecases = services.symptomLogger;
    _wired = true;
    _loadSymptomHistory();
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

          // Care status
          _buildInfoRow(
            theme,
            icon: Icons.circle,
            iconColor: _getCareStatusColor(_plant.careStatus),
            label: context.l10n.careStatus,
            value: _getCareStatusText(_plant.careStatus),
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
          if (_plant.room != null) ...[
            _buildInfoRow(
              theme,
              icon: Icons.room,
              label: context.l10n.room,
              value: _plant.room!,
            ),
            const Divider(height: 32),
          ],

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
          const SizedBox(height: 32),

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
          const SizedBox(height: 24),

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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
