import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/core/constants.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_item_entity.dart';
import 'package:open_plant/pages/plant_collection/plant_collection_usecases.dart';
import 'package:open_plant/pages/plant_identification/classifier/classification_result.dart';
import 'package:open_plant/pages/plant_identification/classifier/plant_classifier_usecases.dart';
import 'package:open_plant/pages/plant_identification/widgets/identification_picker.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_entity.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_form_page.dart';
import 'package:open_plant/pages/room_profiles/room_profiles_usecases.dart';

/// Identification flow states for the add-plant form.
enum PhotoIdentificationState { idle, identifying, resultsShown, error }

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
  final _notesController = TextEditingController();

  late PlantCollectionUsecases _usecases;
  late PlantClassifierUsecases _identificationUsecases;
  late RoomProfilesUsecases _roomUsecases;
  bool _wired = false;

  File? _photoFile;
  String? _existingPhotoPath;
  CareStatus _careStatus = CareStatus.happy;
  String? _selectedRoomId;
  bool _saving = false;
  int _roomDropdownKey = 0;

  PhotoIdentificationState _photoIdentificationState = PhotoIdentificationState.idle;
  List<SpeciesPrediction> _identificationResults = [];
  String? _identifyingPhotoPath;

  List<RoomEntity> _rooms = [];

  bool get _isEditing => widget.plant != null;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    final services = AppScope.of(context).services;
    _usecases = services.plantCollection;
    _identificationUsecases = services.plantIdentification;
    _roomUsecases = services.roomProfiles;
    _wired = true;

    _loadRooms();

    if (_isEditing) {
      _nameController.text = widget.plant!.name;
      _speciesController.text = widget.plant!.speciesName ?? '';
      _notesController.text = widget.plant!.notes ?? '';
      _careStatus = widget.plant!.careStatus;
      _existingPhotoPath = widget.plant!.photoPath;
      _selectedRoomId = widget.plant!.roomId;
    }
  }

  Future<void> _loadRooms() async {
    final rooms = await _roomUsecases.getAll();
    if (!mounted) return;
    setState(() => _rooms = rooms);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _cameraOrGalleryPicker() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: Text(context.l10n.plantIdCamera),
                onTap: () => Navigator.of(context).pop(ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: Text(context.l10n.plantIdGallery),
                onTap: () => Navigator.of(context).pop(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
    );

    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(source: source);

    if (image != null && mounted) {
      setState(() {
        _photoFile = File(image.path);
        _existingPhotoPath = null;
      });
      unawaited(_runIdentification());
    }
  }

  void _removePhoto() {
    _identifyingPhotoPath = null;
    setState(() {
      _photoFile = null;
      _existingPhotoPath = null;
      _photoIdentificationState = PhotoIdentificationState.idle;
      _identificationResults = [];
    });
  }

  Future<void> _runIdentification() async {
    if (_photoFile == null) return;

    final photoPath = _photoFile!.path;
    _identifyingPhotoPath = photoPath;

    setState(() {
      _photoIdentificationState = PhotoIdentificationState.identifying;
    });

    try {
      final bytes = await _photoFile!.readAsBytes();
      final result = await _identificationUsecases.classifyImage(bytes);
      if (!mounted) return;

      // Discard results if a new photo was picked while identification was in flight
      if (_identifyingPhotoPath != photoPath) return;

      final topPredictions = result.topK(5);
      setState(() {
        _identificationResults = topPredictions;
        _photoIdentificationState = PhotoIdentificationState.resultsShown;
      });
    } catch (e) {
      if (!mounted) return;
      if (_identifyingPhotoPath != photoPath) return;
      debugPrint('Identification failed: $e');
      setState(() {
        _photoIdentificationState = PhotoIdentificationState.error;
      });
    }
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
          roomId: _selectedRoomId,
          clearRoomId: _selectedRoomId == null,
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
          roomId: _selectedRoomId,
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

            // Identification picker (shown when results are available)
            if (_photoIdentificationState == PhotoIdentificationState.resultsShown) ...[
              IdentificationPicker(
                predictions: _identificationResults,
                onSelected: _onSpeciesSelected,
                onSkip: _onSkipIdentification,
              ),
              const SizedBox(height: 24),
            ],

            // Identification loading indicator
            if (_photoIdentificationState == PhotoIdentificationState.identifying) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Column(
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 12),
                      Text(context.l10n.plantIdIdentifying),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Identification error
            if (_photoIdentificationState == PhotoIdentificationState.error) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  context.l10n.plantIdIdentificationErrorWithManual,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Species field (hidden when picker results are shown)
            if (_photoIdentificationState != PhotoIdentificationState.resultsShown) ...[
              TextFormField(
                controller: _speciesController,
                decoration: InputDecoration(
                  labelText: context.l10n.species,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Room picker
            DropdownButtonFormField<String?>(
              key: ValueKey(_roomDropdownKey),
              initialValue: _selectedRoomId,
              decoration: InputDecoration(
                labelText: context.l10n.room,
                border: const OutlineInputBorder(),
              ),
              items: [
                const DropdownMenuItem<String?>(
                  child: Text('No room'),
                ),
                ..._rooms.map(
                  (room) => DropdownMenuItem<String?>(
                    value: room.id,
                    child: Text(room.name),
                  ),
                ),
                const DropdownMenuItem<String?>(
                  value: kNewRoomSentinel,
                  child: Text('+ New Room'),
                ),
              ],
              onChanged: (value) async {
                if (value == kNewRoomSentinel) {
                  final newRoom = await Navigator.of(context).push<RoomEntity>(
                    MaterialPageRoute(builder: (_) => const RoomProfilesFormPage()),
                  );
                  if (newRoom != null) {
                    await _loadRooms();
                    setState(() => _selectedRoomId = newRoom.id);
                  } else {
                    // User cancelled — force rebuild to reset dropdown
                    setState(() => _roomDropdownKey++);
                  }
                } else {
                  setState(() => _selectedRoomId = value);
                }
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
                  child: Stack(
                    children: [
                      if (_photoFile != null)
                        Image.file(
                          _photoFile!,
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      if (_photoFile == null && _existingPhotoPath != null)
                        Image.file(
                          File(_existingPhotoPath!),
                          width: 150,
                          height: 150,
                          fit: BoxFit.cover,
                        ),
                      if (_photoIdentificationState == PhotoIdentificationState.identifying)
                        Positioned.fill(
                          child: Container(
                            color: Colors.black.withValues(alpha: 0.4),
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
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
              onPressed: _cameraOrGalleryPicker,
              icon: const Icon(Icons.edit),
              label: Text(context.l10n.changePhoto),
            ),
          ] else ...[
            GestureDetector(
              onTap: _cameraOrGalleryPicker,
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

  void _onSpeciesSelected(String speciesName) {
    setState(() {
      _speciesController.text = speciesName;
      _photoIdentificationState = PhotoIdentificationState.idle;
      _identificationResults = [];
    });
  }

  void _onSkipIdentification() {
    setState(() {
      _photoIdentificationState = PhotoIdentificationState.idle;
      _identificationResults = [];
    });
  }
}
