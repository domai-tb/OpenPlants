import 'package:flutter/material.dart';

/// Initial state UI with camera and gallery buttons.
///
/// Displayed when no image has been captured yet.
class CapturePrompt extends StatelessWidget {
  final VoidCallback onCameraTap;
  final VoidCallback onGalleryTap;
  final String promptText;
  final String cameraLabel;
  final String galleryLabel;

  const CapturePrompt({
    super.key,
    required this.onCameraTap,
    required this.onGalleryTap,
    required this.promptText,
    required this.cameraLabel,
    required this.galleryLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(height: 24),
          Text(
            promptText,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _CaptureButton(
                icon: Icons.camera_alt,
                label: cameraLabel,
                onTap: onCameraTap,
              ),
              const SizedBox(width: 24),
              _CaptureButton(
                icon: Icons.photo_library,
                label: galleryLabel,
                onTap: onGalleryTap,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CaptureButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium,
          ),
        ],
      ),
    );
  }
}
