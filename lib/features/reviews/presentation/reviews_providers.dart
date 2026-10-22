import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/reviews/data/reviews_repository.dart';
import 'package:eventra/features/reviews/domain/review.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show FutureProviderFamily;

final reviewsRepositoryProvider = Provider<ReviewsRepository>(
  (ref) => ReviewsRepository(
    ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Bumped after every review write so all review views refresh.
class ReviewsRevision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

final reviewsRevisionProvider = NotifierProvider<ReviewsRevision, int>(
  ReviewsRevision.new,
);

/// Seeds catalogue reviews once the events are loaded.
final reviewsReadyProvider = FutureProvider<void>((ref) async {
  final events = await ref.watch(eventsProvider.future);
  await ref.read(reviewsRepositoryProvider).seedIfNeeded(events);
});

final FutureProviderFamily<RatingSummary, String> ratingSummaryProvider =
    FutureProvider.family<RatingSummary, String>((ref, eventId) async {
      ref.watch(reviewsRevisionProvider);
      await ref.watch(reviewsReadyProvider.future);
      return ref.read(reviewsRepositoryProvider).summary(eventId);
    });

/// The three newest reviews (Event Details).
final FutureProviderFamily<List<Review>, String> latestReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, eventId) async {
      ref.watch(reviewsRevisionProvider);
      await ref.watch(reviewsReadyProvider.future);
      return ref.read(reviewsRepositoryProvider).list(eventId, limit: 3);
    });

final FutureProviderFamily<List<Review>, String> allReviewsProvider =
    FutureProvider.family<List<Review>, String>((ref, eventId) async {
      ref.watch(reviewsRevisionProvider);
      await ref.watch(reviewsReadyProvider.future);
      return ref.read(reviewsRepositoryProvider).list(eventId);
    });

/// The signed-in user's review of an event, if any.
final FutureProviderFamily<Review?, String> myReviewProvider =
    FutureProvider.family<Review?, String>((ref, eventId) async {
      ref.watch(reviewsRevisionProvider);
      final user = ref.watch(authControllerProvider.select((s) => s.user));
      if (user == null) return null;
      return ref.read(reviewsRepositoryProvider).mine(eventId, user.id);
    });

final FutureProviderFamily<ReviewEligibility, String>
reviewEligibilityProvider = FutureProvider.family<ReviewEligibility, String>(
  (ref, eventId) async {
    ref
      ..watch(reviewsRevisionProvider)
      ..watch(ticketingRevisionProvider);
    final user = ref.watch(authControllerProvider.select((s) => s.user));
    final event = await ref.watch(eventByIdProvider(eventId).future);
    return ref.read(reviewsRepositoryProvider).eligibility(user?.id, event);
  },
);

/// Review commands for the UI.
class ReviewActions {
  ReviewActions(this._ref);
  final Ref _ref;

  ReviewsRepository get _repo => _ref.read(reviewsRepositoryProvider);
  void _bump() => _ref.read(reviewsRevisionProvider.notifier).bump();

  Future<Result<Review>> create(Event event, int rating, String text) async {
    final user = _ref.read(authControllerProvider).user;
    if (user == null) {
      return Result.failure(
        ReviewFailure(ReviewError.notAllowed, AppLocale.l10n.revLoginToWrite),
      );
    }
    final r = await _repo.create(
      userId: user.id,
      authorName: user.name,
      event: event,
      rating: rating,
      text: text,
    );
    if (r.isSuccess) _bump();
    return r;
  }

  Future<Result<Review>> update(Review review, int rating, String text) async {
    final user = _ref.read(authControllerProvider).user;
    final r = await _repo.update(
      reviewId: review.id,
      userId: user?.id ?? '',
      rating: rating,
      text: text,
    );
    if (r.isSuccess) _bump();
    return r;
  }

  Future<Result<void>> delete(Review review) async {
    final user = _ref.read(authControllerProvider).user;
    final r = await _repo.delete(reviewId: review.id, userId: user?.id ?? '');
    if (r.isSuccess) _bump();
    return r;
  }
}

final reviewActionsProvider = Provider<ReviewActions>(ReviewActions.new);
