import 'package:eventra/features/reviews/presentation/all_reviews_screen.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/harness.dart';
import '../../helpers/seed.dart';

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  // Centre it: the collapsing header covers the top of the page.
  await Scrollable.ensureVisible(tester.element(f), alignment: 0.5);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  const pastId = 'evt-p04-late-laughs-showcase';
  const upcomingId = 'evt-001-highland-music-festival';
  final past = loadSeed().events.firstWhere((e) => e.id == pastId);

  Future<ProviderContainer> pumpDetails(
    WidgetTester tester,
    String id, {
    bool withTicket = false,
  }) async {
    await setPhoneSize(tester);
    final app = TestApp();
    await tester.pumpWidget(app.build(initialLocation: '/home/event/$id'));
    await tester.pumpAndSettle();
    final c = ProviderScope.containerOf(
      tester.element(find.byType(MaterialApp)),
    );
    if (withTicket) {
      await tester.runAsync(
        () => c
            .read(ticketingRepositoryProvider)
            .ensureDemoPastOrder(
              userId: 'u_demo',
              attendeeName: 'Daniel Brooks',
              attendeeEmail: 'demo@eventra.app',
              event: past,
            ),
      );
      c.read(ticketingRevisionProvider.notifier).bump();
      await tester.pumpAndSettle();
    }
    return c;
  }

  testWidgets('details show average, count, histogram and latest reviews', (
    tester,
  ) async {
    await pumpDetails(tester, pastId);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('rating-summary')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('${past.reviews.length + 7} reviews'), findsOneWidget);
    expect(find.byKey(const ValueKey('histogram-5')), findsOneWidget);
    expect(find.byKey(const ValueKey('histogram-1')), findsOneWidget);
    // No ticket: explains who can review.
    expect(
      find.text('Only attendees with a ticket can review this event.'),
      findsOneWidget,
    );
  });

  testWidgets('upcoming event with no ticket cannot be reviewed', (
    tester,
  ) async {
    await pumpDetails(tester, upcomingId);
    expect(find.byKey(const ValueKey('write-review')), findsNothing);
  });

  testWidgets('a past attendee writes, edits and deletes a review', (
    tester,
  ) async {
    await pumpDetails(tester, pastId, withTicket: true);
    await tapKey(tester, 'write-review');

    // Validation: needs stars and 10+ characters.
    await tapKey(tester, 'review-submit');
    expect(find.byKey(const ValueKey('review-error')), findsOneWidget);
    await tapKey(tester, 'star-5');
    await tester.enterText(find.byKey(const ValueKey('review-text')), 'Short');
    await tapKey(tester, 'review-submit');
    expect(find.text('Write at least 10 characters.'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('review-text')),
      'Laughed the whole night, great host.',
    );
    await tapKey(tester, 'review-submit');
    expect(find.text('Thanks for your review!'), findsOneWidget);
    expect(find.text('Laughed the whole night, great host.'), findsOneWidget);
    expect(find.byKey(const ValueKey('edit-review')), findsOneWidget);
    expect(find.text('${past.reviews.length + 8} reviews'), findsOneWidget);

    await tapKey(tester, 'edit-review');
    await tapKey(tester, 'star-3');
    await tester.enterText(
      find.byKey(const ValueKey('review-text')),
      'Funny, but it ran long.',
    );
    await tapKey(tester, 'review-submit');
    expect(find.text('Funny, but it ran long.'), findsOneWidget);

    await tapKey(tester, 'my-review-menu');
    await tester.tap(find.byKey(const ValueKey('my-review-delete')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('delete-review-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('Funny, but it ran long.'), findsNothing);
    expect(find.byKey(const ValueKey('write-review')), findsOneWidget);
  });

  testWidgets('See all opens the reviews screen with star filters', (
    tester,
  ) async {
    await pumpDetails(tester, pastId);
    await tapKey(tester, 'reviews-see-all');
    expect(find.byType(AllReviewsScreen), findsOneWidget);
    await tapKey(tester, 'reviews-filter-2');
    // The seed pool has exactly one 2-star review per past event.
    expect(
      find.text('Too crowded near the stage and hard to see much.'),
      findsOneWidget,
    );
    await tapKey(tester, 'reviews-sort');
    await tester.tap(find.byKey(const ValueKey('reviews-sort-highest')));
    await tester.pumpAndSettle();
    expect(find.byType(AllReviewsScreen), findsOneWidget);
  });
}
