import 'dart:math' as math;

import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/features/organizer/domain/dashboard.dart';
import 'package:flutter/material.dart';

/// Daily tickets sold as a smooth area chart with a highlighted last point.
/// Drawn with a [CustomPainter] (no chart dependency).
class SalesLineChart extends StatelessWidget {
  const SalesLineChart({
    required this.series,
    required this.tokens,
    super.key,
    this.height = 150,
    this.labelFor,
  });

  final List<DaySales> series;
  final EventraTokens tokens;
  final double height;

  /// Axis label for a day (first, middle and last are drawn).
  final String Function(DateTime day)? labelFor;

  @override
  Widget build(BuildContext context) {
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final labels = labelFor;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: CustomPaint(
            painter: SalesLinePainter(
              values: [for (final d in series) d.tickets],
              line: tokens.primary,
              fill: tokens.primary,
              grid: tokens.outline,
              dot: tokens.surface,
              mirror: rtl,
            ),
          ),
        ),
        if (labels != null && series.length >= 2) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (final d in [
                series.first,
                series[series.length ~/ 2],
                series.last,
              ])
                Text(
                  labels(d.day),
                  style: TextStyle(fontSize: 12, color: tokens.textHint),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class SalesLinePainter extends CustomPainter {
  SalesLinePainter({
    required this.values,
    required this.line,
    required this.fill,
    required this.grid,
    required this.dot,
    this.mirror = false,
  });

  final List<int> values;
  final Color line;
  final Color fill;
  final Color grid;
  final Color dot;

  /// Right-to-left: time runs from the right edge.
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1;
    for (var i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
    if (values.length < 2) return;
    final maxV = math.max(1, values.reduce(math.max)).toDouble();
    const pad = 6.0;
    final h = size.height - pad * 2;
    Offset at(int i) {
      final t = i / (values.length - 1);
      final x = (mirror ? 1 - t : t) * size.width;
      return Offset(x, pad + h - values[i] / maxV * h);
    }

    final path = Path()..moveTo(at(0).dx, at(0).dy);
    for (var i = 1; i < values.length; i++) {
      final p0 = at(i - 1);
      final p1 = at(i);
      final mx = (p0.dx + p1.dx) / 2;
      path.cubicTo(mx, p0.dy, mx, p1.dy, p1.dx, p1.dy);
    }
    final area = Path.from(path)
      ..lineTo(at(values.length - 1).dx, size.height)
      ..lineTo(at(0).dx, size.height)
      ..close();
    canvas
      ..drawPath(
        area,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [fill.withValues(alpha: 0.32), fill.withValues(alpha: 0)],
          ).createShader(Offset.zero & size),
      )
      ..drawPath(
        path,
        Paint()
          ..color = line
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    final last = at(values.length - 1);
    canvas
      ..drawCircle(last, 6, Paint()..color = line)
      ..drawCircle(last, 3, Paint()..color = dot);
  }

  @override
  bool shouldRepaint(SalesLinePainter old) =>
      old.line != line ||
      old.grid != grid ||
      old.mirror != mirror ||
      !_same(old.values, values);

  static bool _same(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}

/// A rounded horizontal fill bar (tier sell-through, check-in progress).
class FillBar extends StatelessWidget {
  const FillBar({
    required this.value,
    required this.color,
    required this.track,
    super.key,
    this.height = 8,
  });

  final double value;
  final Color color;
  final Color track;
  final double height;

  @override
  Widget build(BuildContext context) => DirectionalFlip(
    child: SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _FillBarPainter(value.clamp(0, 1), color, track),
      ),
    ),
  );
}

class _FillBarPainter extends CustomPainter {
  _FillBarPainter(this.value, this.color, this.track);
  final double value;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Radius.circular(size.height / 2);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, r),
      Paint()..color = track,
    );
    if (value <= 0) return;
    final w = math.max(size.height, size.width * value);
    // Grows from the left; [FillBar] flips it to grow from the right in RTL.
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, size.height), r),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_FillBarPainter old) =>
      old.value != value || old.color != color || old.track != track;
}

/// Mirrors its child horizontally in right-to-left layouts.
class DirectionalFlip extends StatelessWidget {
  const DirectionalFlip({required this.child, super.key});
  final Widget child;

  @override
  Widget build(BuildContext context) =>
      Directionality.of(context) == TextDirection.rtl
      ? Transform.flip(flipX: true, child: child)
      : child;
}
