import 'package:flutter/material.dart';

import 'package:open_plant/l10n/l10n.dart';
import 'package:open_plant/l10n/l10n_x.dart';
import 'package:open_plant/pages/plant_health_timeline/plant_health_timeline_item_entity.dart';

/// Card widget that displays a single timeline entry.
///
/// Shows the entry's icon, title, subtitle, date, and severity badge.
/// Visually distinguishes between symptom and diagnosis entries.
class TimelineEntryCard extends StatelessWidget {
  final TimelineEntry entry;
  final VoidCallback? onTap;

  const TimelineEntryCard({
    super.key,
    required this.entry,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSymptom = entry.type == TimelineEntryType.symptom;
    final accentColor = isSymptom ? theme.colorScheme.error : theme.colorScheme.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon circle
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  entry.iconData ?? (isSymptom ? Icons.bug_report_outlined : Icons.medical_services_outlined),
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _localizedTitle(context),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (entry.severity != null)
                          _SeverityBadge(
                            severity: entry.severity!,
                            color: accentColor,
                          ),
                      ],
                    ),
                    if (entry.subtitle != null && entry.subtitle!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                          _localizedSubtitle(context, entry.subtitle!),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(context, entry.date),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _localizedTitle(BuildContext context) {
    final l10n = context.l10n;

    return switch (entry.type) {
      TimelineEntryType.symptom => _localizedSymptom(l10n, entry.title),
      TimelineEntryType.diagnosis => l10n.healthTimelineDiagnosisEntry,
    };
  }

  String _localizedSubtitle(BuildContext context, String subtitle) {
    final l10n = context.l10n;

    return switch (entry.type) {
      TimelineEntryType.symptom => _localizedSeverity(l10n, subtitle),
      TimelineEntryType.diagnosis => _localizedCause(l10n, subtitle),
    };
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final entryDate = DateTime(date.year, date.month, date.day);
    final time = MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(date));
    final l10n = context.l10n;

    if (entryDate == today) {
      return l10n.healthTimelineTodayAt(time);
    }
    final yesterday = today.subtract(const Duration(days: 1));
    if (entryDate == yesterday) {
      return l10n.healthTimelineYesterdayAt(time);
    }
    final formattedDate = MaterialLocalizations.of(context).formatShortDate(date);
    return l10n.healthTimelineDateAt(formattedDate, time);
  }

  String _localizedSymptom(AppLocalizations l10n, String symptom) {
    return switch (symptom) {
      'yellowingLeaves' => l10n.diagnosisSymptomYellowingLeaves,
      'droopingWilt' => l10n.diagnosisSymptomDroopingWilt,
      'brownTips' => l10n.diagnosisSymptomBrownTips,
      'brownPatches' => l10n.diagnosisSymptomBrownPatches,
      'paleLeaves' => l10n.diagnosisSymptomPaleLeaves,
      'leggyGrowth' => l10n.diagnosisSymptomLeggyGrowth,
      'visibleInsects' => l10n.diagnosisSymptomVisibleInsects,
      'stickyResidue' => l10n.diagnosisSymptomStickyResidue,
      'moldOnSoil' => l10n.diagnosisSymptomMoldOnSoil,
      'foulSmell' => l10n.diagnosisSymptomFoulSmell,
      'stuntedGrowth' => l10n.diagnosisSymptomStuntedGrowth,
      'leafCurling' => l10n.diagnosisSymptomLeafCurling,
      'leafDrop' => l10n.diagnosisSymptomLeafDrop,
      'softStems' => l10n.diagnosisSymptomSoftStems,
      'drySoil' => l10n.diagnosisSymptomDrySoil,
      'wetSoil' => l10n.diagnosisSymptomWetSoil,
      'leafSpots' => l10n.diagnosisSymptomLeafSpots,
      _ => l10n.healthTimelineSymptomEntry,
    };
  }

  String _localizedSeverity(AppLocalizations l10n, String severity) {
    return switch (severity) {
      'mild' => l10n.symptomSeverityMild,
      'moderate' => l10n.symptomSeverityModerate,
      'severe' => l10n.symptomSeveritySevere,
      _ => severity,
    };
  }

  String _localizedCause(AppLocalizations l10n, String cause) {
    return switch (cause) {
      'overwatering' => l10n.diagnosisCauseOverwatering,
      'underwatering' => l10n.diagnosisCauseUnderwatering,
      'low_light' => l10n.diagnosisCauseLowLight,
      'sunburn' => l10n.diagnosisCauseSunburn,
      'low_humidity' => l10n.diagnosisCauseLowHumidity,
      'nutrient_problem' => l10n.diagnosisCauseNutrientProblem,
      'root_issue' => l10n.diagnosisCauseRootIssue,
      'pests' => l10n.diagnosisCausePests,
      _ => cause,
    };
  }
}

/// Small badge displaying the severity level.
class _SeverityBadge extends StatelessWidget {
  final String severity;
  final Color color;

  const _SeverityBadge({
    required this.severity,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
