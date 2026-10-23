import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/harness.dart';

/// Key screens at 1.3x text size must lay out without overflow, and the
/// main screens meet the tap-target and labelled-target guidelines.
void main() {
  const highland = 'evt-001-highland-music-festival';

  Future<void> pump(
    WidgetTester tester,
    String location, {
    double scale = 1,
  }) async {
    await setPhoneSize(tester);
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(TestApp().build(initialLocation: location));
    await tester.pumpAndSettle();
  }

  for (final location in [
    '/home',
    '/home/event/$highland',
    '/explore',
    '/favorites',
    '/tickets',
    '/profile',
  ]) {
    testWidgets('$location lays out at 1.3x text without overflow', (
      tester,
    ) async {
      await pump(tester, location, scale: 1.3);
      expect(tester.takeException(), isNull);
      expect(
        MediaQuery.textScalerOf(
          tester.element(find.byType(Scaffold).first),
        ).scale(10),
        closeTo(13, 0.01),
      );
    });
  }

  for (final location in ['/home', '/home/event/$highland', '/explore']) {
    testWidgets('$location meets tap target and label guidelines', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      await pump(tester, location);
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });
  }
}
