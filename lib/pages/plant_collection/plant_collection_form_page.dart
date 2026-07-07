import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';

class PlantCollectionFormPage extends StatefulWidget {
  final PlantEntity? plant;

  const PlantCollectionFormPage({super.key, this.plant});

  @override
  State<PlantCollectionFormPage> createState() => _PlantCollectionFormPageState();
}

class _PlantCollectionFormPageState extends State<PlantCollectionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _roomController = TextEditingController();
  final _notesController = TextEditingController();

  late PlantCollectionUsecases _usecases;
  bool _wired = false;

  File? _photoFile;
  String? _existingPhotoPath;
  CareStatus _careStatus = CareStatus.happy;
  bool _saving = false;

  bool get _isEditing => widget.plant != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.plantCollection;
    _wired = true;

    if (_isEditing) {
      _nameController.text = widget.plant!.name;
      _speciesController.text = widget.plant!.speciesName ?? '';
      _roomController.text = widget.plant!.room ?? '';
      _notesController.text = widget.plant!.notes ?? '';
      _careStatus = widget.plant!.careStatus;
      _existingPhotoPath = widget.plant!.photoPath;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _roomController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _photoFile = File(image.path);
        _existingPhotoPath = null;
      });
    }
  }

  void _removePhoto() {
    setState(() {
      _photoFile = null;
      _existingPhotoPath = null;
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      if (_isEditing) {
        final updated = widget.plant!.copyWith(
          name: _nameController.text.trim(),
          speciesName: _speciesController.text.trim().isEmpty ? null : _speciesController.text.trim(),
          clearSpecies: _speciesController.text.trim().isEmpty,
          room: _roomController.text.trim().isEmpty ? null : _roomController.text.trim(),
          clearRoom: _roomController.text.trim().isEmpty,
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          clearNotes: _notesController.text.trim().isEmpty,
          careStatus: _careStatus,
          clearPhoto: _photoFile == null && _existingPhotoPath == null,
        );

        final saved = await _usecases.updatePlant(updated, photoFile: _photoFile);

        if (mounted) {
          Navigator.of(context).pop(saved);
        }
      } else {
        final now = DateTime.now();
        final plant = PlantEntity(
          id: '',
          name: _nameController.text.trim(),
          speciesName: _speciesController.text.trim().isEmpty ? null : _speciesController.text.trim(),
          room: _roomController.text.trim().isEmpty ? null : _roomController.text.trim(),
          notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
          careStatus: _careStatus,
          createdAt: now,
          updatedAt: now,
        );

        await _usecases.addPlant(plant, photoFile: _photoFile);

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.errorSavingPlant(e.toString()))),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? context.l10n.editPlant : context.l10n.addPlant),
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
            // Photo section
            _buildPhotoSection(theme),
            const SizedBox(height: 24),

            // Name field (required)
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: context.l10n.nameRequired,
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.nameIsRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Species field
            TextFormField(
              controller: _speciesController,
              decoration: InputDecoration(
                labelText: context.l10n.species,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Room field
            TextFormField(
              controller: _roomController,
              decoration: InputDecoration(
                labelText: context.l10n.room,
                border: const OutlineInputBorder(),
              ),
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
            const SizedBox(height: 24),

            // Care status
            Text(
              context.l10n.careStatus,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SegmentedButton<CareStatus>(
              segments: [
                ButtonSegment(
                  value: CareStatus.happy,
                  label: Text(context.l10n.careStatusHappy),
                  icon: const Icon(Icons.sentiment_satisfied),
                ),
                ButtonSegment(
                  value: CareStatus.needsWater,
                  label: Text(context.l10n.careStatusNeedsWater),
                  icon: const Icon(Icons.water_drop),
                ),
                ButtonSegment(
                  value: CareStatus.needsFertilizer,
                  label: Text(context.l10n.careStatusNeedsFertilizer),
                  icon: const Icon(Icons.grass),
                ),
              ],
              selected: {_careStatus},
              onSelectionChanged: (selected) {
                setState(() => _careStatus = selected.first);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoSection(ThemeData theme) {
    final hasPhoto = _photoFile != null || _existingPhotoPath != null;

    return Center(
      child: Column(
        children: [
          if (hasPhoto) ...[
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: _photoFile != null
                      ? Image.file(
                          _photoFile!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        )
                      : Image.file(
                          File(_existingPhotoPath!),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _removePhoto,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.error,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.close,
                        size: 16,
                        color: theme.colorScheme.onError,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: _pickPhoto,
              icon: const Icon(Icons.edit),
              label: Text(context.l10n.changePhoto),
            ),
          ] else ...[
            GestureDetector(
              onTap: _pickPhoto,
              child: Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 48,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.addPhoto,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
