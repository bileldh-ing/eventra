import 'dart:math' as math;

import 'package:eventra/core/utils/geo.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/onboarding/domain/interest.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';

/// Everything the feed knows about the user at one moment. Pure data, so a
/// score is a function of (event, profile) only.
@immutable
class FeedProfile {
  const FeedProfile({
    required this.origin,
    required this.now,
    this.interests = const [],
    this.saved = const [],
  });

  /// Where distances are measured from (device position or home city).
  final LatLng origin;
  final DateTime now;

  /// In the user's own order of [Interest.values].
  final List<Interest> interests;

  /// Events the user saved (favorites); drives the social/favorites signal.
  final List<Event> saved;

  /// First interest that covers [category], or null.
  Interest? interestFor(EventCategory category) {
    for (final i in interests) {
      if (i.categories.contains(category)) return i;
    }
    return null;
  }
}

enum FeedReasonKind { interest, nearby, trending, soon, saved }

@immutable
class FeedReason {
  const FeedReason(this.kind, this.label);
  final FeedReasonKind kind;
  final String label;

  @override
  bool operator ==(Object other) =>
      other is FeedReason && other.kind == kind && other.label == label;

  @override
  int get hashCode => Object.hash(kind, label);

  @override
  String toString() => label;
}

/// One event's score, split by signal (each already weighted), plus the
/// human-readable reasons behind it.
@immutable
class FeedScore {
  const FeedScore({
    required this.interests,
    required this.proximity,
    required this.popularity,
    required this.recency,
    required this.social,
    required this.distanceKm,
    required this.reasons,
  });

  final double interests;
  final double proximity;
  final double popularity;
  final double recency;
  final double social;
  final double distanceKm;
  final List<FeedReason> reasons;

  /// 0..100.
  double get total => interests + proximity + popularity + recency + social;
}

/// On-device, explainable recommendation engine.
///
/// score (0..100) = interests 35 + proximity 25 + popularity 15
///                + recency (time decay) 15 + social/favorites 10.
///
/// Deterministic: no randomness and no wall clock; ties break on start time
/// then id.
class SmartFeedScorer {
  const SmartFeedScorer();

  static const wInterests = 35.0;
  static const wProximity = 25.0;
  static const wPopularity = 15.0;
  static const wRecency = 15.0;
  static const wSocial = 10.0;

  /// Full proximity score up to this distance...
  static const nearKm = 1.0;

  /// ...falling linearly to zero here.
  static const farKm = 40.0;

  /// "Near you" reason threshold.
  static const nearYouKm = 5.0;

  /// Participant count that earns the full popularity share (log scale).
  static const popularityCap = 2000;

  /// "Trending" reason threshold.
  static const trendingParticipants = 500;

  /// Recency halves every this many days until the start.
  static const recencyHalfLifeDays = 14.0;

  /// "This week" reason threshold.
  static const soonDays = 7;

  /// Saved events in a category that earn the full social share.
  static const savedForFullAffinity = 3;

  static const maxReasons = 3;

  FeedScore score(Event e, FeedProfile p) {
    final interest = p.interestFor(e.category);
    final interests = interest != null ? wInterests : 0.0;

    final km = haversineKm(p.origin, LatLng(e.latitude, e.longitude));
    final proximity = wProximity * proximityFactor(km);

    final popularity = wPopularity * popularityFactor(e);

    final days = e.startAt.difference(p.now).inMinutes / (60 * 24);
    final recency = wRecency * recencyFactor(days);

    final affinity = savedAffinity(e, p.saved);
    final social = wSocial * affinity;

    // Reasons ordered by how much each signal contributed; the fixed enum
    // order breaks ties so the chips never shuffle.
    final candidates =
        <(double, FeedReason)>[
          if (interest != null)
            (
              interests,
              FeedReason(
                FeedReasonKind.interest,
                'Because you like ${interest.label}',
              ),
            ),
          if (km <= nearYouKm)
            (proximity, const FeedReason(FeedReasonKind.nearby, 'Near you')),
          if (e.participantsCount >= trendingParticipants)
            (popularity, const FeedReason(FeedReasonKind.trending, 'Trending')),
          if (days >= 0 && days <= soonDays)
            (
              recency,
              FeedReason(
                FeedReasonKind.soon,
                days < 1 ? 'Starts soon' : 'This week',
              ),
            ),
          if (affinity > 0)
            (social, const FeedReason(FeedReasonKind.saved, 'Like your saves')),
        ]..sort((a, b) {
          final c = b.$1.compareTo(a.$1);
          return c != 0 ? c : a.$2.kind.index.compareTo(b.$2.kind.index);
        });

    return FeedScore(
      interests: interests,
      proximity: proximity,
      popularity: popularity,
      recency: recency,
      social: social,
      distanceKm: km,
      reasons: [for (final c in candidates.take(maxReasons)) c.$2],
    );
  }

  /// 1 within [nearKm], 0 beyond [farKm], linear between.
  static double proximityFactor(double km) {
    if (km <= nearKm) return 1;
    if (km >= farKm) return 0;
    return 1 - (km - nearKm) / (farKm - nearKm);
  }

  /// 70% attendance (log scale, capped) + 30% rating.
  static double popularityFactor(Event e) {
    final p = math.max(0, e.participantsCount);
    final attendance = math.min(
      1,
      math.log(1 + p) / math.log(1 + popularityCap),
    );
    final rating = (e.rating / 5).clamp(0.0, 1.0);
    return 0.7 * attendance + 0.3 * rating;
  }

  /// 1 for events already under way, halving every [recencyHalfLifeDays].
  static double recencyFactor(double daysUntilStart) {
    if (daysUntilStart <= 0) return 1;
    return math.pow(0.5, daysUntilStart / recencyHalfLifeDays).toDouble();
  }

  /// 1 when the organizer is one the user saved before, else the share of
  /// [savedForFullAffinity] saved events in the same category. The event
  /// itself never counts.
  static double savedAffinity(Event e, List<Event> saved) {
    var sameCategory = 0;
    for (final s in saved) {
      if (s.id == e.id) continue;
      if (s.organizer.id == e.organizer.id) return 1;
      if (s.category == e.category) sameCategory++;
    }
    return math.min(1, sameCategory / savedForFullAffinity);
  }

  /// Highest score first; ties on start time, then id.
  List<Event> rank(Iterable<Event> events, FeedProfile p) {
    final scored = [for (final e in events) (e, score(e, p).total)]
      ..sort((a, b) {
        final c = b.$2.compareTo(a.$2);
        if (c != 0) return c;
        final d = a.$1.startAt.compareTo(b.$1.startAt);
        return d != 0 ? d : a.$1.id.compareTo(b.$1.id);
      });
    return [for (final s in scored) s.$1];
  }

  /// The Upcoming order: editorial picks that match the user's interests
  /// (or all of them when the user has none) lead in their editorial order,
  /// everything else follows by score.
  List<Event> feed(Iterable<Event> events, FeedProfile p) {
    final pinned = <Event>[];
    final rest = <Event>[];
    for (final e in events) {
      final rank = e.featuredRank;
      final matches = p.interests.isEmpty || p.interestFor(e.category) != null;
      (rank != null && matches ? pinned : rest).add(e);
    }
    pinned.sort((a, b) => a.featuredRank!.compareTo(b.featuredRank!));
    return [...pinned, ...rank(rest, p)];
  }
}
