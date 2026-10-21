import 'dart:async';

import 'package:collection/collection.dart';
import 'package:eventra/core/location/location_service.dart';
import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/repositories/events_repository.dart';
import 'package:latlong2/latlong.dart';

class FakeEventsRepository implements EventsRepository {
  FakeEventsRepository(this.events, {this.delay = Duration.zero});

  List<Event> events;
  Duration delay;
  bool fail = false;
  int calls = 0;

  @override
  Future<Result<List<Event>>> getEvents() async {
    calls++;
    if (delay > Duration.zero) await Future<void>.delayed(delay);
    if (fail) return const Result.failure(NetworkFailure());
    return Result.success(events);
  }

  @override
  Future<Result<Event>> getEvent(String id) async {
    final e = events.firstWhereOrNull((e) => e.id == id);
    return e == null
        ? const Result.failure(NotFoundFailure())
        : Result.success(e);
  }

  @override
  Future<LatLng> defaultLocation() async => kDefaultLocation;
}

class FakeFavoritesRepository implements FavoritesRepository {
  final ids = <String>{};
  final _controller = StreamController<Set<String>>.broadcast();
  bool fail = false;

  @override
  Future<Result<Set<String>>> getFavoriteIds() async =>
      Result.success({...ids});

  @override
  Future<Result<bool>> toggle(String eventId) async {
    if (fail) return const Result.failure(StorageFailure());
    final saved = !ids.remove(eventId);
    if (saved) ids.add(eventId);
    _controller.add({...ids});
    return Result.success(saved);
  }

  @override
  Stream<Set<String>> watchFavoriteIds() => _controller.stream;
}

class FakeLocationService implements LocationService {
  FakeLocationService(this.result);
  LocationResult result;
  int calls = 0;

  @override
  Future<LocationResult> current() async {
    calls++;
    return result;
  }
}
