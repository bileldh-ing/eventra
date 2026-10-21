import 'dart:io';
import 'dart:typed_data';

import 'package:eventra/app/app.dart';
import 'package:eventra/app/router.dart';
import 'package:eventra/core/location/location_service.dart';
import 'package:eventra/core/map/map_layers.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';

import 'fakes.dart';
import 'map_tiles.dart';
import 'seed.dart';

/// Fixed "now" for every widget test: the seed generation day.
final kTestNow = DateTime(2026, 10, 21, 10);

/// Transparent 1x1 PNG.
final Uint8List kTransparentPng = Uint8List.fromList(const [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, //
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
]);

final _memo = <String, MemoryImage>{};

/// Serves seed photos and avatars from test/fixtures so goldens show real
/// images without network access. Unknown URLs get a transparent pixel.
ImageProvider<Object> fixtureImage(String url) {
  return _memo.putIfAbsent(url, () {
    String? path;
    final photo = RegExp('photo-([0-9a-f-]+)').firstMatch(url);
    if (photo != null) {
      path = 'test/fixtures/images/${photo.group(1)}.jpg';
    } else {
      final av = RegExp('portraits/(men|women)/([0-9]+)').firstMatch(url);
      if (av != null) {
        final files =
            Directory('test/fixtures/avatars')
                .listSync()
                .whereType<File>()
                .where((f) => f.path.contains('/${av.group(1)}-'))
                .toList()
              ..sort((a, b) => a.path.compareTo(b.path));
        final exact = File(
          'test/fixtures/avatars/${av.group(1)}-${av.group(2)}.jpg',
        );
        path = exact.existsSync()
            ? exact.path
            : files[int.parse(av.group(2)!) % files.length].path;
      }
    }
    final file = path == null ? null : File(path);
    return MemoryImage(
      file != null && file.existsSync()
          ? file.readAsBytesSync()
          : kTransparentPng,
    );
  });
}

class TestApp {
  TestApp({
    FakeEventsRepository? events,
    FakeFavoritesRepository? favorites,
    FakeLocationService? location,
  }) : events = events ?? FakeEventsRepository(loadSeed().events),
       favorites = favorites ?? FakeFavoritesRepository(),
       location =
           location ??
           FakeLocationService(
             const LocationResult(LocationOutcome.denied),
           );

  final FakeEventsRepository events;
  final FakeFavoritesRepository favorites;
  final FakeLocationService location;

  List<Override> get overrides => [
    eventsRepositoryProvider.overrideWithValue(events),
    favoritesRepositoryProvider.overrideWithValue(favorites),
    clockProvider.overrideWithValue(() => kTestNow),
    imageProviderFactory.overrideWithValue(fixtureImage),
    locationServiceProvider.overrideWithValue(location),
    mapTileProviderProvider.overrideWithValue(FixtureTileProvider()),
    loopingAnimationsProvider.overrideWithValue(false),
  ];

  Widget build({String initialLocation = '/home'}) => ProviderScope(
    retry: (_, _) => null,
    overrides: overrides,
    child: EventraApp(router: buildRouter(initialLocation: initialLocation)),
  );
}

/// Phone-sized surface (390x844 logical, 3x).
Future<void> setPhoneSize(WidgetTester tester, {double dpr = 3}) async {
  tester.view
    ..physicalSize = Size(390 * dpr, 844 * dpr)
    ..devicePixelRatio = dpr;
  addTearDown(tester.view.reset);
}

/// Decodes every image currently in the tree (needs real async), so goldens
/// render photos instead of fallbacks.
Future<void> precacheVisibleImages(WidgetTester tester) async {
  for (var pass = 0; pass < 3; pass++) {
    final providers = tester
        .widgetList<widgets.Image>(find.byType(widgets.Image))
        .map((i) => i.image)
        .toSet();
    final ctx = tester.element(find.byType(EventraApp));
    await tester.runAsync(() async {
      for (final p in providers) {
        await precacheImage(p, ctx);
      }
    });
    await tester.pump();
  }
}
