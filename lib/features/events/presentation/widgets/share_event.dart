import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Deep link used in shares (handled by the router as /home/event/:id).
Uri eventDeepLink(Event e) => Uri.parse('https://eventra.app/event/${e.id}');

String shareText(Event e) {
  final l = AppLocale.l10n;
  return l.shareText(
    e.title,
    formatCardDate(e.startAt),
    e.venue,
    e.address,
    e.isFree ? l.shareFreeEntry : l.shareTicketsFrom(formatPrice(e.minPrice)),
    eventDeepLink(e).toString(),
  );
}

Future<void> shareEvent(BuildContext context, Event e) async {
  final box = context.findRenderObject() as RenderBox?;
  await SharePlus.instance.share(
    ShareParams(
      text: shareText(e),
      subject: e.title,
      sharePositionOrigin: box == null
          ? null
          : box.localToGlobal(Offset.zero) & box.size,
    ),
  );
}

Future<void> shareInvite(Event e) => SharePlus.instance.share(
  ShareParams(
    text: AppLocale.l10n.shareInviteText(
      e.title,
      formatCardDate(e.startAt),
      eventDeepLink(e).toString(),
    ),
    subject: AppLocale.l10n.shareInviteSubject(e.title),
  ),
);
