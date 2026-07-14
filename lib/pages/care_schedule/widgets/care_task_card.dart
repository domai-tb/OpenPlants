import 'package:flutter/material.dart';

import 'package:open_plants/l10n/l10n_x.dart';
import 'package:open_plants/pages/care_schedule/care_task.dart';
import 'package:open_plants/pages/care_schedule/care_task_type.dart';

/// A card displaying a care task with actions.
class CareTaskCard extends StatelessWidget {
  final CareTask task;
  final String? roomName;
  final String? roomEnvironmentSummary;
  final VoidCallback onDone;
  final Function(int days) onSnooze;
  final VoidCallback onSkip;

  const CareTaskCard({
    super.key,
    required this.task,
    this.roomName,
    this.roomEnvironmentSummary,
    required this.onDone,
    required this.onSnooze,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = DateTime.now();
    final isOverdue = task.status == CareTaskStatus.overdue;
    final isDueToday = task.status == CareTaskStatus.dueToday;
    final isJustCompleted = task.status == CareTaskStatus.justCompleted;

    return Opacity(
      opacity: isJustCompleted ? 0.6 : 1.0,
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildTaskIcon(theme),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.taskType.label,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          task.plantName,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (roomName != null && roomEnvironmentSummary != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            '$roomName — $roomEnvironmentSummary',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  _buildStatusBadge(context, theme, today, isOverdue, isDueToday),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: onDone,
                      icon: const Icon(Icons.check, size: 16),
                      label: Text(context.l10n.careScheduleMarkDone),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  PopupMenuButton<int>(
                    onSelected: onSnooze,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: theme.colorScheme.outline,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(context.l10n.careScheduleSnooze),
                          const Icon(Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 1, child: Text('1 day')),
                      const PopupMenuItem(value: 3, child: Text('3 days')),
                      const PopupMenuItem(value: 7, child: Text('7 days')),
                    ],
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: onSkip,
                    child: Text(context.l10n.careScheduleSkip),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskIcon(ThemeData theme) {
    if (task.status == CareTaskStatus.justCompleted) {
      return const Icon(
        Icons.check_circle,
        size: 32,
        color: Colors.grey,
      );
    }

    IconData iconData;
    switch (task.taskType.builtIn) {
      case BuiltInTaskType.watering:
        iconData = Icons.water_drop;
        break;
      case BuiltInTaskType.fertilizing:
        iconData = Icons.science;
        break;
      case BuiltInTaskType.misting:
        iconData = Icons.water;
        break;
      case BuiltInTaskType.pruning:
        iconData = Icons.content_cut;
        break;
      case BuiltInTaskType.rotating:
        iconData = Icons.rotate_right;
        break;
      case BuiltInTaskType.repotting:
        iconData = Icons.yard;
        break;
      case BuiltInTaskType.leafCleaning:
        iconData = Icons.cleaning_services;
        break;
      case BuiltInTaskType.pestInspection:
        iconData = Icons.bug_report;
        break;
      case null:
        iconData = Icons.task_alt;
        break;
    }

    return Icon(
      iconData,
      size: 32,
      color: task.status == CareTaskStatus.overdue
          ? Colors.red
          : task.status == CareTaskStatus.dueToday
              ? Colors.orange
              : Colors.green,
    );
  }

  Widget _buildStatusBadge(
    BuildContext context,
    ThemeData theme,
    DateTime today,
    bool isOverdue,
    bool isDueToday,
  ) {
    final days = task.daysUntilDue(today);

    if (task.status == CareTaskStatus.justCompleted) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Text(
          days <= 0
              ? context.l10n.careScheduleCompletedDueAgainToday
              : context.l10n.careScheduleCompletedEarlyNextDue(days),
          style: TextStyle(
            color: Colors.green.shade700,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (isOverdue) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Text(
          'Overdue by ${-days} days',
          style: TextStyle(
            color: Colors.red.shade700,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (isDueToday) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade200),
        ),
        child: Text(
          'Due today',
          style: TextStyle(
            color: Colors.orange.shade700,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Text(
        'Due in $days days',
        style: TextStyle(
          color: Colors.green.shade700,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
