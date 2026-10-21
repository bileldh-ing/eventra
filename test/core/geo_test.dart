import 'package:eventra/core/utils/geo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('haversineKm', () {
    test('is zero for the same point', () {
      const p = LatLng(41.147, -73.9895);
      expect(haversineKm(p, p), 0);
    });

    test('matches the known Paris - London distance (~343.5 km)', () {
      const paris = LatLng(48.8566, 2.3522);
      const london = LatLng(51.5074, -0.1278);
      expect(haversineKm(paris, london), closeTo(343.5, 1));
    });

    test('is symmetric', () {
      const a = LatLng(36.8065, 10.1815);
      const b = LatLng(40.7128, -74.006);
      expect(haversineKm(a, b), closeTo(haversineKm(b, a), 1e-9));
    });

    test('one degree of latitude is ~111.2 km', () {
      expect(
        haversineKm(const LatLng(0, 0), const LatLng(1, 0)),
        closeTo(111.19, 0.05),
      );
    });
  });

  test('formatKm uses two decimals and KM suffix', () {
    expect(formatKm(5.2149), '5.21KM');
    expect(formatKm(3.1), '3.10KM');
  });

  test('sortByDistance orders nearest first and is stable', () {
    const origin = LatLng(0, 0);
    final sorted = sortByDistance(
      ['far', 'near', 'mid', 'near2'],
      origin,
      (s) => switch (s) {
        'far' => const LatLng(3, 0),
        'mid' => const LatLng(2, 0),
        _ => const LatLng(1, 0),
      },
    );
    expect(sorted, ['near', 'near2', 'mid', 'far']);
  });
}
