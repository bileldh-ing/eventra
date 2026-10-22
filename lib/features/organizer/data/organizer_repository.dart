import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/organizer/domain/check_in.dart';
import 'package:eventra/features/organizer/domain/dashboard.dart';
import 'package:eventra/features/organizer/domain/event_draft.dart';
import 'package:eventra/features/tickets/data/ticketing_repository.dart';
import 'package:eventra/features/tickets/domain/qr_token.dart';

/// Organizer data on the local database: drafts, published events, the
/// door list and check-ins.
///
/// Check-in is a single conditional `UPDATE tickets SET status = 'used'
/// ... WHERE status = 'valid'`, so a ticket is admitted exactly once even if
/// two scans race. Every check-in also lands in `checkins` with
/// `synced = 0`: the door works fully offline and the queue drains to the
/// server later.
class OrganizerRepository {
  OrganizerRepository({
    required this.db,
    DateTime Function()? clock,
    String Function(String prefix)? ids,
  }) : _clock = clock ?? DateTime.now,
       _ids = ids ?? TicketingRepository.newId;

  final AppDatabase db;
  final DateTime Function() _clock;
  final String Function(String prefix) _ids;

  int get _nowMs => _clock().millisecondsSinceEpoch;

  static DateTime _at(int ms) => DateTime.fromMillisecondsSinceEpoch(ms);

  // ------------------------------------------------------------ events

  /// Every event published from organizer mode (shown in the attendee feed).
  Future<List<Event>> publishedEvents() async {
    final rows = await db
        .customSelect('SELECT payload FROM organizer_events')
        .get();
    return [
      for (final r in rows)
        Event.fromJson(
          jsonDecode(r.read<String>('payload')) as Map<String, dynamic>,
        ),
    ];
  }

  Future<Event?> publishedEvent(String id) async {
    final r = await db
        .customSelect(
          'SELECT payload FROM organizer_events WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    return r == null
        ? null
        : Event.fromJson(
            jsonDecode(r.read<String>('payload')) as Map<String, dynamic>,
          );
  }

  /// Seats sold per tier according to live stock (catalogue + app sales).
  Future<Map<String, int>> soldByTier(String eventId) async {
    final rows = await db
        .customSelect(
          'SELECT tier_id, sold, held FROM tier_stock WHERE event_id = ?',
          variables: [Variable.withString(eventId)],
        )
        .get();
    return {
      for (final r in rows)
        r.read<String>('tier_id'): r.read<int>('sold') + r.read<int>('held'),
    };
  }

  // ------------------------------------------------------------ drafts

  Future<List<EventDraft>> drafts(String ownerId) async {
    final rows = await db
        .customSelect(
          'SELECT payload FROM event_drafts WHERE owner_id = ? '
          'ORDER BY updated_at DESC',
          variables: [Variable.withString(ownerId)],
        )
        .get();
    return [for (final r in rows) _draft(r.read<String>('payload'))];
  }

  Future<EventDraft?> draft(String id) async {
    final r = await db
        .customSelect(
          'SELECT payload FROM event_drafts WHERE id = ?',
          variables: [Variable.withString(id)],
        )
        .getSingleOrNull();
    return r == null ? null : _draft(r.read<String>('payload'));
  }

  EventDraft _draft(String json) =>
      EventDraft.fromJson(jsonDecode(json) as Map<String, dynamic>);

  String newDraftId() => _ids('drf');

  /// Saves (or replaces) a draft; returns it stamped with the save time.
  Future<EventDraft> saveDraft(String ownerId, EventDraft d) async {
    final saved = d.copyWith(updatedAt: _clock());
    await db.customInsert(
      'INSERT OR REPLACE INTO event_drafts '
      '(id, owner_id, event_id, payload, updated_at) VALUES (?, ?, ?, ?, ?)',
      variables: [
        Variable.withString(d.id),
        Variable.withString(ownerId),
        Variable<String>(d.eventId),
        Variable.withString(jsonEncode(saved.toJson())),
        Variable.withInt(_nowMs),
      ],
    );
    return saved;
  }

  Future<void> deleteDraft(String id) => db.customStatement(
    'DELETE FROM event_drafts WHERE id = ?',
    [id],
  );

  /// Publishes a valid draft: a new event, or the update of one already
  /// published. Tier capacity changes go through `tier_stock`, whose CHECK
  /// refuses a capacity below the seats already sold or held.
  Future<Event> publish({
    required String ownerId,
    required EventDraft draft,
    required Organizer organizer,
    required String policy,
  }) => db.transaction(() async {
    final previous = draft.eventId == null
        ? null
        : await publishedEvent(draft.eventId!);
    final id = draft.eventId ?? _ids('evt-u');
    final event = draft.toEvent(
      eventId: id,
      organizer: organizer,
      policy: policy,
      previous: previous,
    );
    final payload = jsonEncode(event.toJson());
    if (previous == null) {
      await db.customInsert(
        'INSERT INTO organizer_events '
        '(id, owner_id, organizer_id, payload, created_at, updated_at) '
        'VALUES (?, ?, ?, ?, ?, ?)',
        variables: [
          Variable.withString(id),
          Variable.withString(ownerId),
          Variable.withString(organizer.id),
          Variable.withString(payload),
          Variable.withInt(_nowMs),
          Variable.withInt(_nowMs),
        ],
      );
    } else {
      await db.customUpdate(
        'UPDATE organizer_events SET payload = ?, updated_at = ? '
        'WHERE id = ?',
        variables: [
          Variable.withString(payload),
          Variable.withInt(_nowMs),
          Variable.withString(id),
        ],
      );
    }
    for (final t in event.tiers) {
      await db.customInsert(
        'INSERT OR IGNORE INTO tier_stock '
        '(event_id, tier_id, capacity, sold, held) VALUES (?, ?, ?, 0, 0)',
        variables: [
          Variable.withString(id),
          Variable.withString(t.id),
          Variable.withInt(t.capacity),
        ],
      );
      await db.customUpdate(
        'UPDATE tier_stock SET capacity = ? WHERE event_id = ? AND tier_id = ?',
        variables: [
          Variable.withInt(t.capacity),
          Variable.withString(id),
          Variable.withString(t.id),
        ],
      );
    }
    await deleteDraft(draft.id);
    return event;
  });

  // ---------------------------------------------------------- dashboard

  /// Paid sales recorded through the app for [eventIds] (demo history and
  /// refunded orders excluded).
  Future<List<SaleRecord>> sales(Set<String> eventIds) async {
    if (eventIds.isEmpty) return const [];
    final marks = List.filled(eventIds.length, '?').join(', ');
    final rows = await db
        .customSelect(
          'SELECT o.event_id, o.created_at, i.tier_id, i.quantity, '
          'i.unit_cents FROM orders o JOIN order_items i ON i.order_id = o.id '
          "WHERE o.status = 'paid' AND o.idempotency_key NOT LIKE 'demo:%' "
          'AND o.event_id IN ($marks)',
          variables: [for (final id in eventIds) Variable.withString(id)],
        )
        .get();
    return [
      for (final r in rows)
        SaleRecord(
          eventId: r.read<String>('event_id'),
          tierId: r.read<String>('tier_id'),
          quantity: r.read<int>('quantity'),
          cents: r.read<int>('quantity') * r.read<int>('unit_cents'),
          at: _at(r.read<int>('created_at')),
        ),
    ];
  }

  /// Door-list sizes and check-ins per event (cancelled tickets excluded).
  Future<Map<String, DoorCount>> doorCounts(Set<String> eventIds) async {
    if (eventIds.isEmpty) return const {};
    final marks = List.filled(eventIds.length, '?').join(', ');
    final rows = await db
        .customSelect(
          'SELECT event_id, '
          "SUM(CASE WHEN status != 'cancelled' THEN 1 ELSE 0 END) AS issued, "
          "SUM(CASE WHEN status = 'used' THEN 1 ELSE 0 END) AS used "
          'FROM tickets WHERE event_id IN ($marks) GROUP BY event_id',
          variables: [for (final id in eventIds) Variable.withString(id)],
        )
        .get();
    return {
      for (final r in rows)
        r.read<String>('event_id'): DoorCount(
          issued: r.read<int>('issued'),
          checkedIn: r.read<int>('used'),
        ),
    };
  }

  // ---------------------------------------------------------- door list

  static const _guestNames = [
    'Amira Ben Salah',
    'Lucas Martin',
    'Sofia Rossi',
    'Youssef Trabelsi',
    'Emma Laurent',
    'Omar Haddad',
    'Chloé Bernard',
    'Noah Fischer',
    'Lina Mansour',
    'Jade Moreau',
    'Karim Jaziri',
    'Maya Chen',
  ];

  /// Demo data: a door list for a seeded event, so check-in can be tried
  /// on the demo organizer account. Idempotent.
  Future<void> ensureGuestList(Event e, {int perTier = 4}) async {
    if (e.tiers.isEmpty) return;
    final existing = await db
        .customSelect(
          "SELECT COUNT(*) AS n FROM tickets WHERE order_id = 'seed-guests' "
          'AND event_id = ?',
          variables: [Variable.withString(e.id)],
        )
        .getSingle();
    if (existing.read<int>('n') > 0) return;
    await db.transaction(() async {
      var n = 0;
      for (final t in e.tiers) {
        final count = perTier.clamp(0, t.sold);
        for (var i = 0; i < count; i++) {
          final name = _guestNames[(stableHash(e.id) + n) % _guestNames.length];
          n++;
          await db.customInsert(
            'INSERT OR IGNORE INTO tickets (id, order_id, user_id, event_id, '
            'tier_id, tier_name, holder_name, status, seq) '
            "VALUES (?, 'seed-guests', ?, ?, ?, ?, ?, 'valid', ?)",
            variables: [
              Variable.withString('tkt_g_${e.id}_$n'),
              Variable.withString('guest-$n'),
              Variable.withString(e.id),
              Variable.withString(t.id),
              Variable.withString(t.name),
              Variable.withString(name),
              Variable.withInt(n),
            ],
          );
        }
      }
    });
  }

  /// Everyone holding a ticket to [eventId], by name.
  Future<List<Attendee>> attendees(String eventId) async {
    final rows = await db
        .customSelect(
          'SELECT t.id, t.holder_name, t.tier_name, t.status, c.at '
          'FROM tickets t LEFT JOIN checkins c ON c.ticket_id = t.id '
          'WHERE t.event_id = ? ORDER BY t.holder_name COLLATE NOCASE, t.id',
          variables: [Variable.withString(eventId)],
        )
        .get();
    return [
      for (final r in rows)
        Attendee(
          ticketId: r.read<String>('id'),
          holderName: r.read<String>('holder_name'),
          tierName: r.read<String>('tier_name'),
          cancelled: r.read<String>('status') == 'cancelled',
          checkedInAt: r.read<String>('status') == 'used'
              ? _at(r.read<int?>('at') ?? 0)
              : null,
        ),
    ];
  }

  // ------------------------------------------------------------ check-in

  /// Verifies a scanned QR [payload] for [eventId] and admits the ticket.
  ///
  /// Order of checks: signature and 30 s window (offline, HMAC), event
  /// match, the ticket exists and belongs to the signed holder, not
  /// cancelled, then the atomic first-use update.
  Future<CheckInResult> checkInCode(
    String payload, {
    required String eventId,
    required QrTokenService qr,
    CheckInMethod method = CheckInMethod.scan,
  }) async {
    final v = qr.verify(payload.trim(), now: _clock());
    switch (v.status) {
      case QrStatus.valid:
        break;
      case QrStatus.expired:
        return const CheckInResult(
          CheckInOutcome.invalid,
          reason: InvalidReason.expired,
        );
      case QrStatus.malformed:
      case QrStatus.badSignature:
      case QrStatus.notYetValid:
        return const CheckInResult(
          CheckInOutcome.invalid,
          reason: InvalidReason.forged,
        );
    }
    if (v.eventId != eventId) {
      return CheckInResult(
        CheckInOutcome.wrongEvent,
        ticketId: v.ticketId,
        otherEventId: v.eventId,
      );
    }
    return _admit(v.ticketId!, eventId, method, holderId: v.holderId);
  }

  /// Manual check-in from the door list (or a typed ticket id).
  Future<CheckInResult> checkInTicket(
    String ticketId, {
    required String eventId,
  }) => _admit(ticketId.trim(), eventId, CheckInMethod.manual);

  Future<CheckInResult> _admit(
    String ticketId,
    String eventId,
    CheckInMethod method, {
    String? holderId,
  }) => db.transaction(() async {
    final row = await db
        .customSelect(
          'SELECT t.user_id, t.event_id, t.holder_name, t.tier_name, '
          't.status, c.at FROM tickets t '
          'LEFT JOIN checkins c ON c.ticket_id = t.id WHERE t.id = ?',
          variables: [Variable.withString(ticketId)],
        )
        .getSingleOrNull();
    if (row == null ||
        (holderId != null && row.read<String>('user_id') != holderId)) {
      return const CheckInResult(
        CheckInOutcome.invalid,
        reason: InvalidReason.forged,
      );
    }
    final name = row.read<String>('holder_name');
    final tier = row.read<String>('tier_name');
    if (row.read<String>('event_id') != eventId) {
      return CheckInResult(
        CheckInOutcome.wrongEvent,
        ticketId: ticketId,
        holderName: name,
        tierName: tier,
        otherEventId: row.read<String>('event_id'),
      );
    }
    final status = row.read<String>('status');
    if (status == 'cancelled') {
      return CheckInResult(
        CheckInOutcome.cancelled,
        ticketId: ticketId,
        holderName: name,
        tierName: tier,
      );
    }
    final now = _nowMs;
    final changed = await db.customUpdate(
      "UPDATE tickets SET status = 'used' WHERE id = ? AND status = 'valid'",
      variables: [Variable.withString(ticketId)],
    );
    if (changed == 0) {
      final at = row.read<int?>('at');
      return CheckInResult(
        CheckInOutcome.alreadyCheckedIn,
        ticketId: ticketId,
        holderName: name,
        tierName: tier,
        checkedInAt: at == null ? null : _at(at),
      );
    }
    await db.customInsert(
      'INSERT OR REPLACE INTO checkins '
      '(ticket_id, event_id, at, method, synced) VALUES (?, ?, ?, ?, 0)',
      variables: [
        Variable.withString(ticketId),
        Variable.withString(eventId),
        Variable.withInt(now),
        Variable.withString(method.name),
      ],
    );
    return CheckInResult(
      CheckInOutcome.valid,
      ticketId: ticketId,
      holderName: name,
      tierName: tier,
      checkedInAt: _at(now),
    );
  });

  // -------------------------------------------------------- sync queue

  /// Check-ins recorded on this device that the server has not confirmed.
  Future<List<QueuedCheckIn>> pendingCheckIns() async {
    final rows = await db
        .customSelect(
          'SELECT * FROM checkins WHERE synced = 0 ORDER BY at',
        )
        .get();
    return [
      for (final r in rows)
        QueuedCheckIn(
          ticketId: r.read<String>('ticket_id'),
          eventId: r.read<String>('event_id'),
          at: _at(r.read<int>('at')),
          method: CheckInMethod.values.byName(r.read<String>('method')),
        ),
    ];
  }

  Future<void> markSynced(Iterable<String> ticketIds) async {
    for (final id in ticketIds) {
      await db.customUpdate(
        'UPDATE checkins SET synced = 1 WHERE ticket_id = ?',
        variables: [Variable.withString(id)],
      );
    }
  }
}

/// Where queued check-ins go when the device is online. Returns the ticket
/// ids the server accepted; throws when unreachable.
// ignore: one_member_abstracts
abstract interface class CheckInSync {
  Future<Set<String>> push(List<QueuedCheckIn> batch);
}

/// Local demo endpoint: accepts everything unless [online] is false.
class DemoCheckInSync implements CheckInSync {
  DemoCheckInSync({this.online = true});
  bool online;

  @override
  Future<Set<String>> push(List<QueuedCheckIn> batch) async {
    if (!online) throw const CheckInSyncOffline();
    return {for (final c in batch) c.ticketId};
  }
}

class CheckInSyncOffline implements Exception {
  const CheckInSyncOffline();
}
