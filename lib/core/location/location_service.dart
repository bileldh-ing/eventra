import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// Default demo location (New City, NY - the area in the reference map),
/// used until the user grants location access. Matches the seed.
const kDefaultLocation = LatLng(41.1470, -73.9895);
const kDefaultLocationName = 'New City, NY';

enum LocationOutcome { granted, denied, deniedForever, serviceDisabled, error }

class LocationResult {
  const LocationResult(this.outcome, [this.position]);
  final LocationOutcome outcome;
  final LatLng? position;
}

/// Abstraction over the device GPS so tests and the map can swap it.
// ignore: one_member_abstracts
abstract interface class LocationService {
  Future<LocationResult> current();
}

/// geolocator-backed implementation: asks for permission only when called.
class GeolocatorLocationService implements LocationService {
  const GeolocatorLocationService();

  @override
  Future<LocationResult> current() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult(LocationOutcome.serviceDisabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult(LocationOutcome.deniedForever);
      }
      if (permission == LocationPermission.denied) {
        return const LocationResult(LocationOutcome.denied);
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
      return LocationResult(
        LocationOutcome.granted,
        LatLng(p.latitude, p.longitude),
      );
    } on Exception {
      return const LocationResult(LocationOutcome.error);
    }
  }
}
