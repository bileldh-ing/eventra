import 'dart:async';
import 'dart:math' as math;

import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/features/tickets/domain/money.dart';
import 'package:eventra/features/tickets/domain/pricing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// White rounded card used by every ticketing section.
class SectionCard extends StatelessWidget {
  const SectionCard({
    required this.child,
    super.key,
    this.title,
    this.trailing,
    this.padding = const EdgeInsets.all(20),
  });

  final Widget child;
  final String? title;
  final Widget? trailing;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(t.radii.listCard),
        boxShadow: t.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    title!,
                    style: EventraText.cardTitle.copyWith(fontSize: 18),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 14),
          ],
          child,
        ],
      ),
    );
  }
}

/// Simple page header with a back button, used by the ticketing screens.
class TicketingHeader extends StatelessWidget {
  const TicketingHeader({
    required this.title,
    super.key,
    this.onBack,
    this.trailing,
  });

  final String title;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        MediaQuery.paddingOf(context).top + 8,
        16,
        8,
      ),
      child: Row(
        children: [
          if (onBack != null)
            Semantics(
              button: true,
              label: 'Back',
              child: Pressable(
                key: const ValueKey('ticketing-back'),
                onTap: onBack,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: t.surface,
                    shape: BoxShape.circle,
                    boxShadow: t.softShadow,
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: t.textPrimary,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: EventraText.sectionTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Minus / count / plus stepper with disabled ends.
class QuantityStepper extends StatelessWidget {
  const QuantityStepper({
    required this.value,
    required this.onChanged,
    required this.max,
    required this.keyPrefix,
    super.key,
    this.enabled = true,
  });

  final int value;
  final int max;
  final bool enabled;
  final String keyPrefix;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    Widget button(
      IconData icon,
      String label, {
      required bool on,
      required VoidCallback tap,
    }) => Semantics(
      button: true,
      enabled: on,
      label: label,
      child: Pressable(
        key: ValueKey('$keyPrefix-${icon == Icons.add ? 'plus' : 'minus'}'),
        onTap: on
            ? () {
                HapticFeedback.selectionClick();
                tap();
              }
            : null,
        child: AnimatedContainer(
          duration: t.motion.fast,
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: on && icon == Icons.add ? t.primaryGradient : null,
            color: on
                ? (icon == Icons.add ? null : t.primary.withValues(alpha: 0.1))
                : const Color(0xFFEDEAF2),
          ),
          child: Icon(
            icon,
            size: 20,
            color: on
                ? (icon == Icons.add ? Colors.white : t.primary)
                : t.textHint,
          ),
        ),
      ),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        button(
          Icons.remove,
          'Remove one',
          on: enabled && value > 0,
          tap: () => onChanged(value - 1),
        ),
        SizedBox(
          width: 36,
          child: AnimatedSwitcher(
            duration: t.motion.fast,
            transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
            child: Text(
              '$value',
              key: ValueKey('$keyPrefix-qty-$value'),
              textAlign: TextAlign.center,
              style: EventraText.cardTitle.copyWith(fontSize: 18),
            ),
          ),
        ),
        button(
          Icons.add,
          'Add one',
          on: enabled && value < max,
          tap: () => onChanged(value + 1),
        ),
      ],
    );
  }
}

/// One label / amount row of a price breakdown.
class AmountRow extends StatelessWidget {
  const AmountRow({
    required this.label,
    required this.cents,
    super.key,
    this.emphasize = false,
    this.negative = false,
    this.valueKey,
  });

  final String label;
  final int cents;
  final bool emphasize;
  final bool negative;
  final Key? valueKey;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final style = emphasize
        ? EventraText.cardTitle.copyWith(fontSize: 18)
        : EventraText.body;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            negative ? formatCents(-cents) : formatCents(cents),
            key: valueKey,
            style: style.copyWith(
              color: negative
                  ? t.success
                  : emphasize
                  ? t.primary
                  : t.textPrimary,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Subtotal, discount, fees, tax and total for a quote.
class PriceBreakdown extends StatelessWidget {
  const PriceBreakdown({required this.quote, super.key});
  final PriceQuote quote;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AmountRow(
          label:
              'Subtotal (${quote.ticketCount} '
              '${quote.ticketCount == 1 ? 'ticket' : 'tickets'})',
          cents: quote.subtotalCents,
          valueKey: const ValueKey('amount-subtotal'),
        ),
        if (quote.discountCents > 0)
          AmountRow(
            label: 'Promo ${quote.promo?.code ?? ''}'.trim(),
            cents: quote.discountCents,
            negative: true,
            valueKey: const ValueKey('amount-discount'),
          ),
        AmountRow(
          label: 'Service fees',
          cents: quote.feesCents,
          valueKey: const ValueKey('amount-fees'),
        ),
        AmountRow(
          label: 'Tax',
          cents: quote.taxCents,
          valueKey: const ValueKey('amount-tax'),
        ),
        const Divider(height: 20),
        AmountRow(
          label: 'Total',
          cents: quote.totalCents,
          emphasize: true,
          valueKey: const ValueKey('amount-total'),
        ),
      ],
    );
  }
}

/// Small rounded status chip ("Valid", "Sold out", "Only 3 left").
class StatusChip extends StatelessWidget {
  const StatusChip({
    required this.label,
    required this.color,
    super.key,
    this.icon,
  });

  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: EventraText.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ticks every second while mounted and rebuilds with the current time from
/// [clock]. Used by hold and QR countdowns.
class ClockTicker extends StatefulWidget {
  const ClockTicker({
    required this.clock,
    required this.builder,
    super.key,
    this.interval = const Duration(seconds: 1),
  });

  final DateTime Function() clock;
  final Widget Function(BuildContext context, DateTime now) builder;
  final Duration interval;

  @override
  State<ClockTicker> createState() => _ClockTickerState();
}

class _ClockTickerState extends State<ClockTicker> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.interval, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, widget.clock());
}

/// Circular countdown ring with text in the middle; its colour moves from
/// the brand purple to orange and red as time runs out.
class CountdownRing extends StatelessWidget {
  const CountdownRing({
    required this.fraction,
    required this.label,
    super.key,
    this.size = 44,
    this.color,
    this.stroke = 4,
  });

  /// Time left, 1 (full) to 0.
  final double fraction;
  final String label;
  final double size;
  final double stroke;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final c = color ?? t.primary;
    return SizedBox.square(
      dimension: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: fraction.clamp(0, 1)),
        duration: const Duration(milliseconds: 600),
        builder: (context, v, _) => CustomPaint(
          painter: _RingPainter(v, c, stroke),
          child: Center(
            child: Text(
              label,
              style: EventraText.caption.copyWith(
                color: c,
                fontWeight: FontWeight.w700,
                fontSize: size < 50 ? 12 : 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter(this.value, this.color, this.stroke);
  final double value;
  final Color color;
  final double stroke;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inner = rect.deflate(stroke / 2);
    canvas
      ..drawArc(
        inner,
        0,
        math.pi * 2,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..color = color.withValues(alpha: 0.15),
      )
      ..drawArc(
        inner,
        -math.pi / 2,
        math.pi * 2 * value,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = stroke
          ..strokeCap = StrokeCap.round
          ..color = color,
      );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.value != value || old.color != color;
}

/// Ticket outline: rounded rectangle with two half-circle notches cut at
/// [notchY] (the perforation line).
class TicketShapeBorder extends ShapeBorder {
  const TicketShapeBorder({
    required this.notchY,
    this.radius = 28,
    this.notchRadius = 14,
  });

  final double notchY;
  final double radius;
  final double notchRadius;

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect, textDirection: textDirection);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final y = rect.top + notchY;
    final body = Path()
      ..addRRect(RRect.fromRectAndRadius(rect, Radius.circular(radius)));
    final notches = Path()
      ..addOval(
        Rect.fromCircle(center: Offset(rect.left, y), radius: notchRadius),
      )
      ..addOval(
        Rect.fromCircle(center: Offset(rect.right, y), radius: notchRadius),
      );
    return Path.combine(PathOperation.difference, body, notches);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => TicketShapeBorder(
    notchY: notchY * t,
    radius: radius * t,
    notchRadius: notchRadius * t,
  );
}

/// Dashed perforation line; [progress] animates the dashes drawing in.
class PerforationLine extends StatelessWidget {
  const PerforationLine({super.key, this.progress = 1, this.color});
  final double progress;
  final Color? color;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 2,
    width: double.infinity,
    child: CustomPaint(
      painter: _DashPainter(
        progress,
        color ?? context.tokens.textHint.withValues(alpha: 0.5),
      ),
    ),
  );
}

class _DashPainter extends CustomPainter {
  _DashPainter(this.progress, this.color);
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;
    const dash = 7.0;
    const gap = 6.0;
    final end = size.width * progress.clamp(0, 1);
    for (var x = 18.0; x < end - 18; x += dash + gap) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset(math.min(x + dash, end - 18), size.height / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) =>
      old.progress != progress || old.color != color;
}

/// Inline error / info banner.
class InlineBanner extends StatelessWidget {
  const InlineBanner({
    required this.message,
    super.key,
    this.icon = Icons.error_outline_rounded,
    this.color,
  });

  final String message;
  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? context.tokens.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: c, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Semantics(
              liveRegion: true,
              child: Text(
                message,
                style: EventraText.caption.copyWith(color: c),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
