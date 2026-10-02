import 'package:flutter/material.dart';

import 'package:openplants/core/app_scope.dart';
import 'package:openplants/l10n/l10n_x.dart';
import 'package:openplants/pages/room_profiles/room_profiles_entity.dart';
import 'package:openplants/pages/room_profiles/room_profiles_repository.dart';
import 'package:openplants/pages/room_profiles/room_profiles_usecases.dart';

/// Room presets with pre-filled environment attributes.
class _RoomPreset {
  final _RoomPresetName name;
  final RoomLightLevel lightLevel;
  final RoomHumidityLevel humidityLevel;

  const _RoomPreset({
    required this.name,
    required this.lightLevel,
    required this.humidityLevel,
  });
}

const List<_RoomPreset> _presets = [
  _RoomPreset(name: _RoomPresetName.bedroom, lightLevel: RoomLightLevel.medium, humidityLevel: RoomHumidityLevel.medium),
  _RoomPreset(name: _RoomPresetName.kitchen, lightLevel: RoomLightLevel.bright, humidityLevel: RoomHumidityLevel.medium),
  _RoomPreset(name: _RoomPresetName.bathroom, lightLevel: RoomLightLevel.low, humidityLevel: RoomHumidityLevel.high),
  _RoomPreset(name: _RoomPresetName.livingRoom, lightLevel: RoomLightLevel.bright, humidityLevel: RoomHumidityLevel.medium),
  _RoomPreset(name: _RoomPresetName.balcony, lightLevel: RoomLightLevel.directSun, humidityLevel: RoomHumidityLevel.low),
  _RoomPreset(name: _RoomPresetName.office, lightLevel: RoomLightLevel.medium, humidityLevel: RoomHumidityLevel.low),
];

enum _RoomPresetName { bedroom, kitchen, bathroom, livingRoom, balcony, office }

extension on _RoomPreset {
  String label(BuildContext context) => switch (name) {
        _RoomPresetName.bedroom => context.l10n.roomPresetBedroom,
        _RoomPresetName.kitchen => context.l10n.roomPresetKitchen,
        _RoomPresetName.bathroom => context.l10n.roomPresetBathroom,
        _RoomPresetName.livingRoom => context.l10n.roomPresetLivingRoom,
        _RoomPresetName.balcony => context.l10n.roomPresetBalcony,
        _RoomPresetName.office => context.l10n.roomPresetOffice,
      };
}

/// Form page for creating or editing a room.
class RoomProfilesFormPage extends StatefulWidget {
  final RoomEntity? room;

  const RoomProfilesFormPage({super.key, this.room});

  @override
  State<RoomProfilesFormPage> createState() => _RoomProfilesFormPageState();
}

class _RoomProfilesFormPageState extends State<RoomProfilesFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _notesController = TextEditingController();

  late RoomProfilesUsecases _usecases;
  bool _wired = false;

  RoomLightLevel _lightLevel = RoomLightLevel.medium;
  RoomHumidityLevel _humidityLevel = RoomHumidityLevel.medium;
  bool _saving = false;
  String? _nameError;

  bool get _isEditing => widget.room != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.roomProfiles;
    _wired = true;

    if (_isEditing) {
      _nameController.text = widget.room!.name;
      _lightLevel = widget.room!.lightLevel;
      _humidityLevel = widget.room!.humidityLevel;
      _notesController.text = widget.room!.notes ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _applyPreset(_RoomPreset preset) {
    setState(() {
      _nameController.text = preset.label(context);
      _lightLevel = preset.lightLevel;
      _humidityLevel = preset.humidityLevel;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _saving = true;
      _nameError = null;
    });

    try {
      final name = _nameController.text.trim();
      final notes = _notesController.text.trim();

      if (_isEditing) {
        final updated = widget.room!.copyWith(
          name: name,
          lightLevel: _lightLevel,
          humidityLevel: _humidityLevel,
          notes: notes,
          clearNotes: notes.isEmpty,
        );
        final saved = await _usecases.update(updated);
        if (mounted) Navigator.of(context).pop(saved);
      } else {
        final saved = await _usecases.create(
          name: name,
          lightLevel: _lightLevel,
          humidityLevel: _humidityLevel,
          notes: notes.isEmpty ? null : notes,
        );
        if (mounted) Navigator.of(context).pop(saved);
      }
    } on RoomNameDuplicateException {
      if (mounted) {
        setState(() {
          _nameError = context.l10n.roomNameDuplicate;
          _saving = false;
        });
      }
    } catch (error, stackTrace) {
      debugPrint('Failed to save room profile: $error\n$stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.generalFailureMessage)),
        );
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? context.l10n.roomFormTitleEdit : context.l10n.roomFormTitleNew),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(context.l10n.save),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Presets (only shown when creating)
            if (!_isEditing) ...[
              Text(
                context.l10n.roomFormQuickStart,
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((preset) {
                  return ActionChip(
                    label: Text(preset.label(context)),
                    onPressed: () => _applyPreset(preset),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.nameRequired,
                border: const OutlineInputBorder(),
                errorText: _nameError,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.nameIsRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Light level
            Text(context.l10n.speciesLibraryLight, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<RoomLightLevel>(
              segments: [
                ButtonSegment(
                  value: RoomLightLevel.low,
                  label: Text(context.l10n.speciesLibraryLightLow),
                  icon: const Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: RoomLightLevel.medium,
                  label: Text(context.l10n.speciesLibraryLightMedium),
                ),
                ButtonSegment(
                  value: RoomLightLevel.bright,
                  label: Text(context.l10n.speciesLibraryLightBright),
                  icon: const Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: RoomLightLevel.directSun,
                  label: Text(context.l10n.speciesLibraryLightDirect),
                  icon: const Icon(Icons.wb_sunny),
                ),
              ],
              selected: {_lightLevel},
              onSelectionChanged: (selected) {
                setState(() => _lightLevel = selected.first);
              },
            ),
            const SizedBox(height: 16),

            // Humidity level
            Text(context.l10n.speciesLibraryHumidity, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            SegmentedButton<RoomHumidityLevel>(
              segments: [
                ButtonSegment(
                  value: RoomHumidityLevel.low,
                  label: Text(context.l10n.diagnosisHumidityLow),
                ),
                ButtonSegment(
                  value: RoomHumidityLevel.medium,
                  label: Text(context.l10n.diagnosisHumidityModerate),
                ),
                ButtonSegment(
                  value: RoomHumidityLevel.high,
                  label: Text(context.l10n.diagnosisHumidityHigh),
                  icon: const Icon(Icons.water_drop),
                ),
              ],
              selected: {_humidityLevel},
              onSelectionChanged: (selected) {
                setState(() => _humidityLevel = selected.first);
              },
            ),
            const SizedBox(height: 16),

            // Notes field
            TextFormField(
              controller: _notesController,
              decoration: InputDecoration(
                labelText: context.l10n.notes,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
