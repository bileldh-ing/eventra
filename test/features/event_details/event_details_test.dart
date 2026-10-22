import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/harness.dart';

void main() {
  const pitchfork = 'evt-002-pitchfork-music-night';
  const highland = 'evt-001-highland-music-festival';

  Future<TestApp> pumpDetails(WidgetTester tester, String id) async {
    await setPhoneSize(tester);
    final app = TestApp();
    await tester.pumpWidget(app.build(initialLocation: '/home/event/$id'));
    await tester.pumpAndSettle();
    return app;
  }

  testWidgets('renders the reference layout', (tester) async {
    await pumpDetails(tester, pitchfork);
    expect(find.text('Events Details'), findsOneWidget);
    expect(find.text('Pitchfork Music Night'), findsWidgets);
    expect(find.byKey(const ValueKey('details-price')), findsOneWidget);
    expect(find.text(r'$50'), findsOneWidget);
    expect(find.textContaining('Participants'), findsOneWidget);
    expect(find.text('About Event'), findsOneWidget);
    expect(find.text('Location'), findsOneWidget);
    expect(find.byKey(const ValueKey('get-ticket')), findsOneWidget);
  });

  testWidgets('See more expands the description and See less collapses', (
    tester,
  ) async {
    await pumpDetails(tester, pitchfork);
    expect(
      find.textContaining('See more....', findRichText: true),
      findsOneWidget,
    );
    final before = tester.getSize(find.byKey(const ValueKey('about-text')));
    await tester.tap(find.byKey(const ValueKey('about-text')));
    await tester.pumpAndSettle();
    expect(find.textContaining('See less', findRichText: true), findsOneWidget);
    final after = tester.getSize(find.byKey(const ValueKey('about-text')));
    expect(after.height, greaterThan(before.height));

    await tester.tap(find.byKey(const ValueKey('about-text')));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('See more....', findRichText: true),
      findsOneWidget,
    );
  });

  testWidgets('bookmark saves the event through the repository', (
    tester,
  ) async {
    final app = await pumpDetails(tester, pitchfork);
    await tester.tap(find.byKey(const ValueKey('bookmark-$pitchfork')));
    await tester.pumpAndSettle();
    expect(app.favorites.ids, contains(pitchfork));
    await tester.tap(find.byKey(const ValueKey('bookmark-$pitchfork')));
    await tester.pumpAndSettle();
    expect(app.favorites.ids, isNot(contains(pitchfork)));
  });

  testWidgets('Get a Ticket shows loading, a check, then opens tickets', (
    tester,
  ) async {
    await pumpDetails(tester, pitchfork);
    await tester.tap(find.byKey(const ValueKey('get-ticket')));
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byKey(const ValueKey('ticket-loading')), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byKey(const ValueKey('ticket-done')), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Get a Ticket'), findsWidgets);
    expect(find.byKey(const ValueKey('tier-list')), findsOneWidget);
  });

  testWidgets('organizer Follow toggles to Following', (tester) async {
    await pumpDetails(tester, pitchfork);
    final follow = find.byKey(const ValueKey('follow-button'));
    await tester.scrollUntilVisible(
      follow,
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('details-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    // Bring it clear of the bottom bar before tapping.
    await Scrollable.ensureVisible(tester.element(follow), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(follow);
    await tester.pumpAndSettle();
    expect(find.text('Following'), findsOneWidget);
  });

  testWidgets('home card opens details with a shared-element hero', (
    tester,
  ) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(TestApp().build());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('card-$highland')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    // Mid-flight: the hero is in the overlay.
    expect(find.byType(Hero), findsWidgets);
    await tester.pumpAndSettle();
    expect(find.text('Events Details'), findsOneWidget);
    final hero = tester.widget<Hero>(
      find.byWidgetPredicate(
        (w) => w is Hero && w.tag == 'carousel-$highland',
      ),
    );
    expect(hero.tag, 'carousel-$highland');

    await tester.tap(find.byKey(const ValueKey('details-back')));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming Events'), findsOneWidget);
  });
}
