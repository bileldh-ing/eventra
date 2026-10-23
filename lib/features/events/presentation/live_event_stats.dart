import 'package:drift/drift.dart' show Variable;
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/reviews/presentation/reviews_providers.dart';
import 'package:eventra/features/tickets/domain/tier_rules.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderFamily;
import 'package:meta/meta.dart';

/// Live rating of one event, from the `reviews` table.
@immutable
class LiveRating {
  const LiveRating({required this.average, required this.count});
  final double average;
  final int count;
}

/// Live tickets left for one event: sold and active holds from `tier_stock`
/// (the same numbers the tier picker uses), falling back to the catalogue
/// snapshot for tiers that have no stock row yet.
@immutable
class EventStock {
  const EventStock({required this.left, required this.capacity});

  /// Seats that can still be bought across all tiers.
  final int left;
  final int capacity;

  bool get soldOut => left <= 0;

  /// Same threshold as the tier picker's "Only N left".
  bool get lowStock => !soldOut && left <= kLowStockThreshold;

  /// Catalogue snapshot only (no database).
  factory EventStock.fromSeed(Event e) => EventStock(
    left: e.tiers.fold(0, (s, t) => s + t.remaining),
    capacity: e.tiers.fold(0, (s, t) => s + t.capacity),
  );
}

/// Per-event live numbers read in two queries for the whole catalogue.
@immutable
class LiveEventStats {
  const LiveEventStats({this.ratings = const {}, this.taken = const {}});

  static const empty = LiveEventStats();

  /// eventId -> average and count of reviews in the database.
  final Map<String, LiveRating> ratings;

  /// eventId -> tierId -> (capacity, sold + active holds).
  final Map<String, Map<String, (int, int)>> taken;

  static Future<LiveEventStats> read(
    AppDatabase db, {
    required DateTime now,
  }) async {
    final ratingRows = await db
        .customSelect(
          'SELECT event_id, AVG(rating) AS a, COUNT(*) AS c FROM reviews '
          'GROUP BY event_id',
        )
        .get();
    final stockRows = await db
        .customSelect(
          'SELECT event_id, tier_id, capacity, sold FROM tier_stock',
        )
        .get();
    // Only holds still running count: expired ones release their seats.
    final holdRows = await db
        .customSelect(
          'SELECT h.event_id AS event_id, i.tier_id AS tier_id, '
          'SUM(i.quantity) AS q FROM ticket_holds h '
          'JOIN ticket_hold_items i ON i.hold_id = h.id '
          "WHERE h.status = 'active' AND h.expires_at > ? "
          'GROUP BY h.event_id, i.tier_id',
          variables: [Variable.withInt(now.millisecondsSinceEpoch)],
        )
        .get();
    final held = <(String, String), int>{
      for (final r in holdRows)
        (r.read<String>('event_id'), r.read<String>('tier_id')): r.read<int>(
          'q',
        ),
    };
    final taken = <String, Map<String, (int, int)>>{};
    for (final r in stockRows) {
      final e = r.read<String>('event_id');
      final t = r.read<String>('tier_id');
      final cap = r.read<int>('capacity');
      final used = (r.read<int>('sold') + (held[(e, t)] ?? 0)).clamp(0, cap);
      (taken[e] ??= {})[t] = (cap, used);
    }
    return LiveEventStats(
      ratings: {
        for (final r in ratingRows)
          if (r.read<int>('c') > 0)
            r.read<String>('event_id'): LiveRating(
              average: r.read<double>('a'),
              count: r.read<int>('c'),
            ),
      },
      taken: taken,
    );
  }

  EventStock stockFor(Event e) {
    final live = taken[e.id];
    if (live == null) return EventStock.fromSeed(e);
    var left = 0;
    var capacity = 0;
    for (final t in e.tiers) {
      final (cap, used) = live[t.id] ?? (t.capacity, t.sold);
      capacity += cap;
      left += (cap - used).clamp(0, cap);
    }
    return EventStock(left: left, capacity: capacity);
  }

  /// Live average when reviews exist, else the catalogue aggregate.
  LiveRating ratingFor(Event e) =>
      ratings[e.id] ?? LiveRating(average: e.rating, count: e.reviewCount);
}

/// Live stock and ratings, refreshed after every ticketing or review write.
/// Falls back to [LiveEventStats.empty] (catalogue snapshot) when no
/// database is available (widget tests with fake repositories).
final liveEventStatsProvider = FutureProvider<LiveEventStats>((ref) async {
  ref
    ..watch(ticketingRevisionProvider)
    ..watch(reviewsRevisionProvider);
  try {
    final db = ref.watch(appDatabaseProvider);
    await ref.watch(reviewsReadyProvider.future);
    return await LiveEventStats.read(db, now: ref.read(clockProvider)());
  } on Object {
    return LiveEventStats.empty;
  }
});

/// Live stock for one event (catalogue snapshot until the stats load).
final ProviderFamily<EventStock, Event> eventStockProvider =
    Provider.family<EventStock, Event>((ref, event) {
      final stats = ref.watch(liveEventStatsProvider).value;
      return (stats ?? LiveEventStats.empty).stockFor(event);
    });

/// Live rating for one event (catalogue aggregate until reviews exist).
final ProviderFamily<LiveRating, Event> eventRatingProvider =
    Provider.family<LiveRating, Event>((ref, event) {
      final stats = ref.watch(liveEventStatsProvider).value;
      return (stats ?? LiveEventStats.empty).ratingFor(event);
    });
