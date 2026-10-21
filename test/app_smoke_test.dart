import 'package:eventra/app/nav_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers/harness.dart';

void main() {
  testWidgets('app launches into the themed shell with the nav pill', (
    tester,
  ) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(TestApp().build());
    await tester.pumpAndSettle();
    expect(find.byType(NavPill), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('nav-Explore')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('explore-map')), findsOneWidget);
    expect(find.text('Nearest Location'), findsOneWidget);
  });
}
