import 'package:flutter/material.dart';

class AppIconButton extends StatelessWidget {
  final IconData icon;

  final VoidCallback onTap;

  final Color? backgroundColor;
  final Color? borderColor;

  final bool transparent;

  const AppIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.backgroundColor,
    this.borderColor,
    this.transparent = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(15),
        border: !transparent
            ? Border.all(
                color: borderColor ?? colorScheme.surfaceContainerHighest,
                width: 2,
              )
            : null,
      ),
      child: Material(
        color: backgroundColor ?? theme.cardColor,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          splashColor: colorScheme.onSurface.withValues(alpha: 0.04),
          highlightColor: colorScheme.onSurface.withValues(alpha: 0.02),
          borderRadius: BorderRadius.circular(15),
          child: Center(
            child: Icon(
              icon,
              size: 22,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
