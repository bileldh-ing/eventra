import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/live_event_stats.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Headline price, or "Sold out" once the live stock runs out.
class EventPriceLabel extends ConsumerWidget {
  const EventPriceLabel({required this.event, required this.style, super.key});

  final Event event;
  final TextStyle style;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(eventStockProvider(event));
    if (stock.soldOut) {
      return Text(
        context.l10n.soldOutLower,
        key: ValueKey('sold-out-${event.id}'),
        style: style.copyWith(color: context.tokens.textHint),
      );
    }
    return Text(formatPrice(event.price), style: style);
  }
}

/// Small pill: "Sold out" or "Only N left" from the live stock; nothing
/// while plenty of seats remain.
class EventStockBadge extends ConsumerWidget {
  const EventStockBadge({required this.event, super.key, this.onPhoto = false});

  final Event event;

  /// Drawn over a cover photo (solid background for contrast).
  final bool onPhoto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stock = ref.watch(eventStockProvider(event));
    if (!stock.soldOut && !stock.lowStock) return const SizedBox.shrink();
    final t = context.tokens;
    final label = stock.soldOut
        ? context.l10n.soldOutLower
        : context.l10n.tpOnlyLeft(formatDecimal(stock.left, 0));
    final bg = stock.soldOut ? t.textSecondary : t.accentOrange;
    return Container(
      key: ValueKey('stock-${event.id}'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: onPhoto ? bg : bg.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.text.caption.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: onPhoto ? Colors.white : bg,
        ),
      ),
    );
  }
}

/// "★ 4.7 (3)": the live review average when reviews exist, otherwise the
/// catalogue aggregate; nothing for an event without any rating.
class EventRatingLabel extends ConsumerWidget {
  const EventRatingLabel({required this.event, super.key});

  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(eventRatingProvider(event));
    if (r.count == 0) return const SizedBox.shrink();
    final t = context.tokens;
    final avg = formatDecimal(r.average);
    return Semantics(
      label: context.l10n.a11yRating(avg, formatDecimal(r.count, 0)),
      excludeSemantics: true,
      child: Row(
        key: ValueKey('rating-${event.id}'),
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: t.accentOrange),
          const SizedBox(width: 2),
          Text(
            '$avg (${formatDecimal(r.count, 0)})',
            style: context.text.caption.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
