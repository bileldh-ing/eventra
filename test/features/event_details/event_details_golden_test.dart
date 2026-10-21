@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/golden.dart';
import '../../helpers/harness.dart';
import '../../helpers/map_tiles.dart';

void main() {
  testWidgets('Event Details matches the golden', (tester) async {
    await setPhoneSize(tester, dpr: 2);
    await withRealShadows(() async {
      await tester.pumpWidget(
        TestApp().build(
          initialLocation: '/home/event/evt-002-pitchfork-music-night',
        ),
      );
      await precacheFixtureTiles(tester);
      await tester.pumpAndSettle();
      await precacheVisibleImages(tester);
      await tester.pumpAndSettle();
      await expectGolden(find.byType(MaterialApp), 'goldens/details.png');
    });
  });
}
