import 'dart:convert';
import 'dart:math';

import 'package:eventra/features/events/data/backend/seed_source.dart';
import 'package:eventra/features/events/data/db/app_database.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/domain/entities/seed_bundle.dart';
import 'package:latlong2/latlong.dart';

/// Error thrown by the demo backend when a fault is injected.
class BackendException implements Exception {
  const BackendException(this.kind, [this.message = '']);
  final BackendErrorKind kind;
  final String message;

  @override
  String toString() => 'BackendException($kind, $message)';
}

enum BackendErrorKind { network, notFound, storage }

/// Switchable fault injection for demos and tests.
class FaultConfig {
  const FaultConfig({this.failureRate = 0, this.offline = false, this.seed});

  static const none = FaultConfig();

  /// Probability (0..1) that a call fails with a network error.
  final double failureRate;

  /// When true every call fails with a network error.
  final bool offline;

  /// Seed for deterministic failures in tests.
  final int? seed;
}

/// Zero-setup backend: seeded JSON persisted in drift, simulated latency and
/// switchable error injection. The UI never talks to it directly; it is
/// wrapped by repositories.
class LocalDemoBackend {
  LocalDemoBackend({
    required this.db,
    required this.seedSource,
    this.latency = const Duration(milliseconds: 450),
    FaultConfig faults = FaultConfig.none,
    DateTime Function()? clock,
  }) : _faults = faults,
       _random = Random(faults.seed),
       _clock = clock ?? DateTime.now;

  final AppDatabase db;
  final SeedSource seedSource;
  final Duration latency;
  final DateTime Function() _clock;
  FaultConfig _faults;
  Random _random;
  SeedBundle? _seed;

  FaultConfig get faults => _faults;

  set faults(FaultConfig value) {
    _faults = value;
    _random = Random(value.seed);
  }

  static const _seedVersionKey = 'seed_generated_at';

  Future<SeedBundle> _bundle() async => _seed ??= SeedBundle.fromJson(
    jsonDecode(await seedSource.load()) as Map<String, dynamic>,
  );

  /// Default location shipped with the seed (used before GPS is granted).
  Future<LatLng> defaultLocation() async => (await _bundle()).defaultLocation;

  /// Imports the seed into drift on first run or when the seed changes.
  Future<void> ensureSeeded() async {
    final bundle = await _bundle();
    final version = bundle.generatedAt.toIso8601String();
    final stored = await db.readMeta(_seedVersionKey);
    if (stored == version && await db.eventCount() == bundle.events.length) {
      return;
    }
    await db.replaceEvents([
      for (final e in bundle.events)
        EventRowsCompanion.insert(
          id: e.id,
          category: e.category.name,
          startAt: e.startAt,
          latitude: e.latitude,
          longitude: e.longitude,
          payload: jsonEncode(e.toJson()),
        ),
    ]);
    await db.writeMeta(_seedVersionKey, version);
  }

  Future<void> _simulate() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    if (_faults.offline ||
        (_faults.failureRate > 0 &&
            _random.nextDouble() < _faults.failureRate)) {
      throw const BackendException(
        BackendErrorKind.network,
        'Injected network failure',
      );
    }
  }

  Future<List<Event>> fetchEvents() async {
    await _simulate();
    await ensureSeeded();
    final rows = await db.allEvents();
    return [for (final r in rows) _decode(r)];
  }

  Future<Event> fetchEvent(String id) async {
    await _simulate();
    await ensureSeeded();
    final row = await db.eventById(id);
    if (row == null) {
      throw BackendException(BackendErrorKind.notFound, id);
    }
    return _decode(row);
  }

  Stream<Set<String>> watchFavorites() => db.watchFavoriteIds();

  Future<Set<String>> favoriteIds() => db.favoriteIds();

  /// Favorites are local-first: no injected latency so the bookmark feels
  /// instant, but storage errors still surface.
  Future<bool> toggleFavorite(String eventId) async {
    try {
      return await db.toggleFavorite(eventId, _clock());
    } on Exception catch (e) {
      throw BackendException(BackendErrorKind.storage, '$e');
    }
  }

  Event _decode(EventRow r) =>
      Event.fromJson(jsonDecode(r.payload) as Map<String, dynamic>);
}
