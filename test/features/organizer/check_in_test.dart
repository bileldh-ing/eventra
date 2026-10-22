import 'package:drift/drift.dart' show Variable;
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/organizer/data/organizer_repository.dart';
import 'package:eventra/features/organizer/domain/check_in.dart';
import 'package:eventra/features/tickets/domain/qr_token.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/seed.dart';

class FakeClock {
  FakeClock(this.now);
  DateTime now;
  DateTime call() => now;
  void advance(Duration d) => now = now.add(d);
}

Event doorEvent(String id) {
  final base = loadSeed().events.firstWhere((e) => e.tiers.length == 3);
  return base.copyWith(
    id: id,
    tiers: const [
      TicketTier(
        id: 'ga',
        name: 'General Admission',
        price: 65,
        capacity: 50,
        sold: 10,
      ),
      TicketTier(id: 'vip', name: 'VIP', price: 143, capacity: 10, sold: 2),
    ],
  );
}

void main() {
  late AppDatabase db;
  late FakeClock clock;
  late OrganizerRepository repo;
  final qr = QrTokenService(List<int>.generate(32, (i) => i));
  final event = doorEvent('evt-door');
  final other = doorEvent('evt-other');
  const ticket = 'tkt_g_evt-door_1';
  const holder = 'guest-1';

  String code({String t = ticket, String e = 'evt-door', String h = holder}) =>
      qr.payload(ticketId: t, eventId: e, holderId: h, now: clock());

  setUp(() async {
    db = memoryDb();
    clock = FakeClock(DateTime(2026, 11, 2, 19, 30, 5));
    repo = OrganizerRepository(db: db, clock: clock.call);
    await repo.ensureGuestList(event, perTier: 2);
    await repo.ensureGuestList(other, perTier: 1);
  });
  tearDown(() => db.close());

  group('verification states', () {
    test('a fresh code is admitted with the holder and tier', () async {
      final r = await repo.checkInCode(code(), eventId: event.id, qr: qr);
      expect(r.outcome, CheckInOutcome.valid);
      expect(r.ticketId, ticket);
      expect(r.tierName, 'General Admission');
      expect(r.holderName, isNotEmpty);
      expect(r.checkedInAt, clock.now);
    });

    test('the previous 30 s window is still accepted (clock skew)', () async {
      final c = code();
      clock.advance(const Duration(seconds: 30));
      final r = await repo.checkInCode(c, eventId: event.id, qr: qr);
      expect(r.outcome, CheckInOutcome.valid);
    });

    test('a code older than its window is expired', () async {
      final c = code();
      clock.advance(const Duration(seconds: 61));
      final r = await repo.checkInCode(c, eventId: event.id, qr: qr);
      expect(r.outcome, CheckInOutcome.invalid);
      expect(r.reason, InvalidReason.expired);
    });

    test('a code from the future is rejected as forged', () async {
      final c = code();
      clock.advance(const Duration(minutes: -2));
      final r = await repo.checkInCode(c, eventId: event.id, qr: qr);
      expect(r.reason, InvalidReason.forged);
    });

    test('tampered payloads and foreign keys are forged', () async {
      final parts = code().split('.');
      final swapped = ([...parts]..[1] = 'tkt_g_evt-door_2').join('.');
      final foreign = QrTokenService(List<int>.filled(32, 7)).payload(
        ticketId: ticket,
        eventId: event.id,
        holderId: holder,
        now: clock(),
      );
      for (final c in [swapped, foreign, 'hello', 'ETK1.a.b.c.d.e', '']) {
        final r = await repo.checkInCode(c, eventId: event.id, qr: qr);
        expect(r.outcome, CheckInOutcome.invalid, reason: c);
        expect(r.reason, InvalidReason.forged, reason: c);
      }
    });

    test('a signed code for an unknown ticket or holder is forged', () async {
      final unknown = await repo.checkInCode(
        code(t: 'tkt_nope'),
        eventId: event.id,
        qr: qr,
      );
      expect(unknown.reason, InvalidReason.forged);
      final wrongHolder = await repo.checkInCode(
        code(h: 'someone-else'),
        eventId: event.id,
        qr: qr,
      );
      expect(wrongHolder.reason, InvalidReason.forged);
      expect(
        (await repo.attendees(event.id)).where((a) => a.checkedIn),
        isEmpty,
      );
    });

    test('a genuine ticket for another event is the wrong event', () async {
      final r = await repo.checkInCode(
        code(t: 'tkt_g_evt-other_1', e: other.id),
        eventId: event.id,
        qr: qr,
      );
      expect(r.outcome, CheckInOutcome.wrongEvent);
      expect(r.otherEventId, other.id);
      final manual = await repo.checkInTicket(
        'tkt_g_evt-other_1',
        eventId: event.id,
      );
      expect(manual.outcome, CheckInOutcome.wrongEvent);
    });

    test('a refunded ticket is cancelled and never admitted', () async {
      await db.customUpdate(
        "UPDATE tickets SET status = 'cancelled' WHERE id = ?",
        variables: [Variable.withString(ticket)],
      );
      final r = await repo.checkInCode(code(), eventId: event.id, qr: qr);
      expect(r.outcome, CheckInOutcome.cancelled);
      expect(await repo.pendingCheckIns(), isEmpty);
    });
  });

  group('idempotency', () {
    test('a second scan is already checked in, with the first time', () async {
      final first = await repo.checkInCode(code(), eventId: event.id, qr: qr);
      final at = first.checkedInAt;
      clock.advance(const Duration(seconds: 20));
      final second = await repo.checkInCode(code(), eventId: event.id, qr: qr);
      expect(second.outcome, CheckInOutcome.alreadyCheckedIn);
      expect(second.checkedInAt, at);
      final manual = await repo.checkInTicket(ticket, eventId: event.id);
      expect(manual.outcome, CheckInOutcome.alreadyCheckedIn);
    });

    test('concurrent scans admit exactly once', () async {
      final c = code();
      final results = await Future.wait([
        for (var i = 0; i < 5; i++)
          repo.checkInCode(c, eventId: event.id, qr: qr),
      ]);
      expect(results.where((r) => r.admitted), hasLength(1));
      expect(
        results.where((r) => r.outcome == CheckInOutcome.alreadyCheckedIn),
        hasLength(4),
      );
      expect(await repo.pendingCheckIns(), hasLength(1));
      final counts = await repo.doorCounts({event.id});
      expect(counts[event.id]!.checkedIn, 1);
      expect(counts[event.id]!.issued, 4);
    });
  });

  group('door list and offline queue', () {
    test('attendees are listed by name with check-in state', () async {
      await repo.checkInTicket(ticket, eventId: event.id);
      final list = await repo.attendees(event.id);
      expect(list, hasLength(4));
      final names = [for (final a in list) a.holderName.toLowerCase()];
      expect(names, [...names]..sort());
      expect(list.singleWhere((a) => a.ticketId == ticket).checkedIn, isTrue);
    });

    test('guest list seeding is idempotent and capped by sales', () async {
      await repo.ensureGuestList(event, perTier: 2);
      expect(await repo.attendees(event.id), hasLength(4));
      final tiny = doorEvent('evt-tiny').copyWith(
        tiers: const [
          TicketTier(id: 'ga', name: 'GA', price: 0, capacity: 10, sold: 1),
        ],
      );
      await repo.ensureGuestList(tiny);
      expect(await repo.attendees(tiny.id), hasLength(1));
    });

    test('check-ins queue offline and drain when back online', () async {
      await repo.checkInTicket(ticket, eventId: event.id);
      await repo.checkInTicket('tkt_g_evt-door_2', eventId: event.id);
      final pending = await repo.pendingCheckIns();
      expect(pending.map((c) => c.method), everyElement(CheckInMethod.manual));
      final sync = DemoCheckInSync(online: false);
      await expectLater(
        sync.push(pending),
        throwsA(isA<CheckInSyncOffline>()),
      );
      expect(await repo.pendingCheckIns(), hasLength(2));
      sync.online = true;
      await repo.markSynced(await sync.push(pending));
      expect(await repo.pendingCheckIns(), isEmpty);
      // Synced check-ins still count at the door.
      expect((await repo.doorCounts({event.id}))[event.id]!.checkedIn, 2);
    });
  });
}
