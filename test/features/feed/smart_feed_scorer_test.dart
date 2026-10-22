import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/feed/domain/smart_feed_scorer.dart';
import 'package:eventra/features/onboarding/domain/interest.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../helpers/seed.dart';

void main() {
  const scorer = SmartFeedScorer();
  final now = DateTime(2026, 10, 21, 10);
  const origin = LatLng(41, -74);
  final seed = loadSeed().events;
  final template = seed.first;

  /// A controllable event at [km] north of the origin (~111.2 km per degree).
  Event ev(
    String id, {
    EventCategory category = EventCategory.art,
    double km = 100,
    int participants = 0,
    double rating = 0,
    double daysAhead = 60,
    String organizer = 'org-x',
    List<String> tags = const [],
  }) => template.copyWith(
    id: id,
    category: category,
    latitude: origin.latitude + km / 111.19,
    longitude: origin.longitude,
    participantsCount: participants,
    rating: rating,
    startAt: now.add(Duration(minutes: (daysAhead * 24 * 60).round())),
    endAt: now.add(Duration(minutes: (daysAhead * 24 * 60).round() + 120)),
    organizer: template.organizer.copyWith(id: organizer),
    tags: tags,
  );

  FeedProfile profile({
    List<Interest> interests = const [],
    List<Event> saved = const [],
  }) => FeedProfile(
    origin: origin,
    now: now,
    interests: interests,
    saved: saved,
  );

  test('weights add up to 100', () {
    expect(
      SmartFeedScorer.wInterests +
          SmartFeedScorer.wProximity +
          SmartFeedScorer.wPopularity +
          SmartFeedScorer.wRecency +
          SmartFeedScorer.wSocial,
      100,
    );
  });

  test('a perfect event scores 100, an irrelevant one about 0', () {
    final fav = ev('saved', category: EventCategory.music, organizer: 'o1');
    final best = ev(
      'best',
      category: EventCategory.music,
      km: 0,
      participants: SmartFeedScorer.popularityCap,
      rating: 5,
      daysAhead: 0,
      organizer: 'o1',
    );
    final s = scorer.score(
      best,
      profile(interests: [Interest.music], saved: [fav]),
    );
    expect(s.interests, 35);
    expect(s.proximity, 25);
    expect(s.popularity, closeTo(15, 1e-9));
    expect(s.recency, 15);
    expect(s.social, 10);
    expect(s.total, closeTo(100, 1e-9));

    final worst = scorer.score(ev('w', km: 500, daysAhead: 3650), profile());
    expect(worst.total, lessThan(0.1));
    expect(worst.reasons, isEmpty);
  });

  test('interest match is worth exactly 35 (any covering interest)', () {
    final e = ev('a', category: EventCategory.music);
    final none = scorer.score(e, profile(interests: [Interest.art]));
    final music = scorer.score(e, profile(interests: [Interest.music]));
    final nightlife = scorer.score(e, profile(interests: [Interest.nightlife]));
    expect(music.total - none.total, closeTo(35, 1e-9));
    expect(nightlife.interests, 35);
  });

  test('proximity boundaries: full to 1 km, linear, zero from 40 km', () {
    expect(SmartFeedScorer.proximityFactor(0), 1);
    expect(SmartFeedScorer.proximityFactor(1), 1);
    expect(SmartFeedScorer.proximityFactor(20.5), closeTo(0.5, 1e-9));
    expect(SmartFeedScorer.proximityFactor(40), 0);
    expect(SmartFeedScorer.proximityFactor(400), 0);
    final near = scorer.score(ev('n', km: 3), profile());
    final far = scorer.score(ev('f', km: 30), profile());
    expect(near.proximity, greaterThan(far.proximity));
    expect(near.distanceKm, closeTo(3, 0.05));
  });

  test('popularity is log scaled, capped, and includes rating', () {
    expect(SmartFeedScorer.popularityFactor(ev('a')), 0);
    final capped = SmartFeedScorer.popularityFactor(
      ev('b', participants: SmartFeedScorer.popularityCap * 10),
    );
    expect(capped, closeTo(0.7, 1e-9));
    final rated = SmartFeedScorer.popularityFactor(ev('c', rating: 5));
    expect(rated, closeTo(0.3, 1e-9));
    final mid = SmartFeedScorer.popularityFactor(ev('d', participants: 100));
    expect(mid, greaterThan(0.3));
    expect(mid, lessThan(0.7));
  });

  test('recency halves every 14 days and is full once started', () {
    expect(SmartFeedScorer.recencyFactor(-2), 1);
    expect(SmartFeedScorer.recencyFactor(0), 1);
    expect(SmartFeedScorer.recencyFactor(14), closeTo(0.5, 1e-9));
    expect(SmartFeedScorer.recencyFactor(28), closeTo(0.25, 1e-9));
    final soon = scorer.score(ev('s', daysAhead: 2), profile());
    final later = scorer.score(ev('l', daysAhead: 40), profile());
    expect(soon.recency, greaterThan(later.recency));
  });

  test('saved affinity: same organizer is full, categories ramp to 3', () {
    final target = ev('t', category: EventCategory.food);
    expect(SmartFeedScorer.savedAffinity(target, const []), 0);
    final oneFood = [ev('s1', category: EventCategory.food, organizer: 'o9')];
    expect(
      SmartFeedScorer.savedAffinity(target, oneFood),
      closeTo(1 / 3, 1e-9),
    );
    final threeFood = [
      for (var i = 0; i < 4; i++)
        ev('s$i', category: EventCategory.food, organizer: 'o$i'),
    ];
    expect(SmartFeedScorer.savedAffinity(target, threeFood), 1);
    final sameOrg = [ev('o', category: EventCategory.tech)];
    expect(SmartFeedScorer.savedAffinity(target, sameOrg), 1);
    // The event itself never counts.
    expect(SmartFeedScorer.savedAffinity(target, [target]), 0);
  });

  test('reasons: at most 3, strongest first, readable labels', () {
    final e = ev(
      'r',
      category: EventCategory.music,
      km: 2,
      participants: 900,
      daysAhead: 3,
    );
    final s = scorer.score(
      e,
      profile(
        interests: [Interest.music],
        saved: [ev('x', category: EventCategory.music)],
      ),
    );
    expect(s.reasons.length, 3);
    expect(s.reasons.first.label, 'Because you like Music');
    expect(s.reasons[1].label, 'Near you');
    expect(s.reasons.map((r) => r.kind), isNot(contains(FeedReasonKind.saved)));
  });

  test('reason thresholds: Near you <= 5 km, Trending >= 500, soon <= 7 d', () {
    List<FeedReasonKind> kinds(Event e) =>
        scorer.score(e, profile()).reasons.map((r) => r.kind).toList();
    expect(kinds(ev('a', km: 4.9)), contains(FeedReasonKind.nearby));
    expect(kinds(ev('b', km: 5.2)), isNot(contains(FeedReasonKind.nearby)));
    expect(
      kinds(ev('c', participants: 500)),
      contains(FeedReasonKind.trending),
    );
    expect(
      kinds(ev('d', participants: 499)),
      isNot(contains(FeedReasonKind.trending)),
    );
    expect(
      scorer.score(ev('e', daysAhead: 0.5), profile()).reasons.single.label,
      'Starts soon',
    );
    expect(
      scorer.score(ev('f', daysAhead: 6), profile()).reasons.single.label,
      'This week',
    );
    expect(kinds(ev('g', daysAhead: 8)), isEmpty);
  });

  test('ranking is deterministic and breaks ties by start, then id', () {
    final p = profile(interests: [Interest.music, Interest.tech]);
    final shuffled = [...seed]..shuffle();
    final a = scorer.rank(seed, p).map((e) => e.id).toList();
    final b = scorer.rank(shuffled, p).map((e) => e.id).toList();
    expect(a, b);
    expect(scorer.rank(seed, p).map((e) => e.id), a);

    final twinB = ev('b');
    final twinA = ev('a');
    final earlier = ev('z', daysAhead: 59.99);
    final ranked = scorer.rank([twinB, twinA], profile());
    expect(ranked.map((e) => e.id), ['a', 'b']);
    expect(scorer.rank([twinA, earlier], profile()).first.id, 'z');
  });

  test('interests reorder the feed', () {
    final music = scorer.rank(seed, profile(interests: [Interest.music]));
    final sports = scorer.rank(seed, profile(interests: [Interest.sports]));
    expect(
      music.take(5).every((e) => e.category == EventCategory.music),
      isTrue,
    );
    expect(
      sports.take(5).every((e) => e.category == EventCategory.sports),
      isTrue,
    );
  });

  test('feed pins editorial picks only when they match the interests', () {
    final withMusic = scorer.feed(seed, profile(interests: [Interest.music]));
    expect(withMusic.first.title, 'Highland Music Festival');
    expect(withMusic.take(3).every((e) => e.featured), isTrue);

    final noInterests = scorer.feed(seed, profile());
    expect(noInterests.first.featuredRank, 1);

    final sportsOnly = scorer.feed(seed, profile(interests: [Interest.sports]));
    expect(sportsOnly.first.category, EventCategory.sports);
    expect(sportsOnly.first.featured, isFalse);
    expect(sportsOnly.length, seed.length);
  });
}
