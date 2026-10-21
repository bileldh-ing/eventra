import 'dart:math';

import 'package:flutter/material.dart';

/// Low-poly faceted triangle overlay (white alpha 0.03-0.10), seeded so it is
/// deterministic. [shift] produces a slow parallax offset on scroll.
class FacetedPainter extends CustomPainter {
  FacetedPainter({this.seed = 7, this.shift = 0, this.columns = 6});

  final int seed;
  final double shift;
  final int columns;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = Random(seed);
    final cellW = size.width / columns;
    final rows = (size.height / cellW).ceil() + 2;
    // Jittered grid of vertices.
    final points = List.generate(rows + 1, (r) {
      return List.generate(columns + 2, (c) {
        final jx = (rnd.nextDouble() - 0.5) * cellW * 0.7;
        final jy = (rnd.nextDouble() - 0.5) * cellW * 0.7;
        return Offset(
          (c - 0.5) * cellW + jx,
          (r - 1) * cellW + jy - shift,
        );
      });
    });
    final paint = Paint()..style = PaintingStyle.fill;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < columns + 1; c++) {
        final a = points[r][c];
        final b = points[r][c + 1];
        final d = points[r + 1][c];
        final e = points[r + 1][c + 1];
        for (final tri in [
          [a, b, d],
          [b, e, d],
        ]) {
          final alpha = 0.03 + rnd.nextDouble() * 0.07;
          paint.color = Colors.white.withValues(alpha: alpha);
          final path = Path()
            ..moveTo(tri[0].dx, tri[0].dy)
            ..lineTo(tri[1].dx, tri[1].dy)
            ..lineTo(tri[2].dx, tri[2].dy)
            ..close();
          canvas.drawPath(path, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(FacetedPainter oldDelegate) =>
      oldDelegate.seed != seed ||
      oldDelegate.shift != shift ||
      oldDelegate.columns != columns;
}

/// Gradient block with the faceted overlay, isolated in a RepaintBoundary.
class FacetedGradient extends StatelessWidget {
  const FacetedGradient({
    required this.gradient,
    super.key,
    this.borderRadius = BorderRadius.zero,
    this.shift = 0,
    this.child,
  });

  final Gradient gradient;
  final BorderRadius borderRadius;
  final double shift;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: Stack(
        fit: StackFit.passthrough,
        children: [
          Positioned.fill(
            child: DecoratedBox(decoration: BoxDecoration(gradient: gradient)),
          ),
          Positioned.fill(
            child: RepaintBoundary(
              child: CustomPaint(
                painter: FacetedPainter(shift: shift),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          ?child,
        ],
      ),
    );
  }
}
