import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/reviews/domain/review.dart';
import 'package:eventra/features/reviews/presentation/review_widgets.dart';
import 'package:eventra/features/reviews/presentation/reviews_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ReviewSort { newest, highest, lowest }

/// Every review of an event with sorting and a star filter.
class AllReviewsScreen extends ConsumerStatefulWidget {
  const AllReviewsScreen({required this.eventId, super.key});
  final String eventId;

  @override
  ConsumerState<AllReviewsScreen> createState() => _AllReviewsScreenState();
}

class _AllReviewsScreenState extends ConsumerState<AllReviewsScreen> {
  ReviewSort _sort = ReviewSort.newest;
  int? _stars;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final event = ref.watch(eventByIdProvider(widget.eventId)).value;
    final reviews = ref.watch(allReviewsProvider(widget.eventId));
    final summary =
        ref.watch(ratingSummaryProvider(widget.eventId)).value ??
        RatingSummary.empty;
    final mine = ref.watch(myReviewProvider(widget.eventId)).value;

    List<Review> shown(List<Review> all) {
      final list = [
        for (final r in all)
          if (_stars == null || r.rating == _stars) r,
      ];
      switch (_sort) {
        case ReviewSort.newest:
          break;
        case ReviewSort.highest:
          list.sort((a, b) => b.rating.compareTo(a.rating));
        case ReviewSort.lowest:
          list.sort((a, b) => a.rating.compareTo(b.rating));
      }
      return list;
    }

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        title: const Text('Reviews', style: EventraText.sectionTitle),
        actions: [
          PopupMenuButton<ReviewSort>(
            key: const ValueKey('reviews-sort'),
            tooltip: 'Sort reviews',
            icon: const Icon(Icons.sort_rounded),
            initialValue: _sort,
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => [
              for (final s in ReviewSort.values)
                PopupMenuItem(
                  key: ValueKey('reviews-sort-${s.name}'),
                  value: s,
                  child: Text(switch (s) {
                    ReviewSort.newest => 'Newest',
                    ReviewSort.highest => 'Highest rated',
                    ReviewSort.lowest => 'Lowest rated',
                  }),
                ),
            ],
          ),
        ],
      ),
      body: reviews.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: MessageView.error(
            message: 'Reviews could not load.',
            onRetry: () => ref.invalidate(allReviewsProvider(widget.eventId)),
          ),
        ),
        data: (all) {
          final list = shown(all);
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              if (event != null) ...[
                Text(event.title, style: EventraText.cardTitle),
                const SizedBox(height: 12),
              ],
              RatingSummaryCard(summary: summary),
              const SizedBox(height: 12),
              if (event != null) ReviewCallToAction(event: event),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final s in <int?>[null, 5, 4, 3, 2, 1])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          key: ValueKey('reviews-filter-${s ?? 'all'}'),
                          label: Text(s == null ? 'All' : '$s ★'),
                          selected: _stars == s,
                          onSelected: (_) => setState(() => _stars = s),
                        ),
                      ),
                  ],
                ),
              ),
              if (list.isEmpty)
                const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: MessageView(
                    key: ValueKey('reviews-none'),
                    icon: Icons.reviews_outlined,
                    title: 'No reviews here',
                    message: 'Try another star filter.',
                  ),
                ),
              for (final r in list) ...[
                const SizedBox(height: 12),
                ReviewTile(
                  review: r,
                  mine: r.id == mine?.id,
                  onEdit: event == null
                      ? null
                      : () => showReviewEditor(context, event, existing: r),
                  onDelete: () => confirmDeleteReview(context, ref, r),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
