import 'package:flutter/material.dart';

import 'package:open_plants/pages/plant_identification/classifier/classification_result.dart';

/// Displays a single species prediction with name and confidence percentage.
///
/// The top-1 result is visually distinguished with an accent color and label.
/// When [onTap] is provided, the card becomes tappable and shows a radio-button
/// selection indicator when [isSelected] is true.
class SpeciesResultCard extends StatelessWidget {
  final SpeciesPrediction prediction;
  final bool isTopResult;
  final String? topResultLabel;
  final VoidCallback? onTap;
  final bool isSelected;

  const SpeciesResultCard({
    super.key,
    required this.prediction,
    this.isTopResult = false,
    this.topResultLabel,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidencePercent = (prediction.confidence * 100).toStringAsFixed(1);
    final isInteractive = onTap != null;

    final card = Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
            : isTopResult
                ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
                : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? theme.colorScheme.primary
              : isTopResult
                  ? theme.colorScheme.primary.withValues(alpha: 0.5)
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
          width: isSelected
              ? 2
              : isTopResult
                  ? 1.5
                  : 1,
        ),
      ),
      child: Row(
        children: [
          if (isInteractive)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            )
          else if (isTopResult)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(
                Icons.star,
                color: theme.colorScheme.primary,
                size: 18,
              ),
            ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  prediction.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: isTopResult ? FontWeight.bold : FontWeight.normal,
                    color: isTopResult ? theme.colorScheme.primary : null,
                  ),
                ),
                if (isTopResult && !isInteractive)
                  Text(
                    topResultLabel ?? 'Best match',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '$confidencePercent%',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: isTopResult ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );

    if (isInteractive) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: card,
      );
    }

    return card;
  }
}
