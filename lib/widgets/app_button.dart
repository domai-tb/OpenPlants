import 'package:flutter/material.dart';

enum AppButtonType { normal, light }

/// Simple app-styled button used by OpenPlant.
class AppButton extends StatelessWidget {
  /// The displayed text inside the button
  final String text;

  final double? width;

  final double height;

  /// The callback that should be executed when the button is tapped
  final VoidCallback onTap;

  /// Controls whether the button is rendered for a normal or light background.
  late final AppButtonType type;

  AppButton({
    super.key,
    required this.text,
    this.width = 330,
    this.height = 58,
    required this.onTap,
  }) {
    type = AppButtonType.normal;
  }

  AppButton.light({
    super.key,
    required this.text,
    this.width = 330,
    this.height = 58,
    required this.onTap,
  }) {
    type = AppButtonType.light;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Material(
        color: type == AppButtonType.normal ? colorScheme.primary : colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          splashColor: (type == AppButtonType.normal
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant)
              .withValues(alpha: 0.12),
          highlightColor: (type == AppButtonType.normal
                  ? colorScheme.onPrimary
                  : colorScheme.onSurfaceVariant)
              .withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Text(
              text,
              style: theme.textTheme.labelMedium?.copyWith(
                color: type == AppButtonType.normal ? colorScheme.onPrimary : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
