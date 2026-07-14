import 'package:flutter/material.dart';

import 'package:open_plants/l10n/l10n_x.dart';
import 'package:open_plants/pages/plant_identification/classifier/classification_result.dart';
import 'package:open_plants/pages/plant_identification/widgets/species_result_card.dart';

/// An inline picker that displays identification results as tappable cards.
///
/// The user can tap a result to select it, or type a custom species name
/// in the manual entry field at the bottom. When [onSelected] fires, the
/// picker collapses to a summary label showing the selected species.
/// The [onSkip] callback allows the user to dismiss the picker entirely
/// and type directly in the species field.
class IdentificationPicker extends StatefulWidget {
  final List<SpeciesPrediction> predictions;
  final ValueChanged<String> onSelected;
  final VoidCallback? onSkip;

  const IdentificationPicker({
    super.key,
    required this.predictions,
    required this.onSelected,
    this.onSkip,
  });

  @override
  State<IdentificationPicker> createState() => _IdentificationPickerState();
}

class _IdentificationPickerState extends State<IdentificationPicker> {
  final _manualController = TextEditingController();

  @override
  void dispose() {
    _manualController.dispose();
    super.dispose();
  }

  void _selectSpecies(String name) {
    widget.onSelected(name);
  }

  void _submitManualEntry() {
    final text = _manualController.text.trim();
    if (text.isNotEmpty) {
      _selectSpecies(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            context.l10n.plantIdSelectSpecies,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Results list
        if (widget.predictions.isNotEmpty) ...[
          ...List.generate(widget.predictions.length, (index) {
            final prediction = widget.predictions[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SpeciesResultCard(
                prediction: prediction,
                isTopResult: index == 0,
                onTap: () => _selectSpecies(prediction.name),
              ),
            );
          }),
        ] else ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              context.l10n.plantIdCouldNotIdentifyEnterManually,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],

        // Manual entry
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _manualController,
                decoration: InputDecoration(
                  hintText: context.l10n.plantIdEnterSpeciesManually,
                  border: const OutlineInputBorder(),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  suffixIcon: _manualController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _manualController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _submitManualEntry(),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _manualController.text.trim().isEmpty ? null : _submitManualEntry,
              icon: const Icon(Icons.check, size: 20),
              tooltip: context.l10n.plantIdEnterSpeciesManually,
            ),
          ],
        ),

        // Skip identification option
        if (widget.onSkip != null) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: widget.onSkip,
            child: Text(context.l10n.plantIdSkipIdentification),
          ),
        ],
      ],
    );
  }
}
