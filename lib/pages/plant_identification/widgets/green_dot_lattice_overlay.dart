import 'package:flutter/material.dart';

import 'package:open_plant/pages/plant_identification/widgets/green_dot_lattice_painter.dart';

/// Wraps the [GreenDotLatticePainter] in an [AnimatedBuilder] for continuous animation.
///
/// Positioned over the captured image to indicate inference is in progress.
/// Binds to the size of its parent via [LayoutBuilder] so the lattice grid
/// matches the image dimensions exactly.
class GreenDotLatticeOverlay extends StatefulWidget {
  final bool isVisible;

  const GreenDotLatticeOverlay({super.key, required this.isVisible});

  @override
  State<GreenDotLatticeOverlay> createState() => _GreenDotLatticeOverlayState();
}

class _GreenDotLatticeOverlayState extends State<GreenDotLatticeOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    if (widget.isVisible) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(GreenDotLatticeOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isVisible && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return CustomPaint(
              painter: GreenDotLatticePainter(
                animationValue: _controller.value,
              ),
              size: size,
            );
          },
        );
      },
    );
  }
}
