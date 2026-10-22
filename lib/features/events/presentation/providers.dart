import 'dart:async';

import 'package:collection/collection.dart';
import 'package:eventra/core/location/location_service.dart';
import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/events/data/backend/local_demo_backend.dart';
import 'package:eventra/features/events/data/backend/seed_source.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/data/repositories/local_events_repository.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/repositories/events_repository.dart';
import 'package:eventra/features/onboarding/presentation/onboarding_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart'
    show FutureProviderFamily, ProviderFamily;
import 'package:latlong2/latlong.dart';

/// Overridden in main() with the on-device database.
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw StateError('appDatabaseProvider must be overridden'),
);

final backendProvider = Provider<LocalDemoBackend>(
  (ref) => LocalDemoBackend(
    db: ref.watch(appDatabaseProvider),
    seedSource: const AssetSeedSource(),
  ),
);

final eventsRepositoryProvider = Provider<EventsRepository>(
  (ref) => LocalEventsRepository(ref.watch(backendProvider)),
);

final favoritesRepositoryProvider = Provider<FavoritesRepository>(
  (ref) => LocalFavoritesRepository(ref.watch(backendProvider)),
);

/// Injectable clock so "upcoming" and "this weekend" are testable.
final clockProvider = Provider<DateTime Function()>((ref) => DateTime.now);

final locationServiceProvider = Provider<LocationService>(
  (ref) => const GeolocatorLocationService(),
);

/// All events, ordered by start date.
class EventsNotifier extends AsyncNotifier<List<Event>> {
  @override
  Future<List<Event>> build() => _load();

  Future<List<Event>> _load() async {
    final result = await ref.read(eventsRepositoryProvider).getEvents();
    return switch (result) {
      Success(:final value) => value,
      Failure(:final failure) => throw FailureException(failure),
    };
  }

  /// Pull-to-refresh / retry. Keeps showing old data while reloading.
  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } on Object {
      // The error is exposed through `state`; nothing else to do here.
    }
  }
}

final eventsProvider = AsyncNotifierProvider<EventsNotifier, List<Event>>(
  EventsNotifier.new,
);

/// Upcoming events only (start in the future).
final upcomingEventsProvider = Provider<AsyncValue<List<Event>>>((ref) {
  final now = ref.watch(clockProvider)();
  return ref
      .watch(eventsProvider)
      .whenData((all) => all.where((e) => e.endAt.isAfter(now)).toList());
});

/// One event by id: served from the loaded list, else fetched.
final FutureProviderFamily<Event, String> eventByIdProvider =
    FutureProvider.family<Event, String>((ref, id) async {
      final cached = ref
          .watch(eventsProvider)
          .value
          ?.firstWhereOrNull(
            (e) => e.id == id,
          );
      if (cached != null) return cached;
      final r = await ref.read(eventsRepositoryProvider).getEvent(id);
      return switch (r) {
        Success(:final value) => value,
        Failure(:final failure) => throw FailureException(failure),
      };
    });

/// Saved event ids. Optimistic toggle, persisted through the repository.
class FavoritesNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    _init();
    return const {};
  }

  Future<void> _init() async {
    final r = await ref.read(favoritesRepositoryProvider).getFavoriteIds();
    if (r case Success(:final value)) {
      if (ref.mounted) state = {...state, ...value};
    }
  }

  bool isFavorite(String id) => state.contains(id);

  /// Returns the new saved state, or null when persisting failed (reverted).
  Future<bool?> toggle(String id) async {
    final before = state;
    final saved = !before.contains(id);
    state = saved ? {...before, id} : ({...before}..remove(id));
    unawaited(HapticFeedback.lightImpact());
    final r = await ref.read(favoritesRepositoryProvider).toggle(id);
    if (!ref.mounted) return null;
    if (r case Failure()) {
      state = before;
      return null;
    }
    return saved;
  }
}

final favoritesProvider = NotifierProvider<FavoritesNotifier, Set<String>>(
  FavoritesNotifier.new,
);

final ProviderFamily<bool, String> isFavoriteProvider =
    Provider.family<bool, String>(
      (ref, id) => ref.watch(favoritesProvider.select((s) => s.contains(id))),
    );

/// Where distances are measured from.
class UserLocation {
  const UserLocation({
    required this.position,
    required this.fromDevice,
    this.label = kDefaultLocationName,
  });
  final LatLng position;
  final bool fromDevice;
  final String label;
}

class UserLocationNotifier extends Notifier<UserLocation> {
  @override
  UserLocation build() {
    // The city chosen in onboarding is the origin until GPS is allowed.
    final city = ref.watch(homeCityProvider);
    if (city == null) {
      return const UserLocation(position: kDefaultLocation, fromDevice: false);
    }
    return UserLocation(
      position: LatLng(city.lat, city.lng),
      fromDevice: false,
      label: city.label,
    );
  }

  /// Requests the device position; keeps the default when unavailable.
  Future<LocationOutcome> locate() async {
    final r = await ref.read(locationServiceProvider).current();
    if (r.position != null && ref.mounted) {
      state = UserLocation(
        position: r.position!,
        fromDevice: true,
        label: AppLocale.l10n.yourLocation,
      );
    }
    return r.outcome;
  }

  void setManual(LatLng position, String label) =>
      state = UserLocation(position: position, fromDevice: false, label: label);
}

final userLocationProvider =
    NotifierProvider<UserLocationNotifier, UserLocation>(
      UserLocationNotifier.new,
    );
