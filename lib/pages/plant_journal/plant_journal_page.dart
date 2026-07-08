import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_entry_form_page.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_extensions.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_usecases.dart';
import 'package:open_plant/widgets/confirm_dialog.dart';

/// Timeline view of journal entries for a specific plant.
class PlantJournalPage extends StatefulWidget {
  final String plantId;
  final String plantName;

  const PlantJournalPage({
    super.key,
    required this.plantId,
    required this.plantName,
  });

  @override
  State<PlantJournalPage> createState() => _PlantJournalPageState();
}

class _PlantJournalPageState extends State<PlantJournalPage> {
  late PlantJournalUseCases _usecases;
  bool _wired = false;

  List<JournalEntry> _entries = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.plantJournal;
    _wired = true;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await _usecases.getEntries(widget.plantId);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  Future<void> _addEntry() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlantJournalEntryFormPage(
          plantId: widget.plantId,
        ),
      ),
    );
    if (mounted) {
      unawaited(_load());
    }
  }

  Future<void> _editEntry(JournalEntry entry) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PlantJournalEntryFormPage(
          plantId: widget.plantId,
          existingEntry: entry,
        ),
      ),
    );
    if (mounted) {
      unawaited(_load());
    }
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: context.l10n.journalDeleteEntry,
        message: context.l10n.journalDeleteConfirm,
        confirmLabel: context.l10n.confirm,
      ),
    );

    if (confirmed == true && mounted) {
      await _usecases.deleteEntry(entry.id);
      unawaited(_load());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.journalPageTitle(widget.plantName)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) =>
                      _buildEntryCard(context, _entries[index]),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addEntry,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.book_outlined,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.journalEmpty,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.journalTapToAdd,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _editEntry(entry),
        onLongPress: () => _deleteEntry(entry),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    entry.type.icon,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    entry.type.label(context),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formatJournalDate(entry.timestamp, context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
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
                const SizedBox(height: 8),
                Text(
                  entry.notes!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
