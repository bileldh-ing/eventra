import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/feed/domain/smart_feed_scorer.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:eventra/features/onboarding/domain/interest.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../helpers/seed.dart';

void main() {
  final seed = loadSeed().events;
  final template = seed.first;
  // Wednesday.
  final now = DateTime(2026, 10, 21, 10);
  const origin = LatLng(41, -74);

  Event at(
    String id,
    DateTime start, {
    Duration length = const Duration(hours: 3),
  }) => template.copyWith(id: id, startAt: start, endAt: start.add(length));

  group('date presets', () {
    test('windows relative to now', () {
      expect(
        presetWindow(DatePreset.today, now, null),
        DateWindow(DateTime(2026, 10, 21), DateTime(2026, 10, 22)),
      );
      expect(
        presetWindow(DatePreset.tomorrow, now, null),
        DateWindow(DateTime(2026, 10, 22), DateTime(2026, 10, 23)),
      );
      expect(
        presetWindow(DatePreset.thisWeekend, now, null),
        DateWindow(DateTime(2026, 10, 24), DateTime(2026, 10, 26)),
      );
      expect(
        presetWindow(DatePreset.thisWeek, now, null),
        DateWindow(DateTime(2026, 10, 21), DateTime(2026, 10, 28)),
      );
      expect(presetWindow(DatePreset.any, now, null), isNull);
      expect(presetWindow(DatePreset.custom, now, null), isNull);
    });

    test('month boundaries roll over', () {
      final lastDay = DateTime(2026, 10, 31, 22);
      expect(
        presetWindow(DatePreset.tomorrow, lastDay, null),
        DateWindow(DateTime(2026, 11), DateTime(2026, 11, 2)),
      );
    });

    test('events match by overlap with the window', () {
      const today = EventFilter(datePreset: DatePreset.today);
      expect(
        today.matches(at('a', DateTime(2026, 10, 21, 20)), now: now),
        isTrue,
      );
      expect(
        today.matches(at('b', DateTime(2026, 10, 22)), now: now),
        isFalse,
      );
      // Started yesterday and still running.
      expect(
        today.matches(
          at('c', DateTime(2026, 10, 20, 22), length: const Duration(hours: 4)),
          now: now,
        ),
        isTrue,
      );
      const weekend = EventFilter(datePreset: DatePreset.thisWeekend);
      expect(
        weekend.matches(at('d', DateTime(2026, 10, 25, 23)), now: now),
        isTrue,
      );
      expect(
        weekend.matches(at('e', DateTime(2026, 10, 26, 9)), now: now),
        isFalse,
      );
    });

    test('custom range includes both end days', () {
      final f = EventFilter(
        datePreset: DatePreset.custom,
        customRange: DateWindow.days(
          DateTime(2026, 11, 3),
          DateTime(2026, 11, 5),
        ),
      );
      expect(f.hasDate, isTrue);
      expect(f.matches(at('a', DateTime(2026, 11, 5, 21)), now: now), isTrue);
      expect(f.matches(at('b', DateTime(2026, 11, 6)), now: now), isFalse);
      expect(f.matches(at('c', DateTime(2026, 11, 2, 18)), now: now), isFalse);
      // Custom without a range does not filter and is not counted.
      const empty = EventFilter(datePreset: DatePreset.custom);
      expect(empty.hasDate, isFalse);
      expect(empty.refinementCount, 0);
    });

    test('date criteria need a clock', () {
      const f = EventFilter(datePreset: DatePreset.today);
      expect(f.matches(at('x', DateTime(2027))), isTrue);
    });
  });

  test('multiple categories combine with OR', () {
    const f = EventFilter(categories: {EventCategory.music, EventCategory.art});
    final list = f.apply(seed, origin: origin, now: now);
    expect(list, isNotEmpty);
    expect(
      list.every(
        (e) =>
            e.category == EventCategory.music ||
            e.category == EventCategory.art,
      ),
      isTrue,
    );
    expect(
      list.length,
      seed.where((e) => f.categories.contains(e.category)).length,
    );
    expect(f.category, isNull);
    expect(f.refinementCount, 1);
    expect(
      const EventFilter(categories: {EventCategory.art}).refinementCount,
      0,
    );
  });

  test('toggleCategory and withCategory', () {
    final f = EventFilter.none
        .toggleCategory(EventCategory.music)
        .toggleCategory(EventCategory.tech);
    expect(f.categories, {EventCategory.music, EventCategory.tech});
    expect(f.toggleCategory(EventCategory.music).categories, {
      EventCategory.tech,
    });
    expect(f.withCategory(null).categories, isEmpty);
    expect(f.withCategory(EventCategory.art).category, EventCategory.art);
  });

  test('price range bounds the cheapest ticket', () {
    const f = EventFilter(minPrice: 10, maxPrice: 40);
    final list = f.apply(seed, origin: origin);
    expect(list, isNotEmpty);
    expect(list.every((e) => e.minPrice >= 10 && e.minPrice <= 40), isTrue);
    expect(f.refinementCount, 1);
  });

  test('distance radius from the origin', () {
    final near = seed.first.copyWith(id: 'n', latitude: 41.01, longitude: -74);
    final far = seed.first.copyWith(id: 'f', latitude: 41.5, longitude: -74);
    const f = EventFilter(maxDistanceKm: 10);
    expect(f.matches(near, origin: origin), isTrue);
    expect(f.matches(far, origin: origin), isFalse);
    // No origin: radius not applied.
    expect(f.matches(far), isTrue);
  });

  test('refinement count, default and equality ignore set order', () {
    const f = EventFilter(
      categories: {EventCategory.music, EventCategory.art},
      datePreset: DatePreset.tomorrow,
      maxPrice: 20,
      maxDistanceKm: 5,
      freeOnly: true,
      hasTicketsLeft: true,
      sort: EventSort.soonest,
    );
    expect(f.refinementCount, 7);
    expect(f.isDefault, isFalse);
    final same = f.copyWith(
      categories: {EventCategory.art, EventCategory.music},
    );
    expect(same, f);
    expect(same.hashCode, f.hashCode);
    expect(f.copyWith(maxPrice: () => null).hasPrice, isFalse);
    expect(EventFilter.none.isDefault, isTrue);
  });

  test('Recommended sort uses the smart feed when given a profile', () {
    final profile = FeedProfile(
      origin: origin,
      now: now,
      interests: const [Interest.sports],
    );
    final list = EventFilter.none.apply(seed, origin: origin, profile: profile);
    expect(list.first.category, EventCategory.sports);
    expect(list.length, seed.length);
  });

  test('home sections build interest rows from the profile', () {
    final profile = FeedProfile(
      origin: origin,
      now: now,
      interests: const [Interest.music, Interest.nightlife, Interest.tech],
    );
    final s = HomeSections.from(seed, now, profile: profile);
    // Nightlife (music + social) is not fully covered by Music, so it gets
    // the second row; Tech would be a third and is capped.
    expect(s.interestRows.map((r) => r.title), [
      'Because You Like Music',
      'Because You Like Nightlife',
    ]);
    expect(
      s.interestRows.first.events.every(
        (e) => e.category == EventCategory.music,
      ),
      isTrue,
    );
    final generic = HomeSections.from(
      seed,
      now,
      profile: FeedProfile(origin: origin, now: now),
    );
    expect(generic.interestRows.single.title, 'Recommended For You');
    final covered = HomeSections.from(
      seed,
      now,
      profile: FeedProfile(
        origin: origin,
        now: now,
        interests: const [Interest.tech, Interest.business],
      ),
    );
    // Business only covers Tech, already shown: skipped.
    expect(covered.interestRows.length, 1);
  });
}
