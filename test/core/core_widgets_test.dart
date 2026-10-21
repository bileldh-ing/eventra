import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/widgets/faceted_painter.dart';
import 'package:eventra/core/widgets/glass.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
  theme: buildEventraTheme(),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('GradientPillButton fires and disables', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(GradientPillButton(label: 'Continue', onPressed: () => taps++)),
    );
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
    expect(taps, 1);

    await tester.pumpWidget(
      _wrap(const GradientPillButton(label: 'Sold Out', onPressed: null)),
    );
    await tester.tap(find.text('Sold Out'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });

  testWidgets('GlassCircleButton shows badge and handles taps', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _wrap(
        GlassCircleButton(
          icon: Icons.notifications_none,
          semanticLabel: 'Notifications',
          badge: true,
          onPressed: () => taps++,
        ),
      ),
    );
    expect(find.byKey(const ValueKey('notification-dot')), findsOneWidget);
    await tester.tap(find.byType(GlassCircleButton));
    expect(taps, 1);
  });

  test('FacetedPainter repaints only when inputs change', () {
    final a = FacetedPainter(shift: 2);
    expect(a.shouldRepaint(FacetedPainter(shift: 2)), isFalse);
    expect(a.shouldRepaint(FacetedPainter(shift: 3)), isTrue);
  });
}
