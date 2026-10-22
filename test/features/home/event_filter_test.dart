import 'package:eventra/core/location/location_service.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/seed.dart';

void main() {
  final events = loadSeed().events;
  const origin = kDefaultLocation;

  test('default filter keeps everything, featured first', () {
    final list = EventFilter.none.apply(events, origin: origin);
    expect(list.length, events.length);
    expect(list.take(3).every((e) => e.featured), isTrue);
    expect(list.first.title, 'Highland Music Festival');
  });

  test('category, free and max price filters combine', () {
    final music = const EventFilter(
      categories: {EventCategory.music},
    ).apply(events, origin: origin);
    expect(music.every((e) => e.category == EventCategory.music), isTrue);

    final free = const EventFilter(
      freeOnly: true,
    ).apply(events, origin: origin);
    expect(free, isNotEmpty);
    expect(free.every((e) => e.isFree), isTrue);

    final cheap = const EventFilter(maxPrice: 15).apply(events, origin: origin);
    expect(cheap.every((e) => e.minPrice <= 15), isTrue);
  });

  test('has tickets left hides sold-out events', () {
    final list = const EventFilter(
      hasTicketsLeft: true,
    ).apply(events, origin: origin);
    expect(list.any((e) => e.isSoldOut), isFalse);
    expect(
      list.length,
      events.length - events.where((e) => e.isSoldOut).length,
    );
  });

  test('sorts: soonest, price, popular, nearest', () {
    final soonest = const EventFilter(
      sort: EventSort.soonest,
    ).apply(events, origin: origin);
    for (var i = 1; i < soonest.length; i++) {
      expect(soonest[i].startAt.isBefore(soonest[i - 1].startAt), isFalse);
    }
    final price = const EventFilter(
      sort: EventSort.priceLow,
    ).apply(events, origin: origin);
    expect(price.first.minPrice, 0);
    final popular = const EventFilter(
      sort: EventSort.popular,
    ).apply(events, origin: origin);
    expect(
      popular.first.participantsCount,
      greaterThanOrEqualTo(popular.last.participantsCount),
    );
    final nearest = const EventFilter(
      sort: EventSort.nearest,
    ).apply(events, origin: origin);
    expect(nearest.first.title, 'Pitchfork Music Night');
    expect(nearest[1].title, 'National Music Festival');
    expect(nearest[2].title, 'Harbor Art Festival');
  });

  test('refinement count and equality', () {
    const f = EventFilter(freeOnly: true, sort: EventSort.popular);
    expect(f.refinementCount, 2);
    expect(f, const EventFilter(freeOnly: true, sort: EventSort.popular));
    expect(f.isDefault, isFalse);
    expect(
      f.withCategory(EventCategory.art).category,
      EventCategory.art,
    );
    expect(EventFilter.none.isDefault, isTrue);
  });

  test('query matches title, venue, address and category', () {
    final e = events.firstWhere((e) => e.title == 'Pitchfork Music Night');
    expect(matchesQuery(e, 'pitch'), isTrue);
    expect(matchesQuery(e, 'washington'), isTrue);
    expect(matchesQuery(e, 'music'), isTrue);
    expect(matchesQuery(e, 'zzz'), isFalse);
    expect(matchesQuery(e, '  '), isTrue);
  });

  test('weekend range covers the coming Saturday and Sunday', () {
    final wed = DateTime(2026, 10, 21, 10);
    final r = weekendRange(wed);
    expect(r.start, DateTime(2026, 10, 24));
    expect(r.end, DateTime(2026, 10, 26));
    final sun = DateTime(2026, 10, 25, 9);
    expect(weekendRange(sun).start, DateTime(2026, 10, 24));
  });

  test('home sections are built from upcoming events', () {
    final s = HomeSections.from(events, DateTime(2026, 10, 21, 10));
    expect(s.trending.length, 8);
    // No profile: no interest rows.
    expect(s.interestRows, isEmpty);
    expect(s.free.every((e) => e.isFree), isTrue);
    expect(s.thisWeekend, isNotEmpty);
  });
}
