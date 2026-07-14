import 'package:flutter/material.dart';

import 'package:open_plants/l10n/l10n_x.dart';
import 'package:open_plants/pages/plant_journal/plant_journal_item_entity.dart';

/// Card widget that renders a diagnosis-type journal entry.
///
/// Displays top cause name, confidence badge, evidence summary,
/// date evaluated, and a link to the source symptom when paired.
class JournalDiagnosisCard extends StatelessWidget {
  final JournalEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onLinkedSymptomTap;

  const JournalDiagnosisCard({
    super.key,
    required this.entry,
    this.onTap,
    this.onLinkedSymptomTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = entry.structuredData ?? {};
    final topCause = data['topCause'] as String?;
    final topConfidence = data['topConfidence'] as double?;
    final causeCount = data['causeCount'] as int? ?? 0;
    final evidenceSummary = data['evidenceSummary'] as String?;
    final linkedSymptomId = data['symptomLogEntryId'] as String?;

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
                    Icons.medical_services_outlined,
                    size: 18,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    context.l10n.healthTimelineDiagnosisEntry,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (topConfidence != null) _ConfidenceBadge(confidence: topConfidence),
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

              // Top cause
              if (topCause != null) ...[
                Text(
                  topCause
                      .replaceAllMapped(
                        RegExp('(?<=[a-z])(?=[A-Z])|_'),
                        (m) => ' ',
                      )
                      .trim(),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
              ],

              // Cause count
              if (causeCount > 1)
                Text(
                  '$causeCount possible causes evaluated',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

              // Evidence summary
              if (evidenceSummary != null && evidenceSummary.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  evidenceSummary,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Notes
              if (entry.notes != null && entry.notes!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  entry.notes!,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              // Linked symptom reference
              if (linkedSymptomId != null && onLinkedSymptomTap != null) ...[
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: onLinkedSymptomTap,
                  icon: const Icon(Icons.link, size: 14),
                  label: Text(
                    context.l10n.healthTimelineViewLinkedSymptom,
                    style: theme.textTheme.labelSmall,
                  ),
                ),
              ],
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
}

/// Small badge indicating diagnosis confidence level.
class _ConfidenceBadge extends StatelessWidget {
  final double confidence;

  const _ConfidenceBadge({required this.confidence});

  @override
  Widget build(BuildContext context) {
    final (Color color, String label) = switch (confidence) {
      > 0.7 => (Colors.green.shade600, 'High'),
      > 0.4 => (Colors.orange.shade600, 'Medium'),
      _ => (Colors.grey.shade600, 'Low'),
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
