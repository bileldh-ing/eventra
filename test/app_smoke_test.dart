import 'package:eventra/app/app.dart';
import 'package:eventra/app/nav_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app launches into the themed shell with the nav pill', (
    tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: EventraApp()));
    await tester.pumpAndSettle();
    expect(find.byType(NavPill), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('nav-Explore')));
    await tester.pumpAndSettle();
    expect(find.text('Explore'), findsWidgets);
  });
}
