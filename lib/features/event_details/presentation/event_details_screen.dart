import 'package:eventra/app/nav.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Phase 2 version of Event Details: hero photo, title, date and the ticket
/// entry point. Phase 3 replaces it with the full reference layout.
class EventDetailsScreen extends ConsumerWidget {
  const EventDetailsScreen({required this.eventId, super.key, this.heroTag});

  final String eventId;
  final String? heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final async = ref.watch(eventByIdProvider(eventId));
    return Scaffold(
      backgroundColor: t.sheet,
      appBar: AppBar(backgroundColor: t.sheet),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: MessageView.error(
            message: '$e',
            onRetry: () => ref.invalidate(eventByIdProvider(eventId)),
          ),
        ),
        data: (event) => ListView(
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(
              height: 260,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(t.radii.eventCard),
                child: Hero(
                  tag: heroTag ?? defaultHeroTag(event.id),
                  child: EventImage(
                    url: event.coverImageUrl,
                    category: event.category,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(event.title, style: EventraText.detailsTitle),
            Text(formatDetailsDate(event.startAt), style: EventraText.body),
            const SizedBox(height: 24),
            GradientPillButton(
              label: 'Get a Ticket',
              onPressed: () => context.push(
                '${currentTabRoot(context)}/event/${event.id}/tickets',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
