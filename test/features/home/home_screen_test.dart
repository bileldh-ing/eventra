import 'package:eventra/core/widgets/skeleton.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/events/presentation/widgets/participants_sheet.dart';
import 'package:eventra/features/home/presentation/widgets/upcoming_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/harness.dart';
import '../../helpers/seed.dart';

void main() {
  // Home lists upcoming events only (the seed also has past events).
  final seed = loadSeed().events
      .where((e) => e.endAt.isAfter(kTestNow))
      .toList();
  String idOf(String title) => seed.firstWhere((e) => e.title == title).id;

  Future<TestApp> pumpHome(WidgetTester tester, {TestApp? app}) async {
    await setPhoneSize(tester);
    final a = app ?? TestApp();
    await tester.pumpWidget(a.build());
    await tester.pumpAndSettle();
    return a;
  }

  testWidgets('renders the reference layout above the fold', (tester) async {
    await pumpHome(tester);
    expect(find.text('Discover Amazing\nEvents Near You'), findsOneWidget);
    expect(find.text('Search'), findsOneWidget);
    expect(find.byKey(const ValueKey('home-bell')), findsOneWidget);
    expect(find.byKey(const ValueKey('notification-dot')), findsOneWidget);
    expect(find.byKey(const ValueKey('chip-See All')), findsOneWidget);
    expect(find.text('Upcoming Events'), findsOneWidget);
    expect(find.text('See All'), findsNWidgets(2));
    // Featured reference card first, with its location chip, date and +12.
    expect(find.text('Highland Music Festival'), findsOneWidget);
    expect(find.text('4517 Manchester'), findsOneWidget);
    expect(find.text('Jun 20 - 11:00 PM'), findsOneWidget);
    expect(find.text('+12'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
  });

  testWidgets('category chips filter the carousel for real', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const ValueKey('chip-Sports')));
    await tester.pumpAndSettle();

    final carousel = tester.widget<UpcomingCarousel>(
      find.byType(UpcomingCarousel),
    );
    expect(carousel.events, isNotEmpty);
    expect(
      carousel.events.every((e) => e.category == EventCategory.sports),
      isTrue,
    );
    expect(find.text('Highland Music Festival'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('chip-See All')));
    await tester.pumpAndSettle();
    expect(find.text('Highland Music Festival'), findsOneWidget);
  });

  testWidgets('bookmark toggles and persists through the repository', (
    tester,
  ) async {
    final app = await pumpHome(tester);
    final id = idOf('Highland Music Festival');
    await tester.tap(find.byKey(ValueKey('bookmark-$id')).first);
    await tester.pumpAndSettle();
    expect(app.favorites.ids, contains(id));
    expect(find.byIcon(Icons.bookmark_rounded), findsWidgets);

    await tester.tap(find.byKey(ValueKey('bookmark-$id')).first);
    await tester.pumpAndSettle();
    expect(app.favorites.ids, isNot(contains(id)));
  });

  testWidgets('swiping the carousel snaps to the next card', (tester) async {
    await pumpHome(tester);
    final carousel = tester.widget<UpcomingCarousel>(
      find.byType(UpcomingCarousel),
    );
    final second = carousel.events[1];
    await tester.fling(
      find.byKey(const ValueKey('upcoming-carousel')),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    final page = tester
        .widget<PageView>(find.byKey(const ValueKey('upcoming-carousel')))
        .controller!
        .page;
    expect(page, 1);
    expect(find.text(second.title), findsWidgets);
  });

  testWidgets('arrow button opens Event Details for that card', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.bySemanticsLabel('Open event').first);
    await tester.pumpAndSettle();
    expect(find.text('Get a Ticket'), findsOneWidget);
    expect(find.text('Highland Music Festival'), findsWidgets);
  });

  testWidgets('avatar stack opens the participants sheet', (tester) async {
    await pumpHome(tester);
    await tester.tap(
      find.byKey(ValueKey('avatars-${idOf('Highland Music Festival')}')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(ParticipantsSheet), findsOneWidget);
    expect(find.text('Invite friends'), findsOneWidget);
  });

  testWidgets('shows a skeleton shimmer while loading', (tester) async {
    await setPhoneSize(tester);
    final app = TestApp()..events.delay = const Duration(seconds: 2);
    await tester.pumpWidget(app.build());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(Shimmer), findsOneWidget);
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.byType(Shimmer), findsNothing);
    expect(find.byType(UpcomingCarousel), findsOneWidget);
  });

  testWidgets('error state retries and recovers', (tester) async {
    await setPhoneSize(tester);
    final app = TestApp();
    app.events.fail = true;
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('error-view')), findsOneWidget);

    app.events.fail = false;
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('error-view')), findsNothing);
    expect(find.text('Highland Music Festival'), findsOneWidget);
  });

  testWidgets('empty state resets the filter', (tester) async {
    await setPhoneSize(tester);
    final app = TestApp();
    app.events.events = seed
        .where((e) => e.category == EventCategory.music)
        .toList();
    await tester.pumpWidget(app.build());
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('chip-Cinema')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('empty-view')), findsOneWidget);
    await tester.tap(find.text('Show all events'));
    await tester.pumpAndSettle();
    expect(find.text('Highland Music Festival'), findsOneWidget);
  });

  testWidgets('pull to refresh reloads the feed', (tester) async {
    final app = await pumpHome(tester);
    final before = app.events.calls;
    await tester.fling(
      find.text('Discover Amazing\nEvents Near You'),
      const Offset(0, 400),
      1200,
    );
    await tester.pumpAndSettle();
    expect(app.events.calls, greaterThan(before));
  });

  testWidgets('filters sheet applies Free only with a live count', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const ValueKey('home-filter')));
    await tester.pumpAndSettle();
    final freeCount = seed.where((e) => e.isFree).length;
    expect(find.text('Show ${seed.length} results'), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('filter-free')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('filter-free')));
    await tester.pumpAndSettle();
    expect(find.text('Show $freeCount results'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('filters-apply')));
    await tester.pumpAndSettle();
    final carousel = tester.widget<UpcomingCarousel>(
      find.byType(UpcomingCarousel),
    );
    expect(carousel.events.length, freeCount);
    expect(carousel.events.every((e) => e.isFree), isTrue);
  });

  testWidgets('search pill opens live search', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const ValueKey('home-search')));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('search-input')),
      'pitchfork',
    );
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    expect(find.text('Pitchfork Music Night'), findsOneWidget);
  });

  testWidgets('See All lists every upcoming event with sorting', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const ValueKey('action-Upcoming Events')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('sort-priceLow')), findsOneWidget);
    await tester.ensureVisible(find.byKey(const ValueKey('sort-priceLow')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('sort-priceLow')));
    await tester.pumpAndSettle();
    expect(find.text('Free'), findsWidgets);
  });

  testWidgets('bell opens notifications; mark all read clears the dot', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const ValueKey('home-bell')));
    await tester.pumpAndSettle();
    expect(find.text('Notifications'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('mark-all-read')));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('notification-dot')), findsNothing);
  });

  testWidgets('nav pill switches tabs; favorites shows saved events', (
    tester,
  ) async {
    final app = await pumpHome(tester);
    await tester.tap(find.byKey(const ValueKey('nav-Favorites')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('favorites-empty')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-Home')));
    await tester.pumpAndSettle();
    final id = idOf('Highland Music Festival');
    await tester.tap(find.byKey(ValueKey('bookmark-$id')).first);
    await tester.pumpAndSettle();
    expect(app.favorites.ids, {id});

    await tester.tap(find.byKey(const ValueKey('nav-Favorites')));
    await tester.pumpAndSettle();
    expect(find.text('Highland Music Festival'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('nav-Profile')));
    await tester.pumpAndSettle();
    expect(find.text('My Tickets'), findsOneWidget);
  });

  testWidgets('avatar opens the profile tab', (tester) async {
    await pumpHome(tester);
    await tester.tap(find.byKey(const ValueKey('home-avatar')));
    await tester.pumpAndSettle();
    expect(find.text('Invite Friends'), findsOneWidget);
  });

  testWidgets('long-press opens the quick preview with reasons and Save', (
    tester,
  ) async {
    final app = await pumpHome(tester);
    final id = idOf('Highland Music Festival');
    await tester.longPress(find.byKey(ValueKey('card-$id')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('quick-preview')), findsOneWidget);
    expect(find.text('Because you like Music'), findsOneWidget);
    expect(find.byKey(const ValueKey('preview-price')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('preview-save')));
    await tester.pumpAndSettle();
    expect(app.favorites.ids, contains(id));

    await tester.tap(find.byKey(const ValueKey('preview-open')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('quick-preview')), findsNothing);
    expect(find.text('Get a Ticket'), findsOneWidget);
  });

  testWidgets('interest rows follow the user interests', (tester) async {
    await pumpHome(tester);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('section-interest-music')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Because You Like Music'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byKey(const ValueKey('section-interest-tech')),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Because You Like Tech'), findsOneWidget);
  });
}
