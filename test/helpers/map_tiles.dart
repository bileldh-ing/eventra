import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';

import 'harness.dart' show kTransparentPng;

final _tiles = <String, MemoryImage>{};

/// Bundled CARTO Positron tiles (test/fixtures/tiles/z/x/y.png) around the
/// demo location, so map goldens render real streets offline. Tiles outside
/// the fixture area are transparent.
MemoryImage fixtureTile(int z, int x, int y) => _tiles.putIfAbsent(
  '$z/$x/$y',
  () {
    final f = File('test/fixtures/tiles/$z/$x/$y.png');
    return MemoryImage(f.existsSync() ? f.readAsBytesSync() : kTransparentPng);
  },
);

class FixtureTileProvider extends TileProvider {
  FixtureTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) =>
      fixtureTile(coordinates.z, coordinates.x, coordinates.y);
}

/// Decodes every fixture tile into the image cache (needs real async), so a
/// golden captures the map fully drawn.
Future<void> precacheFixtureTiles(WidgetTester tester) async {
  final files = Directory('test/fixtures/tiles')
      .listSync(recursive: true)
      .whereType<File>()
      .where((f) => f.path.endsWith('.png'));
  final ctx = tester.binding.rootElement!;
  await tester.runAsync(() async {
    for (final f in files) {
      final parts = f.path.split('/');
      final z = int.parse(parts[parts.length - 3]);
      final x = int.parse(parts[parts.length - 2]);
      final y = int.parse(parts.last.split('.').first);
      await precacheImage(fixtureTile(z, x, y), ctx);
    }
  });
}
