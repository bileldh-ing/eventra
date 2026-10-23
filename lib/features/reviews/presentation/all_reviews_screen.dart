import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/reviews/domain/review.dart';
import 'package:eventra/features/reviews/presentation/review_widgets.dart';
import 'package:eventra/features/reviews/presentation/reviews_providers.dart';
import 'package:eventra/l10n/l10n.dart';
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
        title: Text(context.l10n.statReviews, style: context.text.sectionTitle),
        actions: [
          PopupMenuButton<ReviewSort>(
            key: const ValueKey('reviews-sort'),
            tooltip: context.l10n.sortReviews,
            icon: const Icon(Icons.sort_rounded),
            initialValue: _sort,
            onSelected: (s) => setState(() => _sort = s),
            itemBuilder: (_) => [
              for (final s in ReviewSort.values)
                PopupMenuItem(
                  key: ValueKey('reviews-sort-${s.name}'),
                  value: s,
                  child: Text(switch (s) {
                    ReviewSort.newest => context.l10n.revNewest,
                    ReviewSort.highest => context.l10n.revHighest,
                    ReviewSort.lowest => context.l10n.revLowest,
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
            message: context.l10n.revLoadFailed,
            onRetry: () => ref.invalidate(allReviewsProvider(widget.eventId)),
          ),
        ),
        data: (all) {
          final list = shown(all);
          return ListView(
            padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 32),
            children: [
              if (event != null) ...[
                Text(event.title, style: context.text.cardTitle),
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
                        padding: const EdgeInsetsDirectional.only(end: 8),
                        child: ChoiceChip(
                          key: ValueKey('reviews-filter-${s ?? 'all'}'),
                          label: s == null
                              ? Text(context.l10n.filtersAll)
                              : Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('$s'),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.star_rounded,
                                      size: 16,
                                      color: context.tokens.accentOrange,
                                    ),
                                  ],
                                ),
                          selected: _stars == s,
                          onSelected: (_) => setState(() => _stars = s),
                        ),
                      ),
                  ],
                ),
              ),
              if (list.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: MessageView(
                    key: const ValueKey('reviews-none'),
                    icon: Icons.reviews_outlined,
                    title: context.l10n.revNoneHere,
                    message: context.l10n.revTryAnotherStar,
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
