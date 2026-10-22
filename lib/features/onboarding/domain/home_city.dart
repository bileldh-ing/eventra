import 'package:meta/meta.dart';

/// The area the feed and distances start from until GPS is allowed.
@immutable
class HomeCity {
  const HomeCity(this.name, this.region, this.lat, this.lng);

  final String name;
  final String region;
  final double lat;
  final double lng;

  String get label => '$name, $region';

  String encode() => '$name|$region|$lat|$lng';

  static HomeCity? decode(String? raw) {
    final p = raw?.split('|');
    if (p == null || p.length != 4) return null;
    final lat = double.tryParse(p[2]);
    final lng = double.tryParse(p[3]);
    if (lat == null || lng == null) return null;
    return HomeCity(p[0], p[1], lat, lng);
  }

  @override
  bool operator ==(Object other) =>
      other is HomeCity && other.name == name && other.region == region;

  @override
  int get hashCode => Object.hash(name, region);
}

/// Areas covered by the demo catalogue (events are seeded around New City,
/// NY), nearest first.
const kHomeCities = <HomeCity>[
  HomeCity('New City', 'NY', 41.1476, -73.9893),
  HomeCity('Nyack', 'NY', 41.0907, -73.9179),
  HomeCity('Spring Valley', 'NY', 41.1132, -74.0438),
  HomeCity('Suffern', 'NY', 41.1148, -74.1496),
  HomeCity('Tarrytown', 'NY', 41.0762, -73.8587),
  HomeCity('White Plains', 'NY', 41.0340, -73.7629),
  HomeCity('Yonkers', 'NY', 40.9312, -73.8988),
  HomeCity('New York', 'NY', 40.7128, -74.0060),
];
