import 'package:flutter/material.dart';

import 'package:open_plant/pages/plant_identification/classifier/classification_result.dart';

/// Displays a single species prediction with name and confidence percentage.
///
/// The top-1 result is visually distinguished with an accent color and label.
class SpeciesResultCard extends StatelessWidget {
  final SpeciesPrediction prediction;
  final bool isTopResult;
  final String? topResultLabel;

  const SpeciesResultCard({
    super.key,
    required this.prediction,
    this.isTopResult = false,
    this.topResultLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final confidencePercent = (prediction.confidence * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isTopResult
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.3)
            : theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: isTopResult
            ? Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
                width: 1.5,
              )
            : null,
      ),
      child: Row(
        children: [
          if (isTopResult)
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
                if (isTopResult)
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
  }
}
