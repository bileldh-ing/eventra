import 'package:eventra/core/location/location_service.dart';
import 'package:eventra/core/utils/geo.dart';
import 'package:eventra/features/explore/domain/nearest.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../helpers/seed.dart';

void main() {
  final events = loadSeed().events;

  test('sorts nearest first with Haversine distances', () {
    final list = nearestEvents(events, kDefaultLocation);
    expect(list, hasLength(events.length));
    for (var i = 1; i < list.length; i++) {
      expect(list[i].km, greaterThanOrEqualTo(list[i - 1].km));
    }
    expect(list.first.event.title, 'Pitchfork Music Night');
    String km(String title) =>
        formatKm(list.firstWhere((n) => n.event.title == title).km);
    expect(km('National Music Festival'), '3.11KM');
    expect(km('Harbor Art Festival'), '5.21KM');
  });

  test('re-sorts when the origin changes (locate me)', () {
    const nyack = LatLng(41.0906, -73.9180);
    final list = nearestEvents(events, nyack);
    expect(list.first.event.address, contains('Nyack'));
    expect(list.first.km, lessThan(0.5));
  });

  test('query narrows by title, venue or address', () {
    final list = nearestEvents(events, kDefaultLocation, query: 'harbor');
    expect(list.map((n) => n.event.title), contains('Harbor Art Festival'));
    expect(
      list.every(
        (n) => '${n.event.title} ${n.event.venue} ${n.event.address}'
            .toLowerCase()
            .contains('harbor'),
      ),
      isTrue,
    );
  });

  test('filters apply and the result stays distance sorted', () {
    final list = nearestEvents(
      events,
      kDefaultLocation,
      filter: const EventFilter(freeOnly: true),
    );
    expect(list, isNotEmpty);
    expect(list.every((n) => n.event.isFree), isTrue);
    for (var i = 1; i < list.length; i++) {
      expect(list[i].km, greaterThanOrEqualTo(list[i - 1].km));
    }
  });

  test('map address appends the country to short street addresses', () {
    final p = events.firstWhere((e) => e.title == 'Pitchfork Music Night');
    expect(mapAddress(p), '4523 Washington USA');
  });
}
