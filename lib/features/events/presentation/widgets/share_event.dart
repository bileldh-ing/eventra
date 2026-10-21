import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:flutter/widgets.dart';
import 'package:share_plus/share_plus.dart';

/// Deep link used in shares (handled by the router as /home/event/:id).
Uri eventDeepLink(Event e) => Uri.parse('https://eventra.app/event/${e.id}');

String shareText(Event e) =>
    '${e.title} - ${formatCardDate(e.startAt)} at ${e.venue}, ${e.address}. '
    '${e.isFree ? 'Free entry' : 'Tickets from ${formatPrice(e.minPrice)}'}. '
    '${eventDeepLink(e)}';

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
    text:
        'Join me at ${e.title} on ${formatCardDate(e.startAt)}! '
        '${eventDeepLink(e)}',
    subject: 'Come with me to ${e.title}',
  ),
);
