import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/tickets/domain/money.dart';
import 'package:eventra/features/tickets/domain/pricing.dart';
import 'package:eventra/features/tickets/domain/tier_rules.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticketing_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Choose tiers and quantities. Availability is live (other buyers' holds
/// count), steppers respect per-tier and per-order limits, and the bottom
/// bar shows the running total with fees and tax.
class TierPickerScreen extends ConsumerStatefulWidget {
  const TierPickerScreen({required this.eventId, super.key});
  final String eventId;

  @override
  ConsumerState<TierPickerScreen> createState() => _TierPickerScreenState();
}

class _TierPickerScreenState extends ConsumerState<TierPickerScreen> {
  final _selection = <String, int>{};
  bool _busy = false;

  int get _count => _selection.values.fold(0, (s, v) => s + v);

  /// Most this tier's stepper may reach given the rest of the selection.
  int _maxFor(TierAvailability tier) =>
      clampSelection(selection: _selection, tier: tier, wanted: 1 << 20);

  void _set(TierAvailability tier, int wanted) => setState(
    () => _selection[tier.tierId] = clampSelection(
      selection: _selection,
      tier: tier,
      wanted: wanted,
    ),
  );

  Future<void> _continue(Event event) async {
    final user = ref.read(authControllerProvider).user;
    if (user == null || _busy) return;
    setState(() => _busy = true);
    final r = await ref
        .read(ticketingActionsProvider)
        .hold(userId: user.id, event: event, quantities: {..._selection});
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case Success(:final value):
        await context.push('/checkout/${value.id}');
        if (!mounted) return;
        // Back from checkout (cancelled or expired): refresh the counts and
        // drop anything no longer available.
        ref.invalidate(tierAvailabilityProvider(widget.eventId));
      case Failure(:final failure):
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(failure.message)));
        ref.invalidate(tierAvailabilityProvider(widget.eventId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final event = ref.watch(eventByIdProvider(widget.eventId));
    final tiers = ref.watch(tierAvailabilityProvider(widget.eventId));
    final now = ref.watch(clockProvider)();

    Widget body;
    if (event.hasError || tiers.hasError) {
      body = MessageView.error(
        message: 'We could not load the tickets for this event.',
        onRetry: () => ref.invalidate(tierAvailabilityProvider(widget.eventId)),
      );
    } else if (!event.hasValue || !tiers.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else {
      final e = event.value!;
      final list = tiers.value!;
      // Selections never exceed what is still available.
      for (final a in list) {
        final q = _selection[a.tierId] ?? 0;
        if (q > a.maxSelectable) _selection[a.tierId] = a.maxSelectable;
      }
      final ended = !now.isBefore(e.startAt);
      body = ListView(
        key: const ValueKey('tier-list'),
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          _EventStrip(event: e),
          const SizedBox(height: 18),
          if (ended)
            const InlineBanner(
              message: 'This event has started; tickets are no longer sold.',
            )
          else
            for (final a in list) ...[
              _TierCard(
                tier: a,
                quantity: _selection[a.tierId] ?? 0,
                max: _maxFor(a),
                onChanged: (q) => _set(a, q),
              ),
              const SizedBox(height: 14),
            ],
          const SizedBox(height: 4),
          if (_count >= kMaxTicketsPerOrder) ...[
            const InlineBanner(
              key: ValueKey('order-cap'),
              icon: Icons.info_outline_rounded,
              message:
                  'You reached the $kMaxTicketsPerOrder-ticket limit for one '
                  'order.',
            ),
            const SizedBox(height: 10),
          ],
          Text(
            'Up to $kMaxTicketsPerOrder tickets per order. Seats are held '
            'for 10 minutes once you continue.',
            textAlign: TextAlign.center,
            style: EventraText.caption.copyWith(color: t.textHint),
          ),
        ],
      );
    }

    final e = event.value;
    final list = tiers.value ?? const <TierAvailability>[];
    final quote = priceOrder([
      for (final a in list)
        PriceLine(
          tierId: a.tierId,
          tierName: a.tier.name,
          unitCents: a.unitCents,
          quantity: _selection[a.tierId] ?? 0,
        ),
    ]);

    return Scaffold(
      backgroundColor: t.background,
      body: Column(
        children: [
          TicketingHeader(
            title: 'Get a Ticket',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(child: body),
          if (e != null && list.isNotEmpty && now.isBefore(e.startAt))
            _SummaryBar(
              quote: quote,
              busy: _busy,
              onContinue: _count == 0 ? null : () => _continue(e),
            ),
        ],
      ),
    );
  }
}

class _EventStrip extends StatelessWidget {
  const _EventStrip({required this.event});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SectionCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(t.radii.thumbnail),
            child: SizedBox.square(
              dimension: 72,
              child: EventImage(
                url: event.coverImageUrl,
                category: event.category,
                cacheWidth: 216,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: EventraText.cardTitle.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  formatCardDate(event.startAt),
                  style: EventraText.caption.copyWith(color: t.primary),
                ),
                Text(
                  event.venue,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: EventraText.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TierCard extends StatelessWidget {
  const _TierCard({
    required this.tier,
    required this.quantity,
    required this.max,
    required this.onChanged,
  });

  final TierAvailability tier;
  final int quantity;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final selected = quantity > 0;
    final soldOut = tier.soldOut;
    return AnimatedContainer(
      key: ValueKey('tier-${tier.tierId}'),
      duration: t.motion.medium,
      curve: t.motion.standard,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: soldOut ? const Color(0xFFF6F4F9) : t.surface,
        borderRadius: BorderRadius.circular(t.radii.listCard),
        border: Border.all(
          color: selected ? t.primary : Colors.transparent,
          width: 1.5,
        ),
        boxShadow: soldOut ? null : t.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tier.tier.name,
                      style: EventraText.cardTitle.copyWith(
                        fontSize: 18,
                        color: soldOut ? t.textHint : t.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      tier.unitCents == 0
                          ? 'Free'
                          : formatCents(tier.unitCents),
                      style: EventraText.cardTitle.copyWith(
                        fontSize: 20,
                        color: soldOut ? t.textHint : t.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              if (soldOut)
                StatusChip(
                  key: ValueKey('soldout-${tier.tierId}'),
                  label: 'Sold out',
                  color: t.textSecondary,
                )
              else
                QuantityStepper(
                  keyPrefix: 'tier-${tier.tierId}',
                  value: quantity,
                  max: max,
                  onChanged: onChanged,
                ),
            ],
          ),
          if (tier.tier.perks.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                for (final p in tier.tier.perks)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 16,
                        color: soldOut ? t.textHint : t.success,
                      ),
                      const SizedBox(width: 4),
                      Text(p, style: EventraText.caption),
                    ],
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: tier.soldFraction,
              minHeight: 6,
              backgroundColor: t.primary.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(
                soldOut
                    ? t.textHint
                    : tier.lowStock
                    ? t.accentOrange
                    : t.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  soldOut
                      ? 'All ${tier.capacity} tickets are gone'
                      : '${tier.available} of ${tier.capacity} left',
                  key: ValueKey('remaining-${tier.tierId}'),
                  style: EventraText.caption,
                ),
              ),
              if (tier.lowStock)
                StatusChip(
                  key: ValueKey('lowstock-${tier.tierId}'),
                  label: 'Only ${tier.available} left',
                  color: t.accentOrange,
                  icon: Icons.local_fire_department_rounded,
                )
              else if (!soldOut)
                Text(
                  'Max ${tier.maxSelectable} per order',
                  style: EventraText.caption.copyWith(color: t.textHint),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({
    required this.quote,
    required this.busy,
    required this.onContinue,
  });

  final PriceQuote quote;
  final bool busy;
  final VoidCallback? onContinue;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final n = quote.ticketCount;
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        16 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x149A5BD6),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedSize(
            duration: t.motion.medium,
            curve: t.motion.standard,
            child: n == 0
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      'Choose your tickets to see the total.',
                      style: EventraText.body.copyWith(color: t.textHint),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      children: [
                        AmountRow(
                          label: '$n ${n == 1 ? 'ticket' : 'tickets'}',
                          cents: quote.subtotalCents,
                          valueKey: const ValueKey('picker-subtotal'),
                        ),
                        AmountRow(
                          label: 'Fees and tax',
                          cents: quote.feesCents + quote.taxCents,
                          valueKey: const ValueKey('picker-fees'),
                        ),
                        AmountRow(
                          label: 'Total',
                          cents: quote.totalCents,
                          emphasize: true,
                          valueKey: const ValueKey('picker-total'),
                        ),
                      ],
                    ),
                  ),
          ),
          GradientPillButton(
            key: const ValueKey('tier-continue'),
            label: busy ? 'Holding your seats…' : 'Continue to checkout',
            icon: busy ? null : Icons.lock_clock_rounded,
            onPressed: busy ? null : onContinue,
          ),
        ],
      ),
    );
  }
}
