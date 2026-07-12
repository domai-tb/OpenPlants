import 'dart:io';

import 'package:flutter/material.dart';

import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/diagnosis/diagnosis_item_entity.dart';
import 'package:open_plant/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plant/pages/symptom_logger/symptom_logger_item_entity.dart';

/// Card widget that renders a symptom-type journal entry.
///
/// Displays symptom type icons, severity badge, onset timing,
/// affected parts, and resolved/unresolved status.
class JournalSymptomCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback? onResolvedTap;
  final VoidCallback? onTap;

  const JournalSymptomCard({
    super.key,
    required this.entry,
    this.onResolvedTap,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = entry.structuredData ?? {};
    final resolved = data['resolved'] as bool? ?? false;
    final severityName = data['severity'] as String? ?? 'mild';
    final severity = Severity.values.firstWhere(
      (s) => s.name == severityName,
      orElse: () => Severity.mild,
    );
    final symptomTypeNames = (data['symptomTypes'] as List<dynamic>?)?.cast<String>() ?? [];
    final affectedPartNames = (data['affectedParts'] as List<dynamic>?)?.cast<String>() ?? [];
    final onsetTimingName = data['onsetTiming'] as String? ?? 'today';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Icon(
                    Icons.bug_report_outlined,
                    size: 18,
                    color: resolved ? theme.colorScheme.onSurfaceVariant : Colors.orange.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.healthTimelineSymptomEntry,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: resolved ? theme.colorScheme.onSurfaceVariant : Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _SeverityBadge(severity: severity),
                  const Spacer(),
                  Text(
                    _formatDate(entry.timestamp, context),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Symptom type icons
              if (symptomTypeNames.isNotEmpty) ...[
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: symptomTypeNames.map((name) {
                    final symptom = PlantSymptom.values.firstWhere(
                      (s) => s.name == name,
                      orElse: () => PlantSymptom.yellowingLeaves,
                    );
                    return Chip(
                      avatar: Icon(_symptomIcon(symptom), size: 16),
                      label: Text(_symptomLabel(symptom, context)),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],

              // Affected parts
              if (affectedPartNames.isNotEmpty) ...[
                Text(
                  'Affected: ${affectedPartNames.map((n) => n.replaceAll(RegExp('(?<=[a-z])(?=[A-Z])|_'), ' ')).join(', ')}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Onset timing
              Text(
                'Onset: ${onsetTimingName.replaceAll(RegExp('(?<=[a-z])(?=[A-Z])'), ' ')}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              // Photo
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

              // Notes
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  entry.notes!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Resolved status / action
              const SizedBox(height: 8),
              if (resolved)
                Row(
                  children: [
                    Icon(Icons.check_circle, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      context.l10n.healthTimelineResolved,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                )
              else if (onResolvedTap != null)
                TextButton.icon(
                  onPressed: onResolvedTap,
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: Text(
                    context.l10n.healthTimelineMarkResolved,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) {
      return context.l10n.healthTimelineTodayAt(
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
      );
    } else if (diff.inDays == 1) {
      return context.l10n.healthTimelineYesterdayAt(
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
      );
    }
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return context.l10n.healthTimelineDateAt(
      '$month/$day/${date.year}',
      '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
    );
  }

  IconData _symptomIcon(PlantSymptom symptom) {
    switch (symptom) {
      case PlantSymptom.yellowingLeaves:
        return Icons.face; // yellow
      case PlantSymptom.droopingWilt:
        return Icons.mood_bad;
      case PlantSymptom.brownTips:
        return Icons.colorize;
      case PlantSymptom.brownPatches:
        return Icons.blur_on;
      case PlantSymptom.paleLeaves:
        return Icons.invert_colors;
      case PlantSymptom.leggyGrowth:
        return Icons.straighten;
      case PlantSymptom.visibleInsects:
        return Icons.bug_report;
      case PlantSymptom.stickyResidue:
        return Icons.opacity;
      case PlantSymptom.moldOnSoil:
        return Icons.grass;
      case PlantSymptom.foulSmell:
        return Icons.air;
      case PlantSymptom.stuntedGrowth:
        return Icons.block;
      case PlantSymptom.leafCurling:
        return Icons.auto_fix_high;
      case PlantSymptom.leafDrop:
        return Icons.file_download;
      case PlantSymptom.softStems:
        return Icons.timeline;
      case PlantSymptom.drySoil:
        return Icons.water_drop;
      case PlantSymptom.wetSoil:
        return Icons.water;
      case PlantSymptom.leafSpots:
        return Icons.lens;
    }
  }

  String _symptomLabel(PlantSymptom symptom, BuildContext context) {
    // Use the symptom name as a simple label; l10n can be added later
    return symptom.name
        .replaceAllMapped(
          RegExp('[A-Z]'),
          (m) => ' ${m.group(0)}',
        )
        .trim();
  }
}

/// Small colored badge indicating severity level.
class _SeverityBadge extends StatelessWidget {
  final Severity severity;

  const _SeverityBadge({required this.severity});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (severity) {
      Severity.mild => (Colors.green.shade600, 'Mild'),
      Severity.moderate => (Colors.orange.shade600, 'Moderate'),
      Severity.severe => (Colors.red.shade600, 'Severe'),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
