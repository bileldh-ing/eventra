import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
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
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        title: Text(paid ? context.l10n.tdRefundQ : context.l10n.tdCancelResQ),
        content: Text(
          paid
              ? context.l10n.tdRefundBody(
                  order.ticketCount,
                  formatCents(decision.refundCents),
                  '${order.cardBrand ?? context.l10n.cardGeneric}$card',
                )
              : context.l10n.tdReleaseBody(order.ticketCount),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.l10n.tdKeep),
          ),
          TextButton(
            key: const ValueKey('confirm-refund'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              paid ? context.l10n.tdRefund : context.l10n.tdCancelRes,
            ),
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
            ? context.l10n.tdRefunded(formatCents(o.refundCents))
            : context.l10n.tdResCancelled,
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
            title: context.l10n.tdYourTicket,
            onBack: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: switch (entry) {
              AsyncError() => MessageView.error(
                message: context.l10n.tdLoadFailed,
                onRetry: () =>
                    ref.invalidate(ticketEntryProvider(widget.ticketId)),
              ),
              AsyncData(value: null) => MessageView(
                icon: Icons.confirmation_number_outlined,
                title: context.l10n.tdNotFound,
                message: context.l10n.tdOtherAccount,
                actionLabel: context.l10n.myTickets,
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
    final display = ticketDisplayStatus(entry, now);
    final valid = display == TicketDisplayStatus.valid;
    final decision = RefundPolicy.evaluate(
      eventStart: e.startAt,
      now: now,
      paidCents: order.totalCents,
    );
    return ListView(
      key: const ValueKey('ticket-detail-scroll'),
      padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 32),
      children: [
        _TicketBody(entry: entry, status: display, valid: valid),
        const SizedBox(height: 22),
        Row(
          children: [
            TicketAction(
              key: const ValueKey('ticket-calendar'),
              icon: Icons.event_available_rounded,
              label: context.l10n.tdAddCal,
              onTap: () => addEventToCalendar(context, ref, e),
            ),
            TicketAction(
              key: const ValueKey('ticket-directions'),
              icon: Icons.directions_rounded,
              label: context.l10n.tdDirections,
              onTap: () => openDirections(context, e),
            ),
            TicketAction(
              key: const ValueKey('ticket-share'),
              icon: Icons.ios_share_rounded,
              label: context.l10n.tdInvite,
              onTap: () => shareTicketInvite(ref, e),
            ),
            TicketAction(
              key: const ValueKey('ticket-event'),
              icon: Icons.info_outline_rounded,
              label: context.l10n.tdDetails,
              onTap: () => context.push('/tickets/event/${e.id}'),
            ),
          ],
        ),
        const SizedBox(height: 22),
        SectionCard(
          title: context.l10n.tdOrder,
          trailing: StatusChip(
            label: order.status == OrderStatus.refunded
                ? context.l10n.tdRefundedChip
                : context.l10n.tdPaid,
            color: order.status == OrderStatus.refunded ? t.error : t.success,
          ),
          child: Column(
            children: [
              _InfoRow(context.l10n.tdOrder, _orderNumber(order.id)),
              _InfoRow(
                context.l10n.tdBooked,
                formatDateTime(order.createdAt),
              ),
              for (final l in order.lines)
                _InfoRow(
                  '${l.quantity}× ${l.tierName}',
                  l.unitCents == 0
                      ? context.l10n.priceFree
                      : formatCents(l.subtotalCents),
                ),
              if (order.discountCents > 0)
                _InfoRow(
                  context.l10n.tdPromo(order.promoCode ?? ''),
                  formatCents(-order.discountCents),
                ),
              _InfoRow(
                context.l10n.feesAndTax,
                formatCents(order.feesCents + order.taxCents),
              ),
              _InfoRow(
                context.l10n.tdTotalPaid,
                formatCents(order.totalCents),
                bold: true,
              ),
              if (order.cardLast4 != null)
                _InfoRow(
                  context.l10n.tdPaidWith,
                  '${order.cardBrand} •••• ${order.cardLast4}',
                ),
              if (order.status == OrderStatus.refunded)
                _InfoRow(
                  context.l10n.tdRefundedChip,
                  [
                    formatCents(order.refundCents),
                    if (order.refundedAt case final at?) formatMonthDay(at),
                  ].join(' · '),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (order.status == OrderStatus.paid) ...[
          SectionCard(
            title: context.l10n.tdRefundPolicy,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(RefundPolicy.summary, style: context.text.body),
                const SizedBox(height: 10),
                Text(
                  decision.allowed && decision.deadline != null
                      ? '${decision.reason} '
                            '(${formatMonthDayTime(decision.deadline!)})'
                      : decision.reason,
                  key: const ValueKey('refund-reason'),
                  style: context.text.caption.copyWith(
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
                          ? context.l10n.tdProcessing
                          : order.totalCents > 0
                          ? context.l10n.tdRequestRefund(
                              formatCents(decision.refundCents),
                            )
                          : context.l10n.tdCancelRes,
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
  final TicketDisplayStatus status;
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
                PositionedDirectional(
                  top: 14,
                  end: 14,
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
                          status.label,
                          key: const ValueKey('ticket-status'),
                          style: context.text.caption.copyWith(
                            color: statusColor(t, status),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                PositionedDirectional(
                  start: 20,
                  end: 20,
                  bottom: 14,
                  child: Text(
                    e.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.cardTitleOnPhoto.copyWith(
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
              padding: const EdgeInsetsDirectional.fromSTEB(20, 16, 20, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      _Field(
                        context.l10n.fDate,
                        formatWeekdayMonthDay(e.startAt),
                      ),
                      _Field(context.l10n.fTime, formatTime(e.startAt)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _Field(context.l10n.fVenue, e.venue),
                      _Field(
                        context.l10n.fTicket,
                        context.l10n.tdSeqOf(
                          entry.ticket.seq.toString(),
                          entry.order.ticketCount.toString(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const PerforationLine(),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 20, 20, 20),
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
                          status == TicketDisplayStatus.cancelled
                              ? context.l10n.tdWasCancelled
                              : context.l10n.tdEnded,
                          style: context.text.body,
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    _Field(context.l10n.fHolder, entry.ticket.holderName),
                    _Field(context.l10n.fTier, entry.ticket.tierName),
                  ],
                ),
                if (valid) ...[
                  const SizedBox(height: 14),
                  Text(
                    context.l10n.tdShowCode,
                    textAlign: TextAlign.center,
                    style: context.text.caption.copyWith(color: t.textHint),
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
          Text(label, style: context.text.caption.copyWith(color: t.textHint)),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.text.body.copyWith(
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
          Expanded(child: Text(label, style: context.text.body)),
          Text(
            value,
            style: context.text.body.copyWith(
              color: bold ? t.primary : t.textPrimary,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
