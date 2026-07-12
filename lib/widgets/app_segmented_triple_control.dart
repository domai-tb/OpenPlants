import 'package:flutter/material.dart';

/// This widget allows the user to pick between three options.
/// It is a linear set of three segments, each of which functions as a button.
class AppSegmentedTripleControl extends StatefulWidget {
  /// The displayed text on the left button of the SegmentedControl
  final String leftTitle;

  /// The displayed text on the center button of the SegmentedControl
  final String centerTitle;

  /// The displayed text on the right button of the SegmentedControl
  final String rightTitle;

  /// Is executed whenever the switch changes its value.
  /// Returns the new selected value, which can be 0 or 1.
  final void Function(int) onChanged;

  /// Initial selected segment: 0 (left), 1 (center), 2 (right).
  final int initialSelection;

  const AppSegmentedTripleControl({
    super.key,
    required this.leftTitle,
    required this.centerTitle,
    required this.rightTitle,
    required this.onChanged,
    this.initialSelection = 0,
  });

  @override
  State<AppSegmentedTripleControl> createState() => AppSegmentedTripleControlState();
}

class AppSegmentedTripleControlState extends State<AppSegmentedTripleControl> {
  late AlignmentGeometry _hoverAligment;
  static const double _pickerWidth = 300;

  int selected = 0;

  void _picked(int newSelected) {
    if (newSelected != selected) {
      // Execute the `onChanged()` callback
      widget.onChanged(newSelected);

      // Update the visuals
      setState(() {
        selected = newSelected;

        switch (newSelected) {
          case 0:
            _hoverAligment = Alignment.centerLeft;
            break;
          case 1:
            _hoverAligment = Alignment.center;
            break;
          case 2:
            _hoverAligment = Alignment.centerRight;
            break;
        }
      });
    }
  }

  @override
  void initState() {
    super.initState();

    selected = widget.initialSelection.clamp(0, 2);
    switch (selected) {
      case 0:
        _hoverAligment = Alignment.centerLeft;
        break;
      case 1:
        _hoverAligment = Alignment.center;
        break;
      case 2:
        _hoverAligment = Alignment.centerRight;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      height: 42,
      width: _pickerWidth,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          // Selection
          AnimatedAlign(
            alignment: _hoverAligment,
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            child: Container(
              width: (_pickerWidth / 3) - 4,
              height: 32,
              margin: const EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(color: colorScheme.shadow, blurRadius: 5),
                ],
              ),
            ),
          ),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  widget.leftTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.centerTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  widget.rightTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          // GestureDetector
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _picked(0),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _picked(1),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _picked(2),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
