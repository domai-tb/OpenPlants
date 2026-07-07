import 'package:flutter/material.dart';

import 'package:open_plant/l10n/l10n_x.dart';

/// Empty state widget shown when no care tasks exist.
class EmptyScheduleState extends StatelessWidget {
  /// Optional callback: navigate to the Plant Collection tab.
  final VoidCallback? onNavigateToPlantCollection;

  const EmptyScheduleState({super.key, this.onNavigateToPlantCollection});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco,
              size: 64,
              color: theme.colorScheme.primary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              context.l10n.careScheduleEmpty,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                onNavigateToPlantCollection?.call();
              },
              icon: const Icon(Icons.yard),
              label: Text(context.l10n.careScheduleGoToCollection),
            ),
          ],
        ),
      ),
    );
  }
}
