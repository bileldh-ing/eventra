import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/event_details/presentation/details_providers.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

BoxDecoration _card(EventraTokens t) => BoxDecoration(
  color: t.surface,
  borderRadius: BorderRadius.circular(t.radii.listCard),
  boxShadow: t.softShadow,
);

class DetailsSectionTitle extends StatelessWidget {
  const DetailsSectionTitle(this.text, {super.key, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 26, bottom: 12),
    child: Row(
      children: [
        Expanded(child: Text(text, style: EventraText.sectionTitle)),
        ?trailing,
      ],
    ),
  );
}

/// Organizer card: avatar, name, verified badge, followers and Follow.
class OrganizerCard extends ConsumerWidget {
  const OrganizerCard({required this.organizer, super.key});
  final Organizer organizer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final following = ref.watch(
      followedOrganizersProvider.select((s) => s.contains(organizer.id)),
    );
    final followers = organizer.followers + (following ? 1 : 0);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(t),
      child: Row(
        children: [
          NetAvatar(
            url: organizer.avatarUrl,
            size: 52,
            borderWidth: 0,
            name: organizer.name,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        organizer.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: EventraText.cardTitle.copyWith(fontSize: 17),
                      ),
                    ),
                    if (organizer.verified) ...[
                      const SizedBox(width: 4),
                      Icon(
                        Icons.verified_rounded,
                        size: 18,
                        color: t.primary,
                        semanticLabel: 'Verified organizer',
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Organizer - ${formatCompact(followers)} followers',
                  style: EventraText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 104,
            child: following
                ? OutlinedButton(
                    key: const ValueKey('follow-button'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(40),
                      foregroundColor: t.primary,
                      side: BorderSide(color: t.primary),
                      shape: const StadiumBorder(),
                    ),
                    onPressed: () => ref
                        .read(followedOrganizersProvider.notifier)
                        .toggle(organizer.id),
                    child: const Text('Following'),
                  )
                : GradientPillButton(
                    key: const ValueKey('follow-button'),
                    label: 'Follow',
                    height: 40,
                    onPressed: () => ref
                        .read(followedOrganizersProvider.notifier)
                        .toggle(organizer.id),
                  ),
          ),
        ],
      ),
    );
  }
}

/// Vertical timeline for the lineup / schedule.
class LineupTimeline extends StatelessWidget {
  const LineupTimeline({required this.items, super.key});
  final List<LineupItem> items;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      decoration: _card(t),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 72,
                    child: Text(
                      DateFormat('h:mm a').format(items[i].time),
                      style: EventraText.caption.copyWith(
                        color: t.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            gradient: t.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                        ),
                        if (i < items.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              color: t.primary.withValues(alpha: 0.2),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(
                        items[i].title,
                        style: EventraText.body.copyWith(
                          color: t.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class PolicyCard extends StatelessWidget {
  const PolicyCard({required this.policy, super.key});
  final String policy;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(t),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: t.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(policy, style: EventraText.body)),
        ],
      ),
    );
  }
}

class StarRow extends StatelessWidget {
  const StarRow({required this.rating, super.key, this.size = 16});
  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          Icon(
            rating >= i
                ? Icons.star_rounded
                : rating >= i - 0.5
                ? Icons.star_half_rounded
                : Icons.star_outline_rounded,
            size: size,
            color: context.tokens.accentOrange,
          ),
      ],
    );
  }
}

class ReviewSummary extends StatelessWidget {
  const ReviewSummary({required this.event, super.key});
  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: _card(t),
      child: Row(
        children: [
          Text(
            event.rating.toStringAsFixed(1),
            style: EventraText.price.copyWith(color: t.textPrimary),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StarRow(rating: event.rating, size: 20),
              const SizedBox(height: 4),
              Text(
                '${event.reviewCount} reviews',
                style: EventraText.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ReviewCard extends StatelessWidget {
  const ReviewCard({required this.review, super.key});
  final EventReview review;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _card(t),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetAvatar(
                url: review.avatarUrl,
                size: 36,
                borderWidth: 0,
                name: review.author,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.author,
                      style: EventraText.body.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(review.date),
                      style: EventraText.caption,
                    ),
                  ],
                ),
              ),
              StarRow(rating: review.rating.toDouble()),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.text, style: EventraText.body),
        ],
      ),
    );
  }
}

Future<void> showAllReviews(BuildContext context, Event event) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (context) => SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            const Text('Reviews', style: EventraText.sectionTitle),
            const SizedBox(height: 12),
            ReviewSummary(event: event),
            for (final r in event.reviews) ...[
              const SizedBox(height: 12),
              ReviewCard(review: r),
            ],
          ],
        ),
      ),
    ),
  );
}
