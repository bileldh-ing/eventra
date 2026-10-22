import 'package:collection/collection.dart';
import 'package:eventra/core/utils/geo.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/feed/domain/smart_feed_scorer.dart';
import 'package:eventra/features/onboarding/domain/interest.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';

enum EventSort {
  recommended,
  soonest,
  nearest,
  priceLow,
  popular;

  /// Name in the active language.
  String get label {
    final l = AppLocale.l10n;
    return switch (this) {
      recommended => l.sortRecommended,
      soonest => l.sortSoonest,
      nearest => l.sortNearest,
      priceLow => l.sortPriceLow,
      popular => l.sortPopular,
    };
  }
}

enum DatePreset {
  any,
  today,
  tomorrow,
  thisWeekend,
  thisWeek,
  custom;

  /// Name in the active language.
  String get label {
    final l = AppLocale.l10n;
    return switch (this) {
      any => l.dateAny,
      today => l.dateToday,
      tomorrow => l.dateTomorrow,
      thisWeekend => l.dateThisWeekend,
      thisWeek => l.dateNext7,
      custom => l.datePick,
    };
  }
}

/// A half-open [start, end) window.
@immutable
class DateWindow {
  const DateWindow(this.start, this.end);

  /// Whole days from [first] to [last], both included.
  factory DateWindow.days(DateTime first, DateTime last) => DateWindow(
    DateTime(first.year, first.month, first.day),
    DateTime(last.year, last.month, last.day + 1),
  );

  final DateTime start;
  final DateTime end;

  /// True when the event runs at any point inside the window.
  bool overlaps(DateTime from, DateTime to) =>
      from.isBefore(end) && to.isAfter(start);

  @override
  bool operator ==(Object other) =>
      other is DateWindow && other.start == start && other.end == end;

  @override
  int get hashCode => Object.hash(start, end);
}

/// The window a preset covers relative to [now] (null = no date limit).
DateWindow? presetWindow(DatePreset preset, DateTime now, DateWindow? custom) {
  final today = DateTime(now.year, now.month, now.day);
  return switch (preset) {
    DatePreset.any => null,
    DatePreset.today => DateWindow(
      today,
      DateTime(now.year, now.month, now.day + 1),
    ),
    DatePreset.tomorrow => DateWindow(
      DateTime(now.year, now.month, now.day + 1),
      DateTime(now.year, now.month, now.day + 2),
    ),
    DatePreset.thisWeekend => () {
      final w = weekendRange(now);
      return DateWindow(w.start, w.end);
    }(),
    DatePreset.thisWeek => DateWindow(
      today,
      DateTime(now.year, now.month, now.day + 7),
    ),
    DatePreset.custom => custom,
  };
}

/// Immutable discovery filter shared by Home, See All, Search, Explore and
/// the Filters sheet.
@immutable
class EventFilter {
  const EventFilter({
    this.categories = const {},
    this.datePreset = DatePreset.any,
    this.customRange,
    this.minPrice,
    this.maxPrice,
    this.maxDistanceKm,
    this.freeOnly = false,
    this.hasTicketsLeft = false,
    this.sort = EventSort.recommended,
  });

  static const none = EventFilter();

  /// Empty = every category ("See All").
  final Set<EventCategory> categories;
  final DatePreset datePreset;

  /// Used when [datePreset] is [DatePreset.custom].
  final DateWindow? customRange;

  /// Cheapest ticket bounds (null = open ended).
  final double? minPrice;
  final double? maxPrice;

  /// Radius from the current origin (null = any distance).
  final double? maxDistanceKm;
  final bool freeOnly;
  final bool hasTicketsLeft;
  final EventSort sort;

  /// The single selected category (what the Home chips show), else null.
  EventCategory? get category =>
      categories.length == 1 ? categories.first : null;

  bool get hasDate =>
      datePreset != DatePreset.any &&
      (datePreset != DatePreset.custom || customRange != null);

  bool get hasPrice => minPrice != null || maxPrice != null;

  bool get isDefault => categories.isEmpty && refinementCount == 0;

  /// Number of refinements beyond a single chip category (badge on the
  /// filter button).
  int get refinementCount =>
      (categories.length > 1 ? 1 : 0) +
      (hasDate ? 1 : 0) +
      (hasPrice ? 1 : 0) +
      (maxDistanceKm != null ? 1 : 0) +
      (freeOnly ? 1 : 0) +
      (hasTicketsLeft ? 1 : 0) +
      (sort != EventSort.recommended ? 1 : 0);

  /// Chip selection: one category, or all when [c] is null.
  EventFilter withCategory(EventCategory? c) =>
      copyWith(categories: c == null ? const {} : {c});

  EventFilter toggleCategory(EventCategory c) => copyWith(
    categories: categories.contains(c)
        ? ({...categories}..remove(c))
        : {...categories, c},
  );

  EventFilter copyWith({
    Set<EventCategory>? categories,
    DatePreset? datePreset,
    DateWindow? Function()? customRange,
    double? Function()? minPrice,
    double? Function()? maxPrice,
    double? Function()? maxDistanceKm,
    bool? freeOnly,
    bool? hasTicketsLeft,
    EventSort? sort,
  }) => EventFilter(
    categories: categories ?? this.categories,
    datePreset: datePreset ?? this.datePreset,
    customRange: customRange != null ? customRange() : this.customRange,
    minPrice: minPrice != null ? minPrice() : this.minPrice,
    maxPrice: maxPrice != null ? maxPrice() : this.maxPrice,
    maxDistanceKm: maxDistanceKm != null ? maxDistanceKm() : this.maxDistanceKm,
    freeOnly: freeOnly ?? this.freeOnly,
    hasTicketsLeft: hasTicketsLeft ?? this.hasTicketsLeft,
    sort: sort ?? this.sort,
  );

  /// [now] is needed for date presets and [origin] for the distance radius;
  /// a criterion whose input is missing is not applied.
  bool matches(Event e, {DateTime? now, LatLng? origin}) {
    if (categories.isNotEmpty && !categories.contains(e.category)) {
      return false;
    }
    if (freeOnly && !e.isFree) return false;
    if (minPrice != null && e.minPrice < minPrice!) return false;
    if (maxPrice != null && e.minPrice > maxPrice!) return false;
    if (hasTicketsLeft && e.isSoldOut) return false;
    if (maxDistanceKm != null && origin != null) {
      final km = haversineKm(origin, LatLng(e.latitude, e.longitude));
      if (km > maxDistanceKm!) return false;
    }
    if (now != null) {
      final w = presetWindow(datePreset, now, customRange);
      if (w != null && !w.overlaps(e.startAt, e.endAt)) return false;
    }
    return true;
  }

  /// Filters then sorts. The Recommended sort uses the smart feed when a
  /// [profile] is given.
  List<Event> apply(
    Iterable<Event> events, {
    required LatLng origin,
    DateTime? now,
    FeedProfile? profile,
  }) {
    final list = events
        .where((e) => matches(e, now: now ?? profile?.now, origin: origin))
        .toList();
    return sortEvents(list, sort, origin: origin, profile: profile);
  }

  @override
  bool operator ==(Object other) =>
      other is EventFilter &&
      const SetEquality<EventCategory>().equals(other.categories, categories) &&
      other.datePreset == datePreset &&
      other.customRange == customRange &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.maxDistanceKm == maxDistanceKm &&
      other.freeOnly == freeOnly &&
      other.hasTicketsLeft == hasTicketsLeft &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
    Object.hashAllUnordered(categories),
    datePreset,
    customRange,
    minPrice,
    maxPrice,
    maxDistanceKm,
    freeOnly,
    hasTicketsLeft,
    sort,
  );
}

List<Event> sortEvents(
  List<Event> events,
  EventSort sort, {
  required LatLng origin,
  FeedProfile? profile,
}) {
  final list = [...events];
  switch (sort) {
    case EventSort.recommended:
      if (profile != null) return const SmartFeedScorer().feed(list, profile);
      // Without a profile: featured picks first, then soonest.
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
      (e.category.label.toLowerCase().contains(q) ||
          e.category.name.contains(q));
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

/// A "Because you like X" row.
@immutable
class InterestRow {
  const InterestRow(this.interest, this.events);

  /// null for the generic "Recommended for you" row (no interests yet).
  final Interest? interest;
  final List<Event> events;

  String get title => interest == null
      ? AppLocale.l10n.rowRecommendedForYou
      : AppLocale.l10n.rowBecauseYouLike(interest!.label);
}

/// Home sections below the carousel.
class HomeSections {
  const HomeSections({
    required this.trending,
    required this.interestRows,
    required this.free,
    required this.thisWeekend,
  });

  /// Rows are ordered by the smart feed when [profile] is given. Up to
  /// [maxInterestRows] interest rows; an interest whose categories are all
  /// covered by an earlier row is skipped.
  factory HomeSections.from(
    List<Event> upcoming,
    DateTime now, {
    FeedProfile? profile,
    int maxInterestRows = 2,
  }) {
    const scorer = SmartFeedScorer();
    List<Event> ranked(Iterable<Event> events) =>
        profile == null ? events.toList() : scorer.rank(events, profile);

    final weekend = weekendRange(now);
    final byPopularity = [...upcoming]
      ..sort((a, b) => b.participantsCount.compareTo(a.participantsCount));

    final rows = <InterestRow>[];
    final covered = <EventCategory>{};
    for (final i in profile?.interests ?? const <Interest>[]) {
      if (rows.length >= maxInterestRows) break;
      if (covered.containsAll(i.categories)) continue;
      final events = ranked(
        upcoming.where((e) => i.categories.contains(e.category)),
      ).take(8).toList();
      if (events.isEmpty) continue;
      covered.addAll(i.categories);
      rows.add(InterestRow(i, events));
    }
    if (rows.isEmpty && profile != null) {
      rows.add(InterestRow(null, ranked(upcoming).take(8).toList()));
    }

    return HomeSections(
      trending: byPopularity.take(8).toList(),
      interestRows: rows,
      free: ranked(upcoming.where((e) => e.isFree)).take(8).toList(),
      thisWeekend: ranked(
        upcoming.where(
          (e) =>
              !e.startAt.isBefore(weekend.start) &&
              e.startAt.isBefore(weekend.end),
        ),
      ),
    );
  }

  final List<Event> trending;
  final List<InterestRow> interestRows;
  final List<Event> free;
  final List<Event> thisWeekend;
}
