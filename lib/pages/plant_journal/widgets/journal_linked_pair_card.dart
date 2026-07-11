import 'package:flutter/material.dart';

import 'package:open_plant/pages/plant_journal/plant_journal_item_entity.dart';
import 'package:open_plant/pages/plant_journal/widgets/journal_diagnosis_card.dart';
import 'package:open_plant/pages/plant_journal/widgets/journal_symptom_card.dart';

/// Widget that visually groups a symptom entry with its linked diagnosis result.
///
/// Shows a connector indicator between the two cards to indicate they are
/// related (e.g., a symptom that triggered a diagnosis).
class JournalLinkedPairCard extends StatelessWidget {
  final JournalEntry symptomEntry;
  final JournalEntry diagnosisEntry;
  final VoidCallback? onSymptomTap;
  final VoidCallback? onDiagnosisTap;
  final VoidCallback? onMarkResolved;

  const JournalLinkedPairCard({
    super.key,
    required this.symptomEntry,
    required this.diagnosisEntry,
    this.onSymptomTap,
    this.onDiagnosisTap,
    this.onMarkResolved,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Symptom card
        JournalSymptomCard(
          entry: symptomEntry,
          onTap: onSymptomTap,
          onResolvedTap: onMarkResolved,
        ),

        // Connector line
        Padding(
          padding: const EdgeInsets.only(left: 24),
          child: Row(
            children: [
              Container(
                width: 2,
                height: 24,
                color: theme.colorScheme.primary.withValues(alpha: 0.3),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.call_made,
                size: 14,
                color: theme.colorScheme.primary.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),

        // Diagnosis card
        JournalDiagnosisCard(
          entry: diagnosisEntry,
          onTap: onDiagnosisTap,
        ),
      ],
    );
  }
}
