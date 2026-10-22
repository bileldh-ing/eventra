import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/tickets/domain/device_services.dart';
import 'package:eventra/features/tickets/domain/qr_token.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/features/tickets/presentation/widgets/ticketing_widgets.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

/// 'Sat, Dec 24 · 11:00 PM'
String ticketDate(DateTime d) =>
    '${formatWeekdayMonthDay(d)} · ${formatTime(d)}';

Color statusColor(EventraTokens t, TicketDisplayStatus status) =>
    switch (status) {
      TicketDisplayStatus.valid => t.success,
      TicketDisplayStatus.cancelled => t.error,
      _ => t.textSecondary,
    };

Uri eventLink(String eventId) =>
    Uri.parse('https://eventra.app/event/$eventId');

Future<void> addEventToCalendar(
  BuildContext context,
  WidgetRef ref,
  EventSnapshot e,
) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final ok = await ref
      .read(calendarServiceProvider)
      .add(
        CalendarEntry(
          title: e.title,
          start: e.startAt,
          end: e.endAt,
          location: '${e.venue}, ${e.address}',
          description: l10n.tvCalDesc(eventLink(e.id).toString()),
        ),
      );
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          ok ? l10n.tvCalAdded : l10n.tvCalFailed,
        ),
      ),
    );
}

Future<void> shareTicketInvite(WidgetRef ref, EventSnapshot e) => ref
    .read(shareServiceProvider)
    .share(
      text: AppLocale.l10n.tvInviteText(
        e.title,
        ticketDate(e.startAt),
        e.venue,
        eventLink(e.id).toString(),
      ),
      subject: AppLocale.l10n.shareInviteSubject(e.title),
    );

Future<void> openDirections(BuildContext context, EventSnapshot e) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final uri = Uri.parse(
    'https://www.google.com/maps/dir/?api=1&destination='
    '${e.latitude},${e.longitude}',
  );
  var ok = false;
  try {
    ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } on Object {
    ok = false;
  }
  if (!ok) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(l10n.tvMapsFailed(e.address))),
      );
  }
}

/// Round icon + label action ("Add to Calendar", "Directions", "Share").
class TicketAction extends StatelessWidget {
  const TicketAction({
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
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        excludeSemantics: true,
        child: Pressable(
          onTap: onTap,
          child: Column(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: t.surface,
                  shape: BoxShape.circle,
                  boxShadow: t.softShadow,
                ),
                child: Icon(icon, color: t.primary),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: context.text.caption.copyWith(color: t.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The signed QR, regenerated every 30 s with a countdown ring.
class RotatingQr extends ConsumerWidget {
  const RotatingQr({
    required this.entry,
    super.key,
    this.size = 220,
  });

  final TicketEntry entry;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final service = ref.watch(qrServiceProvider);
    final clock = ref.watch(clockProvider);
    return switch (service) {
      AsyncData(value: final qr) => ClockTicker(
        clock: clock,
        builder: (context, now) {
          final data = qr.payload(
            ticketId: entry.ticket.id,
            eventId: entry.ticket.eventId,
            holderId: entry.ticket.userId,
            now: now,
          );
          final left = QrTokenService.secondsLeft(now);
          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: t.primary.withValues(alpha: 0.15)),
                ),
                child: Semantics(
                  label: context.l10n.tvQrLabel,
                  child: QrImageView(
                    key: ValueKey('qr-$data'),
                    data: data,
                    size: size,
                    padding: EdgeInsets.zero,
                    errorCorrectionLevel: QrErrorCorrectLevel.M,
                    eyeStyle: QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: t.textPrimary,
                    ),
                    dataModuleStyle: QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: t.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountdownRing(
                    key: const ValueKey('qr-countdown'),
                    fraction: left / QrTokenService.windowSeconds,
                    label: '$left',
                    size: 34,
                    stroke: 3,
                    color: left <= 5 ? t.accentOrange : t.primary,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    context.l10n.tvRefreshIn(left.toString()),
                    style: context.text.caption,
                  ),
                ],
              ),
            ],
          );
        },
      ),
      AsyncError() => SizedBox.square(
        dimension: size,
        child: InlineBanner(
          message: context.l10n.tvQrFailed,
        ),
      ),
      _ => SizedBox.square(
        dimension: size,
        child: const Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// Wallet-style ticket in the My Tickets list.
class WalletTicketCard extends StatelessWidget {
  const WalletTicketCard({
    required this.entry,
    required this.now,
    required this.onTap,
    super.key,
  });

  final TicketEntry entry;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final e = entry.event;
    final display = ticketDisplayStatus(entry, now);
    final status = display.label;
    final dim = display != TicketDisplayStatus.valid;
    const photoH = 104.0;
    return Semantics(
      button: true,
      label: '${e.title}, ${entry.ticket.tierName}, $status',
      child: Pressable(
        key: ValueKey('wallet-${entry.ticket.id}'),
        onTap: onTap,
        pressedScale: 0.97,
        child: Container(
          decoration: ShapeDecoration(
            color: t.surface,
            shape: const TicketShapeBorder(notchY: photoH, radius: 24),
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
                    ColorFiltered(
                      colorFilter: dim
                          ? const ColorFilter.matrix(_grayscale)
                          : const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.dst,
                            ),
                      child: EventImage(url: e.coverImageUrl, cacheWidth: 900),
                    ),
                    const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0x00000000), Color(0xB3000000)],
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      start: 18,
                      end: 18,
                      bottom: 12,
                      child: Text(
                        e.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.text.cardTitleOnPhoto.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    PositionedDirectional(
                      top: 12,
                      end: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          status,
                          key: ValueKey('status-${entry.ticket.id}'),
                          style: context.text.caption.copyWith(
                            color: statusColor(t, display),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(18, 14, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticketDate(e.startAt),
                            style: context.text.body.copyWith(
                              color: t.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            e.venue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.text.caption,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            context.l10n.tvTierSeq(
                              entry.ticket.tierName,
                              entry.ticket.seq.toString(),
                              entry.order.ticketCount.toString(),
                            ),
                            style: context.text.caption.copyWith(
                              color: t.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: t.primary.withValues(alpha: dim ? 0.05 : 0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.qr_code_2_rounded,
                        size: 34,
                        color: dim ? t.textHint : t.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const _grayscale = <double>[
  0.2126, 0.7152, 0.0722, 0, 0, //
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];
