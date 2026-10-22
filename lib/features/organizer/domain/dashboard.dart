import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:meta/meta.dart';

/// A ticket sale recorded through the app (from a paid order).
@immutable
class SaleRecord {
  const SaleRecord({
    required this.eventId,
    required this.tierId,
    required this.quantity,
    required this.cents,
    required this.at,
  });
  final String eventId;
  final String tierId;
  final int quantity;

  /// Face value of the line (unit price x quantity), before fees and tax.
  final int cents;
  final DateTime at;
}

/// Door counts for one event: tickets on the guest list and those checked in.
@immutable
class DoorCount {
  const DoorCount({required this.issued, required this.checkedIn});
  final int issued;
  final int checkedIn;
}

@immutable
class DaySales {
  const DaySales(this.day, this.tickets, this.cents);
  final DateTime day;
  final int tickets;
  final int cents;
}

@immutable
class TierSales {
  const TierSales({
    required this.name,
    required this.sold,
    required this.capacity,
    required this.cents,
  });
  final String name;
  final int sold;
  final int capacity;
  final int cents;
  double get fill => capacity == 0 ? 0 : sold / capacity;
}

@immutable
class DashboardStats {
  const DashboardStats({
    required this.revenueCents,
    required this.ticketsSold,
    required this.capacity,
    required this.issued,
    required this.checkedIn,
    required this.series,
    required this.tiers,
    required this.upcoming,
  });

  static const empty = DashboardStats(
    revenueCents: 0,
    ticketsSold: 0,
    capacity: 0,
    issued: 0,
    checkedIn: 0,
    series: [],
    tiers: [],
    upcoming: [],
  );

  final int revenueCents;
  final int ticketsSold;
  final int capacity;

  /// Tickets on the door lists (QR tickets that can be checked in).
  final int issued;
  final int checkedIn;

  /// One entry per day, oldest first.
  final List<DaySales> series;

  /// Tier totals across the organizer's events, merged by tier name.
  final List<TierSales> tiers;

  /// Events that have not ended, soonest first.
  final List<Event> upcoming;

  /// 0..1; 0 when nothing is on the door list yet.
  double get checkInRate => issued == 0 ? 0 : checkedIn / issued;
}

/// Small FNV-1a hash that is the same on every run and platform.
int stableHash(String s) {
  var h = 0x811c9dc5;
  for (final c in s.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0x7fffffff;
  }
  return h;
}

DateTime _day(DateTime t) => DateTime(t.year, t.month, t.day);

/// Spreads a catalogue tier's pre-existing sales over the [days] days
/// before the baseline date with a deterministic ramp (more sales closer to the
/// date), so the chart has history for seeded events. The parts always add
/// up to [sold] exactly.
List<int> rampSplit(int sold, int days, int salt) {
  if (days <= 0) return const [];
  final weights = [
    for (var i = 0; i < days; i++) (i + 1) * 3 + ((salt + i * 7) % 5),
  ];
  final total = weights.fold(0, (a, b) => a + b);
  final parts = [for (final w in weights) sold * w ~/ total];
  var rest = sold - parts.fold(0, (a, b) => a + b);
  for (var i = days - 1; rest > 0; i = (i - 1 + days) % days) {
    parts[i]++;
    rest--;
  }
  return parts;
}

/// Aggregates the organizer dashboard. Pure: every input is passed in.
///
/// - Revenue and tickets sold = catalogue sales already on each tier
///   ([Event.tiers] `sold`, booked before the app tracked them, spread over
///   the [historyDays] days before [baselineAsOf]) + sales recorded through
///   the app ([sales]).
/// - Check-in rate = checked in / tickets on the door lists ([doors]).
DashboardStats computeDashboard({
  required List<Event> events,
  required List<SaleRecord> sales,
  required Map<String, DoorCount> doors,
  required DateTime now,
  required DateTime baselineAsOf,
  int days = 14,
  int historyDays = 21,
}) {
  final today = _day(now);
  final first = today.subtract(Duration(days: days - 1));
  final buckets = <DateTime, (int, int)>{
    for (var i = 0; i < days; i++)
      DateTime(first.year, first.month, first.day + i): (0, 0),
  };
  void add(DateTime at, int qty, int cents) {
    final k = _day(at);
    final b = buckets[k];
    if (b != null) buckets[k] = (b.$1 + qty, b.$2 + cents);
  }

  var revenue = 0;
  var sold = 0;
  var capacity = 0;
  final tiers = <String, (int, int, int)>{}; // name -> sold, capacity, cents
  final ids = {for (final e in events) e.id};
  final base = _day(baselineAsOf);

  for (final e in events) {
    capacity += e.tiers.fold(0, (s, t) => s + t.capacity);
    for (final t in e.tiers) {
      final unit = (t.price * 100).round();
      revenue += t.sold * unit;
      sold += t.sold;
      final prev = tiers[t.name] ?? (0, 0, 0);
      tiers[t.name] = (
        prev.$1 + t.sold,
        prev.$2 + t.capacity,
        prev.$3 + t.sold * unit,
      );
      final parts = rampSplit(
        t.sold,
        historyDays,
        stableHash('${e.id}/${t.id}'),
      );
      for (var i = 0; i < parts.length; i++) {
        if (parts[i] == 0) continue;
        add(
          DateTime(base.year, base.month, base.day - historyDays + 1 + i),
          parts[i],
          parts[i] * unit,
        );
      }
    }
  }
  final tierNameById = {
    for (final e in events)
      for (final t in e.tiers) '${e.id}/${t.id}': t.name,
  };
  for (final s in sales) {
    if (!ids.contains(s.eventId)) continue;
    revenue += s.cents;
    sold += s.quantity;
    add(s.at, s.quantity, s.cents);
    final name = tierNameById['${s.eventId}/${s.tierId}'];
    if (name != null) {
      final prev = tiers[name]!;
      tiers[name] = (prev.$1 + s.quantity, prev.$2, prev.$3 + s.cents);
    }
  }
  var issued = 0;
  var checkedIn = 0;
  for (final id in ids) {
    final d = doors[id];
    if (d == null) continue;
    issued += d.issued;
    checkedIn += d.checkedIn;
  }
  final upcoming = events.where((e) => e.endAt.isAfter(now)).toList()
    ..sort((a, b) => a.startAt.compareTo(b.startAt));
  final tierList = [
    for (final MapEntry(:key, :value) in tiers.entries)
      TierSales(
        name: key,
        sold: value.$1,
        capacity: value.$2,
        cents: value.$3,
      ),
  ]..sort((a, b) => b.cents.compareTo(a.cents));
  return DashboardStats(
    revenueCents: revenue,
    ticketsSold: sold,
    capacity: capacity,
    issued: issued,
    checkedIn: checkedIn,
    series: [
      for (final MapEntry(:key, :value) in buckets.entries)
        DaySales(key, value.$1, value.$2),
    ],
    tiers: tierList,
    upcoming: upcoming,
  );
}
