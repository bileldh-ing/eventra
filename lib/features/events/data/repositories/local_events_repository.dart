import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/events/data/backend/local_demo_backend.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/repositories/events_repository.dart';
import 'package:latlong2/latlong.dart';

AppFailure mapBackendError(Object e) => switch (e) {
  BackendException(kind: BackendErrorKind.network) => const NetworkFailure(),
  BackendException(kind: BackendErrorKind.notFound) => const NotFoundFailure(),
  BackendException(kind: BackendErrorKind.storage) => const StorageFailure(),
  _ => const UnknownFailure(),
};

class LocalEventsRepository implements EventsRepository {
  const LocalEventsRepository(this._backend);
  final LocalDemoBackend _backend;

  @override
  Future<Result<List<Event>>> getEvents() async {
    try {
      return Result.success(await _backend.fetchEvents());
    } on Object catch (e) {
      return Result.failure(mapBackendError(e));
    }
  }

  @override
  Future<Result<Event>> getEvent(String id) async {
    try {
      return Result.success(await _backend.fetchEvent(id));
    } on Object catch (e) {
      return Result.failure(mapBackendError(e));
    }
  }

  @override
  Future<LatLng> defaultLocation() => _backend.defaultLocation();
}

class LocalFavoritesRepository implements FavoritesRepository {
  const LocalFavoritesRepository(this._backend);
  final LocalDemoBackend _backend;

  @override
  Stream<Set<String>> watchFavoriteIds() => _backend.watchFavorites();

  @override
  Future<Result<Set<String>>> getFavoriteIds() async {
    try {
      return Result.success(await _backend.favoriteIds());
    } on Object catch (e) {
      return Result.failure(mapBackendError(e));
    }
  }

  @override
  Future<Result<bool>> toggle(String eventId) async {
    try {
      return Result.success(await _backend.toggleFavorite(eventId));
    } on Object catch (e) {
      return Result.failure(mapBackendError(e));
    }
  }
}
