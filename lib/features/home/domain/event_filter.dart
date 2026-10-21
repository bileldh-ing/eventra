import 'package:eventra/core/utils/geo.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';

enum EventSort {
  recommended('Recommended'),
  soonest('Soonest'),
  nearest('Nearest'),
  priceLow('Price: low to high'),
  popular('Most popular');

  const EventSort(this.label);
  final String label;
}

/// Immutable discovery filter shared by Home, See All and the Filters sheet.
@immutable
class EventFilter {
  const EventFilter({
    this.category,
    this.maxPrice,
    this.freeOnly = false,
    this.hasTicketsLeft = false,
    this.sort = EventSort.recommended,
  });

  static const none = EventFilter();

  /// null = "See All".
  final EventCategory? category;
  final double? maxPrice;
  final bool freeOnly;
  final bool hasTicketsLeft;
  final EventSort sort;

  bool get isDefault =>
      category == null &&
      maxPrice == null &&
      !freeOnly &&
      !hasTicketsLeft &&
      sort == EventSort.recommended;

  /// Number of non-category refinements (badge on the filter button).
  int get refinementCount =>
      (maxPrice != null ? 1 : 0) +
      (freeOnly ? 1 : 0) +
      (hasTicketsLeft ? 1 : 0) +
      (sort != EventSort.recommended ? 1 : 0);

  EventFilter copyWith({
    EventCategory? Function()? category,
    double? Function()? maxPrice,
    bool? freeOnly,
    bool? hasTicketsLeft,
    EventSort? sort,
  }) => EventFilter(
    category: category != null ? category() : this.category,
    maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
    freeOnly: freeOnly ?? this.freeOnly,
    hasTicketsLeft: hasTicketsLeft ?? this.hasTicketsLeft,
    sort: sort ?? this.sort,
  );

  bool matches(Event e) {
    if (category != null && e.category != category) return false;
    if (freeOnly && !e.isFree) return false;
    if (maxPrice != null && e.minPrice > maxPrice!) return false;
    if (hasTicketsLeft && e.isSoldOut) return false;
    return true;
  }

  List<Event> apply(Iterable<Event> events, {required LatLng origin}) {
    final list = events.where(matches).toList();
    return sortEvents(list, sort, origin: origin);
  }

  @override
  bool operator ==(Object other) =>
      other is EventFilter &&
      other.category == category &&
      other.maxPrice == maxPrice &&
      other.freeOnly == freeOnly &&
      other.hasTicketsLeft == hasTicketsLeft &&
      other.sort == sort;

  @override
  int get hashCode =>
      Object.hash(category, maxPrice, freeOnly, hasTicketsLeft, sort);
}

List<Event> sortEvents(
  List<Event> events,
  EventSort sort, {
  required LatLng origin,
}) {
  final list = [...events];
  switch (sort) {
    case EventSort.recommended:
      // Featured picks first, then soonest. Phase 6 replaces this with the
      // SmartFeedScorer.
      list.sort((a, b) {
        final ra = a.featuredRank ?? 1 << 20;
        final rb = b.featuredRank ?? 1 << 20;
        if (ra != rb) return ra.compareTo(rb);
        return a.startAt.compareTo(b.startAt);
      });
    case EventSort.soonest:
      list.sort((a, b) => a.startAt.compareTo(b.startAt));
    case EventSort.nearest:
      return sortByDistance(
        list,
        origin,
        (e) => LatLng(e.latitude, e.longitude),
      );
    case EventSort.priceLow:
      list.sort((a, b) {
        final c = a.minPrice.compareTo(b.minPrice);
        return c != 0 ? c : a.startAt.compareTo(b.startAt);
      });
    case EventSort.popular:
      list.sort((a, b) => b.participantsCount.compareTo(a.participantsCount));
  }
  return list;
}

/// Free-text match on title, venue, address and category.
bool matchesQuery(Event e, String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  return e.title.toLowerCase().contains(q) ||
      e.venue.toLowerCase().contains(q) ||
      e.address.toLowerCase().contains(q) ||
      e.category.label.toLowerCase().contains(q);
}

/// Saturday 00:00 to Monday 00:00 of the current (or coming) weekend.
({DateTime start, DateTime end}) weekendRange(DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final daysToSat = (DateTime.saturday - today.weekday) % 7;
  final sat = now.weekday == DateTime.sunday
      ? today.subtract(const Duration(days: 1))
      : today.add(Duration(days: daysToSat));
  return (start: sat, end: sat.add(const Duration(days: 2)));
}

/// Home sections below the carousel.
class HomeSections {
  const HomeSections({
    required this.trending,
    required this.becauseYouLikeMusic,
    required this.free,
    required this.thisWeekend,
  });

  factory HomeSections.from(List<Event> upcoming, DateTime now) {
    final weekend = weekendRange(now);
    final byPopularity = [...upcoming]
      ..sort((a, b) => b.participantsCount.compareTo(a.participantsCount));
    return HomeSections(
      trending: byPopularity.take(8).toList(),
      becauseYouLikeMusic: upcoming
          .where((e) => e.category == EventCategory.music)
          .take(8)
          .toList(),
      free: upcoming.where((e) => e.isFree).take(8).toList(),
      thisWeekend: upcoming
          .where(
            (e) =>
                !e.startAt.isBefore(weekend.start) &&
                e.startAt.isBefore(weekend.end),
          )
          .toList(),
    );
  }

  final List<Event> trending;
  final List<Event> becauseYouLikeMusic;
  final List<Event> free;
  final List<Event> thisWeekend;
}
