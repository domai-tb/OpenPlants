import 'package:flutter/material.dart';

import 'package:open_plant/core/app_scope.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_result_entity.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_result_page.dart';
import 'package:open_plant/pages/plant_health_timeline/plant_health_timeline_item_entity.dart';
import 'package:open_plant/pages/plant_health_timeline/plant_health_timeline_usecases.dart';
import 'package:open_plant/pages/plant_health_timeline/widgets/timeline_entry_card.dart';

/// Page that displays a unified health timeline for a single plant.
///
/// Merges symptom logs and diagnosis results into a chronological list.
class PlantHealthTimelinePage extends StatefulWidget {
  final String plantId;

  const PlantHealthTimelinePage({
    super.key,
    required this.plantId,
  });

  @override
  State<PlantHealthTimelinePage> createState() => _PlantHealthTimelinePageState();
}

class _PlantHealthTimelinePageState extends State<PlantHealthTimelinePage> {
  late PlantHealthTimelineUseCases _usecases;
  bool _wired = false;
  List<TimelineEntry> _entries = [];
  bool _loading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_wired) return;
    _usecases = AppScope.of(context).services.plantHealthTimeline;
    _wired = true;
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final entries = await _usecases.getTimeline(widget.plantId);
    if (!mounted) return;
    setState(() {
      _entries = entries;
      _loading = false;
    });
  }

  void _onEntryTap(TimelineEntry entry) {
    if (entry.type == TimelineEntryType.diagnosis) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => DiagnosisResultPage(
            entity: DiagnosisResultEntity(
              id: entry.id,
              plantId: entry.plantId,
              plantSymptoms: const [],
              causes: [],
              type: DiagnosisResultType.rankedCauses,
              context: const DiagnosisContext(symptoms: []),
              createdAt: entry.date,
            ),
          ),
        ),
      );
    }
    // Symptom entries could expand inline or navigate to a detail page.
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.healthTimelineTitle),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _buildEmptyState(theme)
              : _buildTimeline(theme),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.timeline,
            size: 64,
            color: theme.colorScheme.primary.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.healthTimelineEmpty,
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.healthTimelineEmptyHint,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _entries.length,
      itemBuilder: (context, index) {
        final entry = _entries[index];
        return TimelineEntryCard(
          entry: entry,
          onTap: () => _onEntryTap(entry),
        );
      },
    );
  }
}
