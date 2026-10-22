import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/tickets/domain/money.dart';
import 'package:eventra/features/tickets/domain/reminders.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticket_visuals.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticketing_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// "You're in!": the ticket slides up and settles with a bounce, the
/// perforation draws in and a holographic shine sweeps across once.
class BookingSuccessScreen extends ConsumerStatefulWidget {
  const BookingSuccessScreen({required this.orderId, super.key});
  final String orderId;

  @override
  ConsumerState<BookingSuccessScreen> createState() =>
      _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends ConsumerState<BookingSuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final order = ref.watch(orderProvider(widget.orderId));
    return PopScope(
      // Back never returns to the finished checkout.
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/tickets');
      },
      child: Scaffold(
        backgroundColor: t.background,
        body: switch (order) {
          AsyncData(value: final Order o) => _content(t, o),
          AsyncData() => MessageView(
            icon: Icons.receipt_long_outlined,
            title: 'Order not found',
            message: 'Your tickets are in My Tickets.',
            actionLabel: 'My Tickets',
            onAction: () => context.go('/tickets'),
          ),
          AsyncError() => MessageView.error(
            message: 'We could not load your order.',
            onRetry: () => ref.invalidate(orderProvider(widget.orderId)),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }

  Widget _content(EventraTokens t, Order o) {
    final e = o.event;
    final now = ref.watch(clockProvider)();
    final reminders = reminderTimes(e.startAt, now).length;
    final slide = CurvedAnimation(
      parent: _c,
      curve: const Interval(0, 0.55, curve: Curves.easeOutBack),
    );
    final dashes = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
    );
    final shine = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.55, 1, curve: Curves.easeInOut),
    );
    final top = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          height: 300 + top,
          child: FacetedGradient(
            gradient: t.headerGradient,
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(t.radii.header),
            ),
            child: const SizedBox.expand(),
          ),
        ),
        ListView(
          key: const ValueKey('success-scroll'),
          padding: EdgeInsets.fromLTRB(24, top + 28, 24, 32),
          children: [
            Text(
              "You're in!",
              key: const ValueKey('success-title'),
              textAlign: TextAlign.center,
              style: EventraText.heroTitle.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              o.totalCents == 0
                  ? '${o.ticketCount} free '
                        '${o.ticketCount == 1 ? 'spot' : 'spots'} reserved'
                  : '${o.ticketCount} '
                        '${o.ticketCount == 1 ? 'ticket' : 'tickets'} · '
                        '${formatCents(o.totalCents)} paid',
              textAlign: TextAlign.center,
              style: EventraText.body.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 28),
            AnimatedBuilder(
              animation: _c,
              builder: (context, child) => Transform.translate(
                offset: Offset(0, (1 - slide.value) * 220),
                child: Opacity(
                  opacity: slide.value.clamp(0, 1),
                  child: child,
                ),
              ),
              child: _SuccessTicket(
                order: o,
                dashes: dashes,
                shine: shine,
              ),
            ),
            const SizedBox(height: 18),
            if (reminders > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_active_outlined,
                    size: 18,
                    color: t.primary,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      reminders == 2
                          ? "We'll remind you 24 hours and 2 hours before."
                          : "We'll remind you 2 hours before.",
                      key: const ValueKey('reminder-note'),
                      style: EventraText.caption,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 22),
            GradientPillButton(
              key: const ValueKey('view-ticket'),
              label: o.ticketCount > 1 ? 'View Tickets' : 'View Ticket',
              icon: Icons.qr_code_2_rounded,
              onPressed: () => o.ticketCount > 1
                  ? context.go('/tickets')
                  : context.go('/tickets/${o.tickets.first.id}'),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _SecondaryButton(
                    key: const ValueKey('success-calendar'),
                    icon: Icons.event_available_rounded,
                    label: 'Add to Calendar',
                    onTap: () => addEventToCalendar(context, ref, e),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SecondaryButton(
                    key: const ValueKey('success-invite'),
                    icon: Icons.group_add_outlined,
                    label: 'Invite Friends',
                    onTap: () => shareTicketInvite(ref, e),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            TextButton(
              key: const ValueKey('success-done'),
              onPressed: () => context.go('/tickets'),
              child: const Text('Done'),
            ),
          ],
        ),
      ],
    );
  }
}

class _SuccessTicket extends StatelessWidget {
  const _SuccessTicket({
    required this.order,
    required this.dashes,
    required this.shine,
  });

  final Order order;
  final Animation<double> dashes;
  final Animation<double> shine;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final e = order.event;
    const photoH = 160.0;
    const infoH = 112.0;
    return Container(
      decoration: ShapeDecoration(
        color: t.surface,
        shape: const TicketShapeBorder(notchY: photoH + infoH),
        shadows: const [
          BoxShadow(
            color: Color(0x339A5BD6),
            blurRadius: 30,
            offset: Offset(0, 14),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: photoH,
                child: EventImage(url: e.coverImageUrl, cacheWidth: 1100),
              ),
              SizedBox(
                height: infoH,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: EventraText.cardTitle,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        ticketDate(e.startAt),
                        style: EventraText.body.copyWith(
                          color: t.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        e.venue,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: EventraText.caption,
                      ),
                    ],
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: dashes,
                builder: (context, _) =>
                    PerforationLine(progress: dashes.value),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 18),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        [
                          for (final l in order.lines)
                            '${l.quantity}× ${l.tierName}',
                        ].join(' · '),
                        style: EventraText.body.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.qr_code_2_rounded, color: t.primary, size: 34),
                  ],
                ),
              ),
            ],
          ),
          // Holographic shine: a soft diagonal band that sweeps once.
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: shine,
                builder: (context, _) {
                  final v = shine.value;
                  if (v == 0 || v == 1) return const SizedBox.shrink();
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment(-1 + v * 3 - 1, -1),
                        end: Alignment(v * 3 - 1, 1),
                        colors: const [
                          Color(0x00FFFFFF),
                          Color(0x55E58CFF),
                          Color(0x668DA7EE),
                          Color(0x00FFFFFF),
                        ],
                        stops: const [0.2, 0.45, 0.55, 0.8],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: t.primary,
        backgroundColor: t.surface,
        side: BorderSide(color: t.primary.withValues(alpha: 0.3)),
        minimumSize: const Size.fromHeight(52),
        shape: const StadiumBorder(),
        textStyle: EventraText.body.copyWith(fontWeight: FontWeight.w700),
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 20),
      label: FittedBox(child: Text(label)),
    );
  }
}
