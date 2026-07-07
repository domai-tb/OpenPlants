import 'dart:io';

import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_form_page.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/widgets/confirm_dialog.dart';

class PlantCollectionDetailPage extends StatefulWidget {
  final PlantEntity plant;

  const PlantCollectionDetailPage({super.key, required this.plant});

  @override
  State<PlantCollectionDetailPage> createState() =>
      _PlantCollectionDetailPageState();
}

class _PlantCollectionDetailPageState extends State<PlantCollectionDetailPage> {
  late PlantCollectionUsecases _usecases;
  bool _wired = false;
  late PlantEntity _plant;

  @override
  void initState() {
    super.initState();
    _plant = widget.plant;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.plantCollection;
    _wired = true;
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_plant.name),
        actions: [
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
            value: _plant.lastWateredAt != null
                ? _formatDate(_plant.lastWateredAt!)
                : context.l10n.never,
          ),
          const Divider(height: 32),

          // Last fertilized
          _buildInfoRow(
            theme,
            icon: Icons.grass,
            label: context.l10n.lastFertilized,
            value: _plant.lastFertilizedAt != null
                ? _formatDate(_plant.lastFertilizedAt!)
                : context.l10n.never,
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
        ],
      ),
    );
  }

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
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
