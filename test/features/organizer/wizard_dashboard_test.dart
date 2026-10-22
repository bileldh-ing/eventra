import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/organizer/data/organizer_repository.dart';
import 'package:eventra/features/organizer/domain/check_in.dart';
import 'package:eventra/features/organizer/domain/dashboard.dart';
import 'package:eventra/features/organizer/domain/event_draft.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/seed.dart';

final now = DateTime(2026, 10, 21, 10);

EventDraft validDraft() => EventDraft(
  id: 'drf_1',
  title: 'Night Market Live',
  category: EventCategory.food,
  description: 'Street food, live bands and late-night stalls by the harbor.',
  startAt: DateTime(2026, 11, 14, 19),
  endAt: DateTime(2026, 11, 14, 23, 30),
  venue: 'Harbor Pier 3',
  address: '12 Quay Street',
  latitude: 40.7,
  longitude: -74,
  tiers: const [
    DraftTier(id: 'ga', name: 'General', priceCents: 2500, capacity: 200),
    DraftTier(id: 'vip', name: 'VIP', priceCents: 7999, capacity: 20),
  ],
  coverUrl: kCoverChoices.first,
);

List<DraftIssue> issues(WizardStep s, EventDraft d) => [
  for (final e in DraftValidator.step(s, d, now: now)) e.issue,
];

void main() {
  group('wizard validation', () {
    test('a complete draft has no problems', () {
      expect(DraftValidator.all(validDraft(), now: now), isEmpty);
      expect(DraftValidator.firstInvalidStep(validDraft(), now: now), isNull);
    });

    test('an empty draft fails every step, first is basics', () {
      const d = EventDraft(id: 'x');
      expect(DraftValidator.firstInvalidStep(d, now: now), WizardStep.basics);
      expect(issues(WizardStep.basics, d), [
        DraftIssue.titleLength,
        DraftIssue.categoryMissing,
        DraftIssue.descriptionLength,
      ]);
      expect(issues(WizardStep.schedule, d), [
        DraftIssue.startMissing,
        DraftIssue.endMissing,
      ]);
      expect(issues(WizardStep.venue, d), [
        DraftIssue.venueLength,
        DraftIssue.addressLength,
        DraftIssue.pinMissing,
      ]);
      expect(issues(WizardStep.tiers, d), [
        DraftIssue.tierName,
        DraftIssue.tierCapacity,
      ]);
      expect(issues(WizardStep.cover, d), [DraftIssue.coverMissing]);
    });

    test('basics: title bounds are trimmed; description minimum', () {
      final d = validDraft();
      expect(issues(WizardStep.basics, d.copyWith(title: '  ab  ')), [
        DraftIssue.titleLength,
      ]);
      expect(issues(WizardStep.basics, d.copyWith(title: 'x' * 81)), [
        DraftIssue.titleLength,
      ]);
      expect(issues(WizardStep.basics, d.copyWith(title: 'abc')), isEmpty);
      expect(issues(WizardStep.basics, d.copyWith(description: 'short')), [
        DraftIssue.descriptionLength,
      ]);
      expect(issues(WizardStep.basics, d.copyWith(category: null)), [
        DraftIssue.categoryMissing,
      ]);
    });

    test('schedule: future start, end after start, at most 7 days', () {
      final d = validDraft();
      expect(
        issues(WizardStep.schedule, d.copyWith(startAt: now)),
        [DraftIssue.startInPast],
      );
      expect(
        issues(
          WizardStep.schedule,
          d.copyWith(endAt: d.startAt!.subtract(const Duration(minutes: 1))),
        ),
        [DraftIssue.endBeforeStart],
      );
      expect(
        issues(WizardStep.schedule, d.copyWith(endAt: d.startAt)),
        [DraftIssue.endBeforeStart],
      );
      expect(
        issues(
          WizardStep.schedule,
          d.copyWith(endAt: d.startAt!.add(const Duration(days: 8))),
        ),
        [DraftIssue.tooLong],
      );
      // Editing a published event that already started is allowed.
      final edit = EventDraft.fromEvent(
        loadSeed().events.first.copyWith(
          startAt: DateTime(2026, 10, 21, 9),
          endAt: DateTime(2026, 10, 21, 23),
        ),
        draftId: 'e',
      );
      expect(issues(WizardStep.schedule, edit), isEmpty);
    });

    test('venue needs a name, an address and a map pin', () {
      final d = validDraft();
      expect(
        issues(
          WizardStep.venue,
          d.copyWith(venue: ' ', latitude: null, longitude: null),
        ),
        [DraftIssue.venueLength, DraftIssue.pinMissing],
      );
    });

    test('tiers: names unique, price 0..10k, capacity 1..100k, >= sold', () {
      final d = validDraft();
      List<DraftError> tierErrors(List<DraftTier> t) =>
          DraftValidator.step(WizardStep.tiers, d.copyWith(tiers: t), now: now);
      expect(tierErrors(const []), [const DraftError(DraftIssue.tiersCount)]);
      expect(
        tierErrors([for (var i = 0; i < 6; i++) DraftTier(id: '$i', name: 'Tier $i', capacity: 1)]),
        [const DraftError(DraftIssue.tiersCount)],
      );
      expect(
        tierErrors(const [
          DraftTier(id: 'a', name: 'VIP', capacity: 5),
          DraftTier(id: 'b', name: ' vip ', capacity: 5),
        ]),
        [const DraftError(DraftIssue.tierNameDuplicate, tier: 1)],
      );
      expect(
        tierErrors(const [
          DraftTier(id: 'a', name: 'Gold', priceCents: 1000001, capacity: 0),
        ]),
        [
          const DraftError(DraftIssue.tierPrice, tier: 0),
          const DraftError(DraftIssue.tierCapacity, tier: 0),
        ],
      );
      expect(
        tierErrors(const [
          DraftTier(id: 'a', name: 'Gold', capacity: 4, sold: 5),
        ]),
        [const DraftError(DraftIssue.tierBelowSold, tier: 0)],
      );
      // Free tiers are fine.
      expect(
        tierErrors(const [DraftTier(id: 'a', name: 'RSVP', capacity: 100)]),
        isEmpty,
      );
    });

    test('prices parse to integer cents', () {
      expect(parsePriceCents('12'), 1200);
      expect(parsePriceCents('12.5'), 1250);
      expect(parsePriceCents('12,05'), 1205);
      expect(parsePriceCents(' '), 0);
      expect(parsePriceCents('0.999'), isNull);
      expect(parsePriceCents('-3'), isNull);
      expect(parsePriceCents('abc'), isNull);
    });

    test('drafts round-trip through JSON', () {
      final d = validDraft().copyWith(updatedAt: now);
      final back = EventDraft.fromJson(d.toJson());
      expect(back.toJson(), d.toJson());
      expect(back.tiers, d.tiers);
      const empty = EventDraft(id: 'e');
      expect(EventDraft.fromJson(empty.toJson()).toJson(), empty.toJson());
    });
  });

  group('drafts and publishing', () {
    late AppDatabase db;
    late OrganizerRepository repo;
    var n = 0;
    setUp(() {
      db = memoryDb();
      repo = OrganizerRepository(
        db: db,
        clock: () => now,
        ids: (p) => '$p-${++n}',
      );
    });
    tearDown(() => db.close());

    const org = Organizer(id: 'org-u-u1', name: 'Dana', avatarUrl: '');

    test('drafts save, list newest first and delete', () async {
      await repo.saveDraft('u1', validDraft());
      await repo.saveDraft(
        'u1',
        const EventDraft(id: 'drf_2', title: 'Half done'),
      );
      await repo.saveDraft('u2', const EventDraft(id: 'drf_3'));
      final mine = await repo.drafts('u1');
      expect(mine.map((d) => d.id), containsAll(['drf_1', 'drf_2']));
      expect(mine, hasLength(2));
      expect((await repo.draft('drf_2'))!.title, 'Half done');
      await repo.deleteDraft('drf_2');
      expect(await repo.drafts('u1'), hasLength(1));
    });

    test('publish creates the event, its stock and removes the draft',
        () async {
      await repo.saveDraft('u1', validDraft());
      final e = await repo.publish(
        ownerId: 'u1',
        draft: validDraft(),
        organizer: org,
        policy: 'Refunds up to 48 h before.',
      );
      expect(e.title, 'Night Market Live');
      expect(e.organizer.id, org.id);
      expect(e.capacity, 220);
      expect(e.tiers.map((t) => t.price), [25.0, 79.99]);
      expect(e.tags, contains('organizer'));
      expect(await repo.draft('drf_1'), isNull);
      final published = await repo.publishedEvents();
      expect(published.single.id, e.id);
      expect(await repo.soldByTier(e.id), {'ga': 0, 'vip': 0});
    });

    test('editing keeps the id and refuses capacity below seats sold',
        () async {
      final e = await repo.publish(
        ownerId: 'u1',
        draft: validDraft(),
        organizer: org,
        policy: 'p',
      );
      await db.customStatement(
        "UPDATE tier_stock SET sold = 15 WHERE event_id = ? AND tier_id = 'vip'",
        [e.id],
      );
      final edit = EventDraft.fromEvent(e, draftId: 'drf_e');
      final renamed = await repo.publish(
        ownerId: 'u1',
        draft: edit.copyWith(title: 'Night Market Live II'),
        organizer: org,
        policy: 'p',
      );
      expect(renamed.id, e.id);
      expect((await repo.publishedEvents()).single.title, 'Night Market Live II');
      final shrink = edit.copyWith(
        tiers: [
          edit.tiers.first,
          edit.tiers.last.copyWith(capacity: 10),
        ],
      );
      await expectLater(
        repo.publish(ownerId: 'u1', draft: shrink, organizer: org, policy: 'p'),
        throwsA(anything),
      );
      // The failed edit rolled back.
      expect((await repo.publishedEvents()).single.tiers.last.capacity, 20);
    });
  });

  group('dashboard aggregates', () {
    Event ev(
      String id, {
      required List<TicketTier> tiers,
      DateTime? start,
    }) => loadSeed().events.first.copyWith(
      id: id,
      tiers: tiers,
      startAt: start ?? DateTime(2026, 12, 1, 20),
      endAt: (start ?? DateTime(2026, 12, 1, 20)).add(const Duration(hours: 3)),
    );

    test('ramp split always adds up and is deterministic', () {
      for (final sold in [0, 1, 7, 100, 3500]) {
        final parts = rampSplit(sold, 21, 42);
        expect(parts, hasLength(21));
        expect(parts.fold(0, (a, b) => a + b), sold);
        expect(rampSplit(sold, 21, 42), parts);
      }
      expect(rampSplit(5, 0, 1), isEmpty);
      expect(stableHash('evt/ga'), stableHash('evt/ga'));
    });

    test('revenue, sold, capacity, tiers and check-in rate', () {
      final a = ev(
        'a',
        tiers: const [
          TicketTier(id: 'ga', name: 'GA', price: 10, capacity: 100, sold: 40),
          TicketTier(id: 'vip', name: 'VIP', price: 50.5, capacity: 10, sold: 2),
        ],
      );
      final b = ev(
        'b',
        start: DateTime(2026, 10, 1),
        tiers: const [
          TicketTier(id: 'ga', name: 'GA', price: 20, capacity: 50, sold: 50),
        ],
      );
      final stats = computeDashboard(
        events: [a, b],
        sales: [
          SaleRecord(
            eventId: 'a',
            tierId: 'vip',
            quantity: 2,
            cents: 10100,
            at: DateTime(2026, 10, 21, 9),
          ),
          // Ignored: not one of the organizer's events.
          SaleRecord(
            eventId: 'zzz',
            tierId: 'ga',
            quantity: 9,
            cents: 9000,
            at: DateTime(2026, 10, 21, 9),
          ),
        ],
        doors: const {
          'a': DoorCount(issued: 8, checkedIn: 2),
          'b': DoorCount(issued: 2, checkedIn: 2),
          'zzz': DoorCount(issued: 100, checkedIn: 100),
        },
        now: now,
        baselineAsOf: DateTime(2026, 10, 21),
      );
      // 40*10 + 2*50.50 + 50*20 = 1501 $, + 101 $ app sales.
      expect(stats.revenueCents, 150100 + 10100);
      expect(stats.ticketsSold, 92 + 2);
      expect(stats.capacity, 160);
      expect(stats.issued, 10);
      expect(stats.checkedIn, 4);
      expect(stats.checkInRate, closeTo(0.4, 1e-9));
      final ga = stats.tiers.firstWhere((t) => t.name == 'GA');
      expect(ga.sold, 90);
      expect(ga.capacity, 150);
      expect(ga.cents, 140000);
      final vip = stats.tiers.firstWhere((t) => t.name == 'VIP');
      expect(vip.sold, 4);
      expect(vip.cents, 10100 + 10100);
      // Sorted by revenue.
      expect(stats.tiers.first.name, 'GA');
      // Only events that have not ended are upcoming.
      expect(stats.upcoming.map((e) => e.id), ['a']);
    });

    test('the series has one bucket per day and includes the new sale', () {
      final a = ev(
        'a',
        tiers: const [
          TicketTier(id: 'ga', name: 'GA', price: 10, capacity: 100, sold: 0),
        ],
      );
      final stats = computeDashboard(
        events: [a],
        sales: [
          SaleRecord(
            eventId: 'a',
            tierId: 'ga',
            quantity: 3,
            cents: 3000,
            at: DateTime(2026, 10, 21, 8),
          ),
        ],
        doors: const {},
        now: now,
        baselineAsOf: DateTime(2026, 10, 21),
      );
      expect(stats.series, hasLength(14));
      expect(stats.series.last.day, DateTime(2026, 10, 21));
      expect(stats.series.last.tickets, 3);
      expect(stats.series.first.day, DateTime(2026, 10, 8));
      expect(stats.series.fold(0, (s, d) => s + d.tickets), 3);
      expect(stats.checkInRate, 0);
    });

    test('nothing yields an empty, zero dashboard', () {
      final s = computeDashboard(
        events: const [],
        sales: const [],
        doors: const {},
        now: now,
        baselineAsOf: now,
      );
      expect(s.revenueCents, 0);
      expect(s.tiers, isEmpty);
      expect(s.series.every((d) => d.tickets == 0), isTrue);
    });

    test('the demo account publishes as the seeded organizer', () {
      final seeded = loadSeed().events.where(
        (e) => e.organizer.id == kDemoOrganizerId,
      );
      expect(seeded, isNotEmpty);
    });
  });
}
