import 'package:eventra/core/utils/geo.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:latlong2/latlong.dart';
import 'package:meta/meta.dart';

/// An event with its distance from the current origin.
@immutable
class NearbyEvent {
  const NearbyEvent(this.event, this.km);
  final Event event;
  final double km;

  LatLng get point => LatLng(event.latitude, event.longitude);
}

/// Events sorted nearest first from [origin] (Haversine), optionally
/// narrowed by a free-text [query] and a [filter].
List<NearbyEvent> nearestEvents(
  Iterable<Event> events,
  LatLng origin, {
  String query = '',
  EventFilter filter = EventFilter.none,
  DateTime? now,
}) {
  final list = [
    for (final e in events)
      if (matchesQuery(e, query) && filter.matches(e, now: now))
        NearbyEvent(e, haversineKm(origin, LatLng(e.latitude, e.longitude))),
  ]..sort((a, b) => a.km.compareTo(b.km));
  return list;
}

/// Short street addresses ('4523 Washington') get the country appended on the
/// map, as in the reference ('4523 Washington USA').
String mapAddress(Event e) =>
    e.address.contains(',') || e.address.endsWith('USA')
    ? e.address
    : '${e.address} USA';
