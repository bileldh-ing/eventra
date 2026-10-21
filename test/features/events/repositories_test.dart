import 'package:eventra/core/result/result.dart';
import 'package:eventra/features/events/data/backend/local_demo_backend.dart';
import 'package:eventra/features/events/data/repositories/local_events_repository.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/seed.dart';

void main() {
  late LocalDemoBackend backend;
  late LocalEventsRepository events;
  late LocalFavoritesRepository favorites;

  setUp(() {
    backend = testBackend();
    events = LocalEventsRepository(backend);
    favorites = LocalFavoritesRepository(backend);
  });

  tearDown(() => backend.db.close());

  test(
    'seeds drift on first fetch and returns events sorted by date',
    () async {
      final result = await events.getEvents();
      final list = result.valueOrNull!;
      expect(list.length, loadSeed().events.length);
      for (var i = 1; i < list.length; i++) {
        expect(list[i].startAt.isBefore(list[i - 1].startAt), isFalse);
      }
      expect(await backend.db.eventCount(), list.length);
    },
  );

  test('seeding is idempotent', () async {
    await backend.ensureSeeded();
    await backend.ensureSeeded();
    expect(await backend.db.eventCount(), loadSeed().events.length);
  });

  test('round-trips an event through drift without losing data', () async {
    final original = loadSeed().events.first;
    final fetched = (await events.getEvent(original.id)).valueOrNull;
    expect(fetched, original);
  });

  test('unknown id maps to NotFoundFailure', () async {
    final r = await events.getEvent('nope');
    expect(r, isA<Failure<Object>>());
    expect((r as Failure).failure, isA<NotFoundFailure>());
  });

  test('offline fault injection maps to NetworkFailure', () async {
    backend.faults = const FaultConfig(offline: true);
    final r = await events.getEvents();
    expect((r as Failure).failure, isA<NetworkFailure>());
    backend.faults = FaultConfig.none;
    expect((await events.getEvents()).isSuccess, isTrue);
  });

  test('failure rate is deterministic with a seed', () async {
    Future<List<bool>> run() async {
      backend.faults = const FaultConfig(failureRate: 0.5, seed: 42);
      return [
        for (var i = 0; i < 10; i++) (await events.getEvents()).isSuccess,
      ];
    }

    final a = await run();
    final b = await run();
    expect(a, b);
    expect(a, contains(true));
    expect(a, contains(false));
  });

  test('favorites toggle, persist and stream', () async {
    final id = loadSeed().events.first.id;
    final emitted = <Set<String>>[];
    final sub = favorites.watchFavoriteIds().listen(emitted.add);

    expect((await favorites.toggle(id)).valueOrNull, isTrue);
    expect((await favorites.getFavoriteIds()).valueOrNull, {id});
    expect((await favorites.toggle(id)).valueOrNull, isFalse);
    expect((await favorites.getFavoriteIds()).valueOrNull, <String>{});

    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(emitted.any((s) => s.contains(id)), isTrue);
    await sub.cancel();
  });

  test('favorites survive reopening the backend on the same db', () async {
    final id = loadSeed().events[3].id;
    await favorites.toggle(id);
    final again = LocalFavoritesRepository(testBackend(db: backend.db));
    expect((await again.getFavoriteIds()).valueOrNull, {id});
  });

  test('default location comes from the seed', () async {
    final loc = await events.defaultLocation();
    expect(loc.latitude, closeTo(41.147, 0.001));
  });

  test('event helpers: headline price, free and sold-out flags', () {
    final seed = loadSeed().events;
    final pitchfork = seed.firstWhere(
      (e) => e.title == 'Pitchfork Music Night',
    );
    expect(pitchfork.price, 50);
    expect(pitchfork.minPrice, lessThan(50));
    expect(pitchfork.isFree, isFalse);
    expect(
      seed.firstWhere((e) => e.title == 'Ceramics Open Studio').isSoldOut,
      isTrue,
    );
  });
}
