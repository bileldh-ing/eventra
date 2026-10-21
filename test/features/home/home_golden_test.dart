@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/golden.dart';
import '../../helpers/harness.dart';

void main() {
  testWidgets('Home matches the golden', (tester) async {
    await setPhoneSize(tester, dpr: 2);
    await withRealShadows(() async {
      await tester.pumpWidget(TestApp().build());
      await tester.pumpAndSettle();
      await precacheVisibleImages(tester);
      await tester.pumpAndSettle();
      await expectGolden(find.byType(MaterialApp), 'goldens/home.png');
    });
  });
}
