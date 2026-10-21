import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:latlong2/latlong.dart';

/// Read access to the event catalogue.
abstract interface class EventsRepository {
  Future<Result<List<Event>>> getEvents();
  Future<Result<Event>> getEvent(String id);
  Future<LatLng> defaultLocation();
}

/// Saved events, persisted per device.
abstract interface class FavoritesRepository {
  Stream<Set<String>> watchFavoriteIds();
  Future<Result<Set<String>>> getFavoriteIds();
  Future<Result<bool>> toggle(String eventId);
}
