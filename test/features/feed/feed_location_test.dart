import 'package:eventra/core/location/location_service.dart';
import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/core/storage/storage_providers.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/onboarding/domain/home_city.dart';
import 'package:eventra/features/onboarding/presentation/onboarding_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

void main() {
  ProviderContainer container(MemoryPrefsStore prefs) {
    final c = ProviderContainer(
      overrides: [prefsStoreProvider.overrideWithValue(prefs)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('without a home city, distances start from the default area', () {
    final c = container(MemoryPrefsStore());
    final loc = c.read(userLocationProvider);
    expect(loc.position, kDefaultLocation);
    expect(loc.fromDevice, isFalse);
  });

  test('the onboarding city is the origin, and follows a new choice', () async {
    final yonkers = kHomeCities.firstWhere((h) => h.name == 'Yonkers');
    final c = container(
      MemoryPrefsStore({'location.homeCity': yonkers.encode()}),
    );
    expect(
      c.read(userLocationProvider).position,
      LatLng(yonkers.lat, yonkers.lng),
    );
    expect(c.read(userLocationProvider).label, 'Yonkers, NY');

    final nyack = kHomeCities.firstWhere((h) => h.name == 'Nyack');
    await c.read(homeCityProvider.notifier).choose(nyack);
    expect(c.read(userLocationProvider).position, LatLng(nyack.lat, nyack.lng));
  });
}
