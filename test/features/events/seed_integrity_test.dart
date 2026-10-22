import 'package:eventra/core/utils/geo.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../helpers/seed.dart';

void main() {
  final seed = loadSeed();
  final events = seed.events;
  Iterable<String> titles() => events.map((e) => e.title);

  test('has at least 50 events across all 8 categories', () {
    expect(events.length, greaterThanOrEqualTo(50));
    expect(events.map((e) => e.category).toSet(), EventCategory.values.toSet());
  });

  test('ids are unique', () {
    expect(events.map((e) => e.id).toSet().length, events.length);
  });

  test('coordinates are valid', () {
    for (final e in events) {
      expect(e.latitude, inInclusiveRange(-90, 90), reason: e.id);
      expect(e.longitude, inInclusiveRange(-180, 180), reason: e.id);
      expect(e.latitude == 0 && e.longitude == 0, isFalse, reason: e.id);
    }
  });

  test('every event has 4+ distinct images and a cover from the gallery', () {
    for (final e in events) {
      expect(e.gallery.toSet().length, greaterThanOrEqualTo(4), reason: e.id);
      expect(e.gallery, contains(e.coverImageUrl), reason: e.id);
      expect(Uri.parse(e.coverImageUrl).scheme, 'https');
    }
  });

  test('dates are after the seed generation date and end after start', () {
    for (final e in events) {
      // `evt-p*` are past events (reviews need finished events).
      if (e.id.startsWith('evt-p')) {
        expect(e.endAt.isBefore(seed.generatedAt), isTrue, reason: e.id);
      } else {
        expect(e.startAt.isAfter(seed.generatedAt), isTrue, reason: e.id);
      }
      expect(e.endAt.isAfter(e.startAt), isTrue, reason: e.id);
    }
  });

  test('tiers are consistent: sold never exceeds capacity', () {
    for (final e in events) {
      expect(e.tiers, isNotEmpty);
      for (final t in e.tiers) {
        expect(t.sold, inInclusiveRange(0, t.capacity), reason: e.id);
        expect(t.price, greaterThanOrEqualTo(0));
      }
      expect(e.description.toLowerCase(), isNot(contains('lorem')));
      expect(e.reviews.length, 3);
      expect(e.lineup, isNotEmpty);
    }
  });

  test('contains the reference sample events', () {
    expect(
      titles(),
      containsAll([
        'Highland Music Festival',
        'Pitchfork Music Night',
        'Harbor Art Festival',
        'National Music Festival',
      ]),
    );
    final highland = events.firstWhere(
      (e) => e.title == 'Highland Music Festival',
    );
    expect(highland.startAt.month, 6);
    expect(highland.startAt.day, 20);
    expect(highland.startAt.hour, 23);
    expect(highland.address, '4517 Manchester');
    expect(highland.participantsCount - 3, 12);

    final pitchfork = events.firstWhere(
      (e) => e.title == 'Pitchfork Music Night',
    );
    expect(pitchfork.price, 50);
    expect(pitchfork.startAt.month, 2);
    expect(pitchfork.startAt.day, 11);
    expect(pitchfork.startAt.hour, 22);
    expect(pitchfork.startAt.minute, 20);
    expect(pitchfork.address, '4523 Washington');
    expect(pitchfork.participantsCount - 4, 30);
  });

  test('Harbor Art 5.21 km and National Music 3.11 km from the default', () {
    double km(String title) {
      final e = events.firstWhere((e) => e.title == title);
      return haversineKm(seed.defaultLocation, LatLng(e.latitude, e.longitude));
    }

    expect(formatKm(km('Harbor Art Festival')), '5.21KM');
    expect(formatKm(km('National Music Festival')), '3.11KM');
  });

  test('has free events, a sold-out event and events this weekend', () {
    expect(events.where((e) => e.isFree).length, greaterThanOrEqualTo(5));
    expect(events.where((e) => e.isSoldOut), isNotEmpty);
  });
}
