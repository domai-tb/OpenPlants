import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_extensions.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_usecases.dart';
import 'package:open_plant/widgets/inline_camera_preview.dart';

/// Form page for creating or editing a journal entry.
class PlantJournalEntryFormPage extends StatefulWidget {
  final String plantId;
  final JournalEntry? existingEntry;

  const PlantJournalEntryFormPage({
    super.key,
    required this.plantId,
    this.existingEntry,
  });

  @override
  State<PlantJournalEntryFormPage> createState() => _PlantJournalEntryFormPageState();
}

class _PlantJournalEntryFormPageState extends State<PlantJournalEntryFormPage> {
  late PlantJournalUseCases _usecases;
  bool _wired = false;

  late JournalEntryType _selectedType;
  final _notesController = TextEditingController();
  File? _selectedPhoto;
  String? _existingPhotoPath;
  bool _saving = false;
  bool _showCamera = false;

  bool get _isEditing => widget.existingEntry != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _selectedType = widget.existingEntry!.type;
      _notesController.text = widget.existingEntry!.notes ?? '';
      _existingPhotoPath = widget.existingEntry!.photoPath;
    } else {
      _selectedType = JournalEntryType.text;
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.plantJournal;
    _wired = true;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _onCaptured(Uint8List imageBytes) async {
    if (!mounted) return;

    setState(() => _showCamera = false);

    // Save bytes to a temporary file
    final dir = await getTemporaryDirectory();
    final photoPath = '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(photoPath);
    await file.writeAsBytes(imageBytes);

    if (mounted) {
      setState(() => _selectedPhoto = file);
    }
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);

    try {
      final now = DateTime.now();

      if (_isEditing) {
        final updated = widget.existingEntry!.copyWith(
          type: _selectedType,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          clearNotes: _notesController.text.isEmpty,
        );

        await _usecases.updateEntry(
          updated,
          photoFile: _selectedPhoto,
        );
      } else {
        final entry = JournalEntry(
          id: '',
          plantId: widget.plantId,
          type: _selectedType,
          timestamp: now,
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        await _usecases.addEntry(
          entry,
          photoFile: _selectedPhoto,
        );
      }

      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.generalFailureMessage)),
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
        title: Text(_isEditing ? context.l10n.journalEditEntry : context.l10n.journalNewEntry),
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Entry type selector
          Text(
            context.l10n.journalEntryType,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: JournalEntryType.values.map((type) {
              final selected = type == _selectedType;
              return ChoiceChip(
                label: Text(type.label(context)),
                selected: selected,
                onSelected: (_) => setState(() => _selectedType = type),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Notes field
          TextField(
            controller: _notesController,
            maxLines: 5,
            decoration: InputDecoration(
              labelText: context.l10n.journalNotes,
              hintText: context.l10n.journalNotesHint,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),

          // Photo section
          Text(
            context.l10n.journalPhoto,
            style: theme.textTheme.titleMedium,
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
          ] else if (_selectedPhoto != null)
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    _selectedPhoto!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.8),
                    ),
                    onPressed: () => setState(() => _selectedPhoto = null),
                  ),
                ),
              ],
            )
          else if (_existingPhotoPath != null && _isEditing)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_existingPhotoPath!),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            OutlinedButton.icon(
              onPressed: () => setState(() => _showCamera = true),
              icon: const Icon(Icons.add_a_photo),
              label: Text(context.l10n.journalAddPhoto),
            ),
        ],
      ),
    );
  }
}
