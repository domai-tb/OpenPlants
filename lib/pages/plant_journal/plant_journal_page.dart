import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:open_plants/core/app_scope.dart';
import 'package:open_plants/l10n/l10n_x.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_page.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_repository.dart';
import 'package:open_plants/pages/diagnosis/diagnosis_result_page.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_entry_form_page.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_extensions.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_usecases.dart';
import 'package:open_plants/pages/plant_journal/widgets/journal_diagnosis_card.dart';
import 'package:open_plants/pages/plant_journal/widgets/journal_symptom_card.dart';
import 'package:open_plants/pages/symptom_logger/symptom_logger_page.dart';
import 'package:open_plants/widgets/confirm_dialog.dart';

/// Timeline view of journal entries for a specific plant.
///
/// Shows a unified timeline merging manually-created journal entries with
/// symptom logs and diagnosis results, each rendered with the appropriate card.
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
    final entries = await _usecases.getUnifiedTimeline(widget.plantId);
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

  void _openLogSymptom() {
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => SymptomLoggerPage(
          plantId: widget.plantId,
          plantName: widget.plantName,
        ),
      ),
    )
        .then((_) {
      if (mounted) unawaited(_load());
    });
  }

  void _openDiagnose() {
    // Navigate to diagnosis questionnaire for this plant
    // Use the DiagnosisPage or AutoDiagnosis flow
    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => _DiagnosisPage(
          plantId: widget.plantId,
        ),
      ),
    )
        .then((_) {
      if (mounted) unawaited(_load());
    });
  }

  void _openDiagnosisDetail(JournalEntry entry) {
    final rawId = entry.id.startsWith('diagnosis_') ? entry.id.substring(9) : entry.referenceId ?? entry.id;

    Navigator.of(context)
        .push(
      MaterialPageRoute(
        builder: (_) => _DiagnosisDetailPage(diagnosisId: rawId),
      ),
    )
        .then((_) {
      if (mounted) unawaited(_load());
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.journalPageTitle(widget.plantName)),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report_outlined),
            tooltip: context.l10n.healthTimelineLogSymptom,
            onPressed: _openLogSymptom,
          ),
          IconButton(
            icon: const Icon(Icons.medical_services_outlined),
            tooltip: context.l10n.healthTimelineDiagnose,
            onPressed: _openDiagnose,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) => _buildEntryCard(context, _entries[index]),
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
      child: Padding(
        padding: const EdgeInsets.all(32),
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
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _openLogSymptom,
                  icon: const Icon(Icons.bug_report_outlined, size: 18),
                  label: Text(context.l10n.healthTimelineLogSymptom),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _openDiagnose,
                  icon: const Icon(Icons.medical_services_outlined, size: 18),
                  label: Text(context.l10n.healthTimelineDiagnose),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryCard(BuildContext context, JournalEntry entry) {
    switch (entry.type) {
      case JournalEntryType.symptom:
        return JournalSymptomCard(
          entry: entry,
          onTap: () => _editEntry(entry),
        );
      case JournalEntryType.diagnosis:
        return JournalDiagnosisCard(
          entry: entry,
          onTap: () => _openDiagnosisDetail(entry),
        );
      default:
        return _buildStandardEntryCard(context, entry);
    }
  }

  Widget _buildStandardEntryCard(BuildContext context, JournalEntry entry) {
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

/// Navigates to the real diagnosis questionnaire with current symptoms.
class _DiagnosisPage extends StatefulWidget {
  final String plantId;

  const _DiagnosisPage({required this.plantId});

  @override
  State<_DiagnosisPage> createState() => _DiagnosisPageState();
}

class _DiagnosisPageState extends State<_DiagnosisPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      // Navigate to the DiagnosisPage (questionnaire)
      // The DiagnosisPage doesn't take plantId, but we can navigate to it
      // with plant species context if available
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const DiagnosisPage(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

/// Loads and displays a diagnosis result from the unified timeline.
class _DiagnosisDetailPage extends StatefulWidget {
  final String diagnosisId;

  const _DiagnosisDetailPage({required this.diagnosisId});

  @override
  State<_DiagnosisDetailPage> createState() => _DiagnosisDetailPageState();
}

class _DiagnosisDetailPageState extends State<_DiagnosisDetailPage> {
  late final DiagnosisRepository _diagRepo;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _diagRepo = AppScope.of(context).services.diagnosis;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _load();
    });
  }

  Future<void> _load() async {
    try {
      final result = await _diagRepo.getResultById(widget.diagnosisId);
      if (!mounted) return;
      if (result != null) {
        // Navigate to the actual DiagnosisResultPage
        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => DiagnosisResultPage(entity: result),
          ),
        );
      } else {
        setState(() => _loading = false);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(),
      body: const Center(
        child: Text('Diagnosis result not found'),
      ),
    );
  }
}
