import 'package:eventra/core/result/result.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/event_details/presentation/widgets/details_sections.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/reviews/domain/review.dart';
import 'package:eventra/features/reviews/presentation/reviews_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

BoxDecoration _card(EventraTokens t) => BoxDecoration(
  color: t.surface,
  borderRadius: BorderRadius.circular(t.radii.listCard),
  boxShadow: t.softShadow,
);

/// Average, stars, count and a 5..1 histogram.
class RatingSummaryCard extends StatelessWidget {
  const RatingSummaryCard({required this.summary, super.key});
  final RatingSummary summary;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      key: const ValueKey('rating-summary'),
      padding: const EdgeInsets.all(16),
      decoration: _card(t),
      child: Row(
        children: [
          Column(
            children: [
              Text(
                summary.count == 0 ? '-' : summary.average.toStringAsFixed(1),
                key: const ValueKey('rating-average'),
                style: context.text.price.copyWith(color: t.textPrimary),
              ),
              const SizedBox(height: 4),
              StarRow(rating: summary.average),
              const SizedBox(height: 4),
              Text(
                context.l10n.nReviews(summary.count),
                key: const ValueKey('rating-count'),
                style: context.text.caption,
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                for (var stars = 5; stars >= 1; stars--)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      key: ValueKey('histogram-$stars'),
                      children: [
                        SizedBox(
                          width: 12,
                          child: Text('$stars', style: context.text.caption),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: summary.share(stars),
                              minHeight: 6,
                              backgroundColor: t.textHint.withValues(
                                alpha: 0.18,
                              ),
                              valueColor: AlwaysStoppedAnimation(
                                t.accentOrange,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          width: 24,
                          child: Text(
                            '${summary.histogram[stars - 1]}',
                            textAlign: TextAlign.end,
                            style: context.text.caption,
                          ),
                        ),
                      ],
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

class ReviewTile extends StatelessWidget {
  const ReviewTile({
    required this.review,
    super.key,
    this.mine = false,
    this.onEdit,
    this.onDelete,
  });

  final Review review;
  final bool mine;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      key: ValueKey('review-${review.id}'),
      padding: const EdgeInsets.all(14),
      decoration: _card(t).copyWith(
        border: mine
            ? Border.all(color: t.primary.withValues(alpha: 0.5))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NetAvatar(
                url: review.avatarUrl,
                size: 36,
                borderWidth: 0,
                name: review.authorName,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mine
                          ? context.l10n.revYou(review.authorName)
                          : review.authorName,
                      style: context.text.body.copyWith(
                        color: t.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${formatFullDate(review.createdAt)}'
                      '${review.edited ? ' · ${context.l10n.revEdited}' : ''}',
                      style: context.text.caption,
                    ),
                  ],
                ),
              ),
              StarRow(rating: review.rating.toDouble()),
              if (mine)
                PopupMenuButton<String>(
                  key: const ValueKey('my-review-menu'),
                  tooltip: context.l10n.revOptions,
                  onSelected: (v) =>
                      v == 'edit' ? onEdit?.call() : onDelete?.call(),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      key: const ValueKey('my-review-edit'),
                      value: 'edit',
                      child: Text(context.l10n.edit),
                    ),
                    PopupMenuItem(
                      key: const ValueKey('my-review-delete'),
                      value: 'delete',
                      child: Text(context.l10n.delete),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(review.body, style: context.text.body),
        ],
      ),
    );
  }
}

/// Event Details section: summary, the user's call to action and the
/// three newest reviews.
class EventReviewsSection extends ConsumerWidget {
  const EventReviewsSection({required this.event, super.key});
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final summary =
        ref.watch(ratingSummaryProvider(event.id)).value ?? RatingSummary.empty;
    final latest = ref.watch(latestReviewsProvider(event.id)).value ?? const [];
    final mine = ref.watch(myReviewProvider(event.id)).value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DetailsSectionTitle(
          context.l10n.statReviews,
          trailing: TextButton(
            key: const ValueKey('reviews-see-all'),
            onPressed: () => openAllReviews(context, event.id),
            child: Text(
              context.l10n.seeAllLower,
              style: TextStyle(color: t.primary),
            ),
          ),
        ),
        RatingSummaryCard(summary: summary),
        const SizedBox(height: 12),
        ReviewCallToAction(event: event),
        if (latest.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              context.l10n.revNoneYet,
              key: const ValueKey('reviews-empty'),
              style: context.text.caption,
            ),
          ),
        for (final r in latest) ...[
          const SizedBox(height: 12),
          ReviewTile(
            review: r,
            mine: r.id == mine?.id,
            onEdit: () => showReviewEditor(context, event, existing: r),
            onDelete: () => confirmDeleteReview(context, ref, r),
          ),
        ],
      ],
    );
  }
}

void openAllReviews(BuildContext context, String eventId) {
  final path = GoRouterState.of(context).uri.path;
  context.push(
    path.endsWith('/event/$eventId')
        ? '$path/reviews'
        : '/home/event/$eventId/reviews',
  );
}

/// Write / edit button, or why the user cannot review yet.
class ReviewCallToAction extends ConsumerWidget {
  const ReviewCallToAction({required this.event, super.key});
  final Event event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final eligibility = ref.watch(reviewEligibilityProvider(event.id)).value;
    final mine = ref.watch(myReviewProvider(event.id)).value;
    Widget note(String text) => Row(
      key: const ValueKey('review-note'),
      children: [
        Icon(Icons.info_outline_rounded, size: 18, color: t.textHint),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: context.text.caption)),
      ],
    );
    return switch (eligibility) {
      null => const SizedBox.shrink(),
      ReviewEligibility.eligible => GradientPillButton(
        key: const ValueKey('write-review'),
        label: context.l10n.revWrite,
        icon: Icons.rate_review_outlined,
        onPressed: () => showReviewEditor(context, event),
      ),
      ReviewEligibility.reviewed => OutlinedButton.icon(
        key: const ValueKey('edit-review'),
        onPressed: mine == null
            ? null
            : () => showReviewEditor(context, event, existing: mine),
        icon: const Icon(Icons.edit_outlined),
        label: Text(context.l10n.revEditYours),
      ),
      ReviewEligibility.signedOut => note(
        context.l10n.revSignedOut,
      ),
      ReviewEligibility.noTicket => note(
        context.l10n.revOnlyAttendees,
      ),
      ReviewEligibility.notEnded => note(
        context.l10n.revAfterEnd,
      ),
    };
  }
}

Future<void> confirmDeleteReview(
  BuildContext context,
  WidgetRef ref,
  Review review,
) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(context.l10n.revDeleteQ),
      content: Text(context.l10n.cannotUndo),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          key: const ValueKey('delete-review-confirm'),
          onPressed: () => Navigator.pop(context, true),
          child: Text(context.l10n.delete),
        ),
      ],
    ),
  );
  if (!(ok ?? false)) return;
  final r = await ref.read(reviewActionsProvider).delete(review);
  if (!context.mounted) return;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(
          r.isSuccess
              ? context.l10n.revDeleted
              : r.fold((_) => '', (f) => f.message),
        ),
      ),
    );
}

Future<void> showReviewEditor(
  BuildContext context,
  Event event, {
  Review? existing,
}) => showModalBottomSheet<void>(
  context: context,
  isScrollControlled: true,
  useRootNavigator: true,
  builder: (_) => ReviewEditorSheet(event: event, existing: existing),
);

class ReviewEditorSheet extends ConsumerStatefulWidget {
  const ReviewEditorSheet({required this.event, super.key, this.existing});
  final Event event;
  final Review? existing;

  @override
  ConsumerState<ReviewEditorSheet> createState() => _ReviewEditorSheetState();
}

class _ReviewEditorSheetState extends ConsumerState<ReviewEditorSheet> {
  late int _rating = widget.existing?.rating ?? 0;
  late final _text = TextEditingController(text: widget.existing?.body);
  String? _error;
  var _busy = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final problem = ReviewRules.validate(_rating, _text.text);
    if (problem != null) {
      setState(() => _error = problem.message);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    final actions = ref.read(reviewActionsProvider);
    final existing = widget.existing;
    final r = existing == null
        ? await actions.create(widget.event, _rating, _text.text)
        : await actions.update(existing, _rating, _text.text);
    if (!mounted) return;
    switch (r) {
      case Success():
        final messenger = ScaffoldMessenger.of(context);
        Navigator.of(context).pop();
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                existing == null
                    ? context.l10n.revThanks
                    : context.l10n.revUpdated,
              ),
            ),
          );
      case Failure(:final failure):
        setState(() {
          _busy = false;
          _error = failure.message;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final length = _text.text.trim().length;
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.existing == null
                ? context.l10n.revRateEvent
                : context.l10n.revEditYours,
            style: context.text.sectionTitle,
          ),
          const SizedBox(height: 4),
          Text(widget.event.title, style: context.text.caption),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 1; i <= 5; i++)
                IconButton(
                  key: ValueKey('star-$i'),
                  tooltip: context.l10n.nStars(i),
                  iconSize: 40,
                  onPressed: _busy ? null : () => setState(() => _rating = i),
                  icon: AnimatedScale(
                    scale: _rating >= i ? 1.12 : 1,
                    duration: const Duration(milliseconds: 160),
                    child: Icon(
                      _rating >= i
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      color: t.accentOrange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            key: const ValueKey('review-text'),
            controller: _text,
            enabled: !_busy,
            minLines: 3,
            maxLines: 6,
            maxLength: ReviewRules.maxLength,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: context.l10n.revHint,
              helperText: length < ReviewRules.minLength
                  ? context.l10n.revMinChars(ReviewRules.minLength.toString())
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          if (_error case final e?) ...[
            const SizedBox(height: 4),
            Text(
              e,
              key: const ValueKey('review-error'),
              style: context.text.caption.copyWith(color: t.error),
            ),
          ],
          const SizedBox(height: 12),
          GradientPillButton(
            key: const ValueKey('review-submit'),
            label: _busy
                ? context.l10n.saving
                : widget.existing == null
                ? context.l10n.revPost
                : context.l10n.saveChanges,
            onPressed: _busy ? null : _submit,
          ),
        ],
      ),
    );
  }
}
