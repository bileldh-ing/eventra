import 'dart:async';

import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum _Phase { idle, loading, done }

/// 'Get a Ticket': press squash, short loading ring, then a check mark that
/// draws itself before [onConfirmed] navigates.
class TicketButton extends StatefulWidget {
  const TicketButton({
    required this.onConfirmed,
    super.key,
    this.label = 'Get a Ticket',
  });

  final VoidCallback onConfirmed;
  final String label;

  @override
  State<TicketButton> createState() => _TicketButtonState();
}

class _TicketButtonState extends State<TicketButton> {
  _Phase _phase = _Phase.idle;
  bool _pressed = false;

  Future<void> _run() async {
    if (_phase != _Phase.idle) return;
    unawaited(HapticFeedback.mediumImpact());
    setState(() => _phase = _Phase.loading);
    await Future<void>.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;
    setState(() => _phase = _Phase.done);
    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) return;
    widget.onConfirmed();
    await Future<void>.delayed(const Duration(milliseconds: 400));
    if (mounted) setState(() => _phase = _Phase.idle);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final content = switch (_phase) {
      _Phase.idle => Text(widget.label, style: EventraText.button),
      _Phase.loading => const SizedBox.square(
        key: ValueKey('ticket-loading'),
        dimension: 26,
        child: CircularProgressIndicator(strokeWidth: 3, color: Colors.white),
      ),
      _Phase.done => TweenAnimationBuilder<double>(
        key: const ValueKey('ticket-done'),
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 360),
        builder: (context, v, _) => CustomPaint(
          size: const Size(28, 28),
          painter: _CheckPainter(v),
        ),
      ),
    };
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        key: const ValueKey('get-ticket'),
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: _run,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: t.motion.fast,
          child: Container(
            height: t.buttonHeight,
            decoration: BoxDecoration(
              gradient: t.primaryGradient,
              borderRadius: BorderRadius.circular(t.buttonHeight / 2),
              boxShadow: t.primaryGlow,
            ),
            alignment: Alignment.center,
            child: AnimatedSwitcher(
              duration: t.motion.fast,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  _CheckPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.18, size.height * 0.52)
      ..lineTo(size.width * 0.42, size.height * 0.74)
      ..lineTo(size.width * 0.84, size.height * 0.28);
    final metric = path.computeMetrics().first;
    canvas.drawPath(
      metric.extractPath(0, metric.length * progress),
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_CheckPainter old) => old.progress != progress;
}
