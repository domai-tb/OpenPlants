import 'dart:math';

import 'package:flutter/material.dart';

/// CustomPainter that draws a grid of green dots with staggered pulse animation.
///
/// The dots are arranged in a regular grid pattern and animate with opacity
/// pulsing to convey processing activity.
class GreenDotLatticePainter extends CustomPainter {
  final double animationValue;
  final double dotSpacing;
  final double dotRadius;
  final Color dotColor;

  GreenDotLatticePainter({
    required this.animationValue,
    this.dotSpacing = 20.0,
    this.dotRadius = 3.0,
    this.dotColor = const Color(0xFF4CAF50),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final cols = (size.width / dotSpacing).ceil();
    final rows = (size.height / dotSpacing).ceil();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final x = col * dotSpacing + dotSpacing / 2;
        final y = row * dotSpacing + dotSpacing / 2;

        // Staggered animation: each dot has a phase offset based on position
        final phase = (row + col) * 0.15;
        final t = (animationValue + phase) % 1.0;

        // Pulse: opacity goes from 0.2 to 1.0 and back
        final opacity = 0.2 + 0.8 * (0.5 + 0.5 * sin(t * 2 * pi));

        paint.color = dotColor.withValues(alpha: opacity);

        canvas.drawCircle(
          Offset(x, y),
          dotRadius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant GreenDotLatticePainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
