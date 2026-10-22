import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/tickets/domain/device_services.dart';
import 'package:eventra/features/tickets/domain/money.dart';
import 'package:eventra/features/tickets/domain/refund_policy.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticket_visuals.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticketing_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Full ticket: signed rotating QR, brightness at max while open, calendar,
/// directions, invite, order details and refund per policy. Reads only the
/// local database, so it works offline.
class TicketDetailScreen extends ConsumerStatefulWidget {
  const TicketDetailScreen({required this.ticketId, super.key});
  final String ticketId;

  @override
  ConsumerState<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends ConsumerState<TicketDetailScreen> {
  late final BrightnessController _brightness;
  bool _refunding = false;

  @override
  void initState() {
    super.initState();
    _brightness = ref.read(brightnessControllerProvider);
    _brightness.boost();
  }

  @override
  void dispose() {
    _brightness.restore();
    super.dispose();
  }

  Future<void> _refund(TicketEntry entry, RefundDecision decision) async {
    final order = entry.order;
    final paid = order.totalCents > 0;
    final card = order.cardLast4 == null ? '' : ' •••• ${order.cardLast4}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(paid ? 'Request a refund?' : 'Cancel reservation?'),
        content: Text(
          paid
              ? 'All ${order.ticketCount} tickets in this order will be '
                    'cancelled and ${formatCents(decision.refundCents)} goes '
                    'back to your ${order.cardBrand ?? 'card'}$card.'
              : 'Your ${order.ticketCount == 1 ? 'spot' : 'spots'} will be '
                    'released for other fans.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep tickets'),
          ),
          TextButton(
            key: const ValueKey('confirm-refund'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(paid ? 'Refund' : 'Cancel reservation'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final user = ref.read(authControllerProvider).user;
    if (user == null) return;
    setState(() => _refunding = true);
    final r = await ref
        .read(ticketingActionsProvider)
        .refund(order.id, userId: user.id);
    if (!mounted) return;
    setState(() => _refunding = false);
    final message = switch (r) {
      Success(value: final o) =>
        o.refundCents > 0
            ? 'Refunded ${formatCents(o.refundCents)}. Your tickets were '
                  'cancelled.'
            : 'Reservation cancelled.',
      Failure(:final failure) => failure.message,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final entry = ref.watch(ticketEntryProvider(widget.ticketId));
    final now = ref.watch(clockProvider)();
    return Scaffold(
      backgroundColor: t.background,
      body: Column(
        children: [
          TicketingHeader(
            title: 'Your Ticket',
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: switch (entry) {
              AsyncError() => MessageView.error(
                message: 'We could not open this ticket.',
                onRetry: () =>
                    ref.invalidate(ticketEntryProvider(widget.ticketId)),
              ),
              AsyncData(value: null) => MessageView(
                icon: Icons.confirmation_number_outlined,
                title: 'Ticket not found',
                message: 'It may belong to another account.',
                actionLabel: 'My Tickets',
                onAction: () => context.go('/tickets'),
              ),
              AsyncData(value: final TicketEntry e) => _content(t, e, now),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ],
      ),
    );
  }

  Widget _content(EventraTokens t, TicketEntry entry, DateTime now) {
    final e = entry.event;
    final order = entry.order;
    final status = ticketStatusLabel(entry, now);
    final valid = status == 'Valid';
    final decision = RefundPolicy.evaluate(
      eventStart: e.startAt,
      now: now,
      paidCents: order.totalCents,
    );
    return ListView(
      key: const ValueKey('ticket-detail-scroll'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      children: [
        _TicketBody(entry: entry, status: status, valid: valid),
        const SizedBox(height: 22),
        Row(
          children: [
            TicketAction(
              key: const ValueKey('ticket-calendar'),
              icon: Icons.event_available_rounded,
              label: 'Add to\nCalendar',
              onTap: () => addEventToCalendar(context, ref, e),
            ),
            TicketAction(
              key: const ValueKey('ticket-directions'),
              icon: Icons.directions_rounded,
              label: 'Directions',
              onTap: () => openDirections(context, e),
            ),
            TicketAction(
              key: const ValueKey('ticket-share'),
              icon: Icons.ios_share_rounded,
              label: 'Invite\nfriends',
              onTap: () => shareTicketInvite(ref, e),
            ),
            TicketAction(
              key: const ValueKey('ticket-event'),
              icon: Icons.info_outline_rounded,
              label: 'Event\ndetails',
              onTap: () => context.push('/tickets/event/${e.id}'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionCard(
          title: 'Order',
          trailing: StatusChip(
            label: order.status == OrderStatus.refunded ? 'Refunded' : 'Paid',
            color: order.status == OrderStatus.refunded ? t.error : t.success,
          ),
          child: Column(
            children: [
              _InfoRow('Order', _orderNumber(order.id)),
              _InfoRow(
                'Booked',
                DateFormat('MMM d, y · h:mm a').format(order.createdAt),
              ),
              for (final l in order.lines)
                _InfoRow(
                  '${l.quantity}× ${l.tierName}',
                  l.unitCents == 0 ? 'Free' : formatCents(l.subtotalCents),
                ),
              if (order.discountCents > 0)
                _InfoRow(
                  'Promo ${order.promoCode ?? ''}',
                  formatCents(-order.discountCents),
                ),
              _InfoRow(
                'Fees and tax',
                formatCents(order.feesCents + order.taxCents),
              ),
              _InfoRow('Total paid', formatCents(order.totalCents), bold: true),
              if (order.cardLast4 != null)
                _InfoRow(
                  'Paid with',
                  '${order.cardBrand} •••• ${order.cardLast4}',
                ),
              if (order.status == OrderStatus.refunded)
                _InfoRow(
                  'Refunded',
                  [
                    formatCents(order.refundCents),
                    if (order.refundedAt case final at?)
                      DateFormat('MMM d').format(at),
                  ].join(' · '),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (order.status == OrderStatus.paid) ...[
          SectionCard(
            title: 'Refund policy',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(RefundPolicy.summary, style: EventraText.body),
                const SizedBox(height: 10),
                Text(
                  decision.allowed && decision.deadline != null
                      ? '${decision.reason} '
                            '(${_deadline.format(decision.deadline!)})'
                      : decision.reason,
                  key: const ValueKey('refund-reason'),
                  style: EventraText.caption.copyWith(
                    color: decision.allowed ? t.success : t.textSecondary,
                  ),
                ),
                if (decision.allowed) ...[
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    key: const ValueKey('request-refund'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: t.error,
                      side: BorderSide(color: t.error.withValues(alpha: 0.4)),
                      minimumSize: const Size.fromHeight(50),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: _refunding
                        ? null
                        : () => _refund(entry, decision),
                    icon: const Icon(Icons.undo_rounded),
                    label: Text(
                      _refunding
                          ? 'Processing…'
                          : order.totalCents > 0
                          ? 'Request refund · '
                                '${formatCents(decision.refundCents)}'
                          : 'Cancel reservation',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

final _deadline = DateFormat('MMM d, h:mm a');

/// Short, readable order number ('ord_Ab3x…' -> 'AB3X9K2Q').
String _orderNumber(String id) {
  final raw = id.replaceFirst('ord_', '').toUpperCase();
  return raw.length > 8 ? raw.substring(0, 8) : raw;
}

class _TicketBody extends StatelessWidget {
  const _TicketBody({
    required this.entry,
    required this.status,
    required this.valid,
  });

  final TicketEntry entry;
  final String status;
  final bool valid;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final e = entry.event;
    const photoH = 150.0;
    const infoH = 136.0;
    return Container(
      key: const ValueKey('ticket-card'),
      decoration: ShapeDecoration(
        color: t.surface,
        shape: const TicketShapeBorder(notchY: photoH + infoH),
        shadows: t.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: photoH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                EventImage(url: e.coverImageUrl, cacheWidth: 1100),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x1A000000), Color(0x99000000)],
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  right: 14,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          valid ? Icons.verified_rounded : Icons.block_rounded,
                          size: 16,
                          color: statusColor(t, status),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          status,
                          key: const ValueKey('ticket-status'),
                          style: EventraText.caption.copyWith(
                            color: statusColor(t, status),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 14,
                  child: Text(
                    e.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: EventraText.cardTitleOnPhoto.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: infoH,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      _Field(
                        'Date',
                        DateFormat('EEE, MMM d').format(e.startAt),
                      ),
                      _Field('Time', DateFormat('h:mm a').format(e.startAt)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Field('Venue', e.venue),
                      _Field(
                        'Ticket',
                        '${entry.ticket.seq} of ${entry.order.ticketCount}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const PerforationLine(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
            child: Column(
              children: [
                if (valid)
                  RotatingQr(entry: entry)
                else
                  Container(
                    key: const ValueKey('qr-unavailable'),
                    height: 160,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: t.background,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.qr_code_2_rounded,
                          size: 56,
                          color: t.textHint,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          status == 'Cancelled'
                              ? 'This ticket was cancelled'
                              : 'This event has ended',
                          style: EventraText.body,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _Field('Holder', entry.ticket.holderName),
                    _Field('Tier', entry.ticket.tierName),
                  ],
                ),
                if (valid) ...[
                  const SizedBox(height: 14),
                  Text(
                    'Show this code at the entrance. It changes every 30 '
                    'seconds, so screenshots will not work.',
                    textAlign: TextAlign.center,
                    style: EventraText.caption.copyWith(color: t.textHint),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field(this.label, this.value);
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: EventraText.caption.copyWith(color: t.textHint)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: EventraText.body.copyWith(
              color: t.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(child: Text(label, style: EventraText.body)),
          Text(
            value,
            style: EventraText.body.copyWith(
              color: bold ? t.primary : t.textPrimary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
