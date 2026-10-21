import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ticket purchase and the ticket wallet arrive in Phase 7. This screen is
/// reachable and functional: it summarises the event and saves it so the user
/// can come back.
class TicketsPlaceholderScreen extends ConsumerWidget {
  const TicketsPlaceholderScreen({super.key, this.eventId});
  final String? eventId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final event = eventId == null
        ? null
        : ref.watch(eventByIdProvider(eventId!)).value;
    final saved = eventId != null && ref.watch(isFavoriteProvider(eventId!));
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        title: Text(
          event == null ? 'My Tickets' : 'Get a Ticket',
          style: EventraText.sectionTitle,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(t.radii.listCard),
                boxShadow: t.softShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.confirmation_number_outlined,
                    color: t.primary,
                    size: 36,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Ticketing is coming in Phase 7',
                    style: EventraText.cardTitle,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tier selection with a hold timer, mock checkout and a '
                    'QR ticket wallet are the next milestone.',
                    style: EventraText.body,
                  ),
                  if (event != null) ...[
                    const Divider(height: 32),
                    Text(event.title, style: EventraText.cardTitle),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDetailsDate(event.startAt)}  -  ${event.venue}',
                      style: EventraText.caption,
                    ),
                    const SizedBox(height: 12),
                    for (final tier in event.tiers)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(tier.name, style: EventraText.body),
                            ),
                            Text(
                              tier.remaining == 0
                                  ? 'Sold out'
                                  : formatPrice(tier.price),
                              style: EventraText.body.copyWith(
                                color: t.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
            ),
            const Spacer(),
            if (event != null)
              GradientPillButton(
                key: const ValueKey('placeholder-save'),
                label: saved ? 'Saved to favorites' : 'Save event for later',
                icon: saved ? Icons.check_rounded : Icons.bookmark_add_outlined,
                onPressed: saved
                    ? () => Navigator.of(context).maybePop()
                    : () =>
                          ref.read(favoritesProvider.notifier).toggle(event.id),
              )
            else
              GradientPillButton(
                label: 'Back',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
          ],
        ),
      ),
    );
  }
}
