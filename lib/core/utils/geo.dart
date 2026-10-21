import 'dart:math' as math;

import 'package:latlong2/latlong.dart';

/// Mean Earth radius (IUGG) in kilometres.
const double kEarthRadiusKm = 6371.0088;

/// Great-circle distance in kilometres (Haversine formula).
double haversineKm(LatLng a, LatLng b) {
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(b.latitude - a.latitude);
  final dLng = rad(b.longitude - a.longitude);
  final h =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(a.latitude)) *
          math.cos(rad(b.latitude)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * kEarthRadiusKm * math.asin(math.sqrt(h));
}

/// '5.21KM' style label used in the Nearest Location list.
String formatKm(double km) => '${km.toStringAsFixed(2)}KM';

/// Sorts [items] by distance from [origin], nearest first. Stable for ties.
List<T> sortByDistance<T>(
  Iterable<T> items,
  LatLng origin,
  LatLng Function(T) locate,
) {
  final indexed = items.toList().asMap().entries.toList()
    ..sort((x, y) {
      final c = haversineKm(
        origin,
        locate(x.value),
      ).compareTo(haversineKm(origin, locate(y.value)));
      return c != 0 ? c : x.key.compareTo(y.key);
    });
  return [for (final e in indexed) e.value];
}
