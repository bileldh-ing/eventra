import 'package:eventra/core/result/result.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/foundation.dart';

export 'package:eventra/core/result/result.dart'
    show ReviewError, ReviewFailure;

@immutable
class Review {
  const Review({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.authorName,
    required this.rating,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.avatarUrl = '',
  });

  final String id;
  final String eventId;
  final String userId;
  final String authorName;
  final String avatarUrl;
  final int rating;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get edited => updatedAt.isAfter(createdAt);
}

/// Average, count and a 1..5 star histogram.
@immutable
class RatingSummary {
  const RatingSummary({required this.count, required this.histogram});

  factory RatingSummary.of(Iterable<int> ratings) {
    final h = List<int>.filled(5, 0);
    var n = 0;
    for (final r in ratings) {
      if (r < 1 || r > 5) continue;
      h[r - 1]++;
      n++;
    }
    return RatingSummary(count: n, histogram: List.unmodifiable(h));
  }

  static const empty = RatingSummary(count: 0, histogram: [0, 0, 0, 0, 0]);

  final int count;

  /// `histogram[i]` = number of (i + 1)-star reviews.
  final List<int> histogram;

  double get average {
    if (count == 0) return 0;
    var sum = 0;
    for (var i = 0; i < 5; i++) {
      sum += histogram[i] * (i + 1);
    }
    return sum / count;
  }

  /// Share of reviews with [stars] stars, 0..1.
  double share(int stars) => count == 0 ? 0 : histogram[stars - 1] / count;
}

/// Why the current user can or cannot review an event.
enum ReviewEligibility {
  /// Signed in, holds a valid ticket and the event has ended.
  eligible,

  /// Already reviewed: can edit or delete.
  reviewed,
  signedOut,

  /// No (non-cancelled) ticket for the event.
  noTicket,

  /// Has a ticket but the event has not ended yet.
  notEnded,
}

/// Pure validation rules for a review draft.
abstract final class ReviewRules {
  static const minLength = 10;
  static const maxLength = 500;

  /// Returns the first problem with a draft, or null when it is valid.
  static ReviewFailure? validate(int rating, String text) {
    if (rating < 1 || rating > 5) {
      return ReviewFailure(
        ReviewError.invalidRating,
        AppLocale.l10n.revValRating,
      );
    }
    final n = text.trim().length;
    if (n < minLength) {
      return ReviewFailure(
        ReviewError.tooShort,
        AppLocale.l10n.revValShort(minLength.toString()),
      );
    }
    if (n > maxLength) {
      return ReviewFailure(
        ReviewError.tooLong,
        AppLocale.l10n.revValLong(maxLength.toString()),
      );
    }
    return null;
  }

  /// Eligibility from the facts the repository gathers.
  static ReviewEligibility eligibility({
    required bool signedIn,
    required bool hasValidTicket,
    required bool eventEnded,
    required bool alreadyReviewed,
  }) {
    if (!signedIn) return ReviewEligibility.signedOut;
    if (alreadyReviewed) return ReviewEligibility.reviewed;
    if (!hasValidTicket) return ReviewEligibility.noTicket;
    if (!eventEnded) return ReviewEligibility.notEnded;
    return ReviewEligibility.eligible;
  }
}
