import 'package:eventra/core/storage/storage_providers.dart';
import 'package:eventra/features/onboarding/domain/home_city.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _homeCityKey = 'location.homeCity';

/// The city picked during onboarding (null until chosen or skipped).
class HomeCityNotifier extends Notifier<HomeCity?> {
  @override
  HomeCity? build() =>
      HomeCity.decode(ref.read(prefsStoreProvider).getString(_homeCityKey));

  Future<void> choose(HomeCity city) async {
    state = city;
    await ref.read(prefsStoreProvider).setString(_homeCityKey, city.encode());
  }
}

final homeCityProvider = NotifierProvider<HomeCityNotifier, HomeCity?>(
  HomeCityNotifier.new,
);
