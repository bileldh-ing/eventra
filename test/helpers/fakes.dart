import 'dart:async';

import 'package:collection/collection.dart';
import 'package:eventra/core/location/location_service.dart';
import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/repositories/events_repository.dart';
import 'package:eventra/features/organizer/presentation/widgets/code_scanner.dart';
import 'package:eventra/features/tickets/domain/device_services.dart';
import 'package:eventra/features/tickets/domain/reminders.dart';
import 'package:flutter/widgets.dart';
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

class FakeReminderScheduler implements ReminderScheduler {
  final scheduled = <String, List<DateTime>>{};
  final cancelled = <String>[];

  @override
  Future<List<DateTime>> schedule(
    ReminderRequest request, {
    DateTime? now,
  }) async {
    final times = reminderTimes(request.start, now ?? DateTime.now());
    scheduled[request.orderId] = times;
    return times;
  }

  @override
  Future<void> cancel(String orderId) async {
    cancelled.add(orderId);
    scheduled.remove(orderId);
  }
}

class FakeBrightness implements BrightnessController {
  int boosts = 0;
  int restores = 0;
  bool get boosted => boosts > restores;

  @override
  Future<void> boost() async => boosts++;

  @override
  Future<void> restore() async => restores++;
}

class FakeCalendar implements CalendarService {
  final added = <CalendarEntry>[];

  @override
  Future<bool> add(CalendarEntry entry) async {
    added.add(entry);
    return true;
  }
}

class FakeShare implements ShareService {
  final shared = <String>[];

  @override
  Future<void> share({required String text, required String subject}) async =>
      shared.add(text);
}

/// Mutable clock for countdown tests.
class TestClock {
  TestClock(this.now);
  DateTime now;
  DateTime call() => now;
  void advance(Duration d) => now = now.add(d);
}

/// Deterministic ids: hold_0001, ord_0002, tkt_0003...
class SequentialIds {
  int _n = 0;
  String next(String prefix) =>
      '${prefix}_${(++_n).toString().padLeft(4, '0')}';
}

/// Camera-free scanner: tests call [emit] as if a QR code was in view.
class FakeCodeScanner implements CodeScannerBackend {
  ValueChanged<String>? _onCode;
  VoidCallback? _onUnavailable;

  void emit(String code) => _onCode?.call(code);
  void failCamera() => _onUnavailable?.call();

  @override
  Widget preview({
    required ValueChanged<String> onCode,
    required VoidCallback onUnavailable,
  }) {
    _onCode = onCode;
    _onUnavailable = onUnavailable;
    return const ColoredBox(
      key: ValueKey('fake-camera'),
      color: Color(0xFF000000),
    );
  }
}
