import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:latlong2/latlong.dart';

/// How well [e] matches [query]: 0 = no match; higher is better.
/// Title prefix > word prefix in title > title substring > venue/address >
/// category.
int searchRank(Event e, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return 0;
  final title = e.title.toLowerCase();
  if (title.startsWith(q)) return 5;
  if (title.split(RegExp(r'\s+')).any((w) => w.startsWith(q))) return 4;
  if (title.contains(q)) return 3;
  if (e.venue.toLowerCase().contains(q) ||
      e.address.toLowerCase().contains(q)) {
    return 2;
  }
  if (e.category.label.toLowerCase().contains(q) ||
      e.category.name.contains(q)) {
    return 1;
  }
  return 0;
}

/// Events matching [query], best match first, then soonest, then id.
List<Event> searchEvents(Iterable<Event> events, String query) {
  final scored =
      [
        for (final e in events)
          if (searchRank(e, query) case final r when r > 0) (e, r),
      ]..sort((a, b) {
        final c = b.$2.compareTo(a.$2);
        if (c != 0) return c;
        final d = a.$1.startAt.compareTo(b.$1.startAt);
        return d != 0 ? d : a.$1.id.compareTo(b.$1.id);
      });
  return [for (final s in scored) s.$1];
}

/// Search, then narrow by [filter] (date, price, distance... ; its sort is
/// ignored so the best text match stays on top).
List<Event> searchWithFilter(
  Iterable<Event> events,
  String query,
  EventFilter filter, {
  required DateTime now,
  required LatLng origin,
}) => searchEvents(
  events.where((e) => filter.matches(e, now: now, origin: origin)),
  query,
);

/// Case-insensitive, non-overlapping occurrences of [query] in [text] as
/// (start, end) pairs.
List<(int, int)> matchRanges(String text, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return const [];
  final lower = text.toLowerCase();
  final out = <(int, int)>[];
  var from = 0;
  while (true) {
    final i = lower.indexOf(q, from);
    if (i < 0) break;
    out.add((i, i + q.length));
    from = i + q.length;
  }
  return out;
}

/// Trending search terms: the most attended categories (by total
/// participants), then the most attended event titles. Deterministic.
List<String> trendingSearches(Iterable<Event> events, {int max = 8}) {
  final byCategory = <EventCategory, int>{};
  for (final e in events) {
    byCategory[e.category] =
        (byCategory[e.category] ?? 0) + e.participantsCount;
  }
  final cats = byCategory.entries.toList()
    ..sort((a, b) {
      final c = b.value.compareTo(a.value);
      return c != 0 ? c : a.key.index.compareTo(b.key.index);
    });
  final popular = [...events]
    ..sort((a, b) {
      final c = b.participantsCount.compareTo(a.participantsCount);
      return c != 0 ? c : a.id.compareTo(b.id);
    });
  final terms = <String>[
    for (final c in cats.take(max ~/ 2)) c.key.label,
    for (final e in popular) e.title,
  ];
  final seen = <String>{};
  return [
    for (final t in terms)
      if (seen.add(t.toLowerCase())) t,
  ].take(max).toList();
}
