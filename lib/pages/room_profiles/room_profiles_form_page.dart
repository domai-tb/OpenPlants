import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_entity.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_repository.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_usecases.dart';

/// Room presets with pre-filled environment attributes.
class _RoomPreset {
  final String name;
  final RoomLightLevel lightLevel;
  final RoomHumidityLevel humidityLevel;

  const _RoomPreset({
    required this.name,
    required this.lightLevel,
    required this.humidityLevel,
  });
}

const List<_RoomPreset> _presets = [
  _RoomPreset(name: 'Bedroom', lightLevel: RoomLightLevel.medium, humidityLevel: RoomHumidityLevel.medium),
  _RoomPreset(name: 'Kitchen', lightLevel: RoomLightLevel.bright, humidityLevel: RoomHumidityLevel.medium),
  _RoomPreset(name: 'Bathroom', lightLevel: RoomLightLevel.low, humidityLevel: RoomHumidityLevel.high),
  _RoomPreset(name: 'Living Room', lightLevel: RoomLightLevel.bright, humidityLevel: RoomHumidityLevel.medium),
  _RoomPreset(name: 'Balcony', lightLevel: RoomLightLevel.directSun, humidityLevel: RoomHumidityLevel.low),
  _RoomPreset(name: 'Office', lightLevel: RoomLightLevel.medium, humidityLevel: RoomHumidityLevel.low),
];

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
      _nameController.text = preset.name;
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
          _nameError = 'A room with this name already exists';
          _saving = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving room: $e')),
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
        title: Text(_isEditing ? 'Edit Room' : 'New Room'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save'),
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
                'Quick Start',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _presets.map((preset) {
                  return ActionChip(
                    label: Text(preset.name),
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
                labelText: 'Room name *',
                border: const OutlineInputBorder(),
                errorText: _nameError,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Room name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Light level
            Text(
              'Light Level',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<RoomLightLevel>(
              segments: const [
                ButtonSegment(
                  value: RoomLightLevel.low,
                  label: Text('Low'),
                  icon: Icon(Icons.dark_mode),
                ),
                ButtonSegment(
                  value: RoomLightLevel.medium,
                  label: Text('Medium'),
                ),
                ButtonSegment(
                  value: RoomLightLevel.bright,
                  label: Text('Bright'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: RoomLightLevel.directSun,
                  label: Text('Direct Sun'),
                  icon: Icon(Icons.wb_sunny),
                ),
              ],
              selected: {_lightLevel},
              onSelectionChanged: (selected) {
                setState(() => _lightLevel = selected.first);
              },
            ),
            const SizedBox(height: 16),

            // Humidity level
            Text(
              'Humidity Level',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<RoomHumidityLevel>(
              segments: const [
                ButtonSegment(
                  value: RoomHumidityLevel.low,
                  label: Text('Low'),
                ),
                ButtonSegment(
                  value: RoomHumidityLevel.medium,
                  label: Text('Medium'),
                ),
                ButtonSegment(
                  value: RoomHumidityLevel.high,
                  label: Text('High'),
                  icon: Icon(Icons.water_drop),
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
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }
}
