import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/features/events/presentation/widgets/event_cards.dart';
import 'package:eventra/features/search/domain/search_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/harness.dart';
import '../../helpers/seed.dart';

void main() {
  final seed = loadSeed().events;
  const recentKey = 'search.recent.u_demo';

  MemoryPrefsStore prefs({List<String> recent = const []}) => MemoryPrefsStore({
    'onboarding.seen': true,
    'interests.u_demo': ['music', 'tech', 'food'],
    if (recent.isNotEmpty) recentKey: recent,
  });

  Future<TestApp> pumpSearch(WidgetTester tester, {TestApp? app}) async {
    await setPhoneSize(tester);
    final a = app ?? TestApp(prefs: prefs());
    await tester.pumpWidget(a.build(initialLocation: '/home/search'));
    await tester.pumpAndSettle();
    return a;
  }

  Future<void> type(WidgetTester tester, String text) async {
    await tester.enterText(find.byKey(const ValueKey('search-input')), text);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
  }

  testWidgets('idle state shows trending chips and no recents', (
    tester,
  ) async {
    await pumpSearch(tester);
    expect(find.text('Trending searches'), findsOneWidget);
    expect(find.byKey(const ValueKey('suggest-Music')), findsOneWidget);
    expect(find.text('Recent searches'), findsNothing);
  });

  testWidgets('debounced live results highlight the match and save recents', (
    tester,
  ) async {
    final app = await pumpSearch(tester);
    await tester.enterText(find.byKey(const ValueKey('search-input')), 'pitch');
    await tester.pump(const Duration(milliseconds: 100));
    // Still debouncing: idle content stays.
    expect(find.byKey(const ValueKey('search-results')), findsNothing);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('search-results')), findsOneWidget);
    expect(find.text('Pitchfork Music Night'), findsOneWidget);
    final n = searchEvents(seed, 'pitch').length;
    expect(find.text(n == 1 ? '1 result' : '$n results'), findsOneWidget);

    // The matched text is emphasised in its own span.
    final title = tester.widget<Text>(find.text('Pitchfork Music Night'));
    final spans = (title.textSpan! as TextSpan).children!.cast<TextSpan>();
    expect(spans.first.text, 'Pitch');
    expect(spans.first.style?.fontWeight, FontWeight.w800);

    await tester.tap(find.text('Pitchfork Music Night'));
    await tester.pumpAndSettle();
    expect(find.text('Get a Ticket'), findsOneWidget);
    expect(app.prefs.getStringList(recentKey), ['pitch']);
  });

  testWidgets('recent searches: tap, swipe delete with undo, clear all', (
    tester,
  ) async {
    final app = await pumpSearch(
      tester,
      app: TestApp(prefs: prefs(recent: ['jazz', 'harbor', 'tech'])),
    );
    expect(find.text('Recent searches'), findsOneWidget);
    expect(find.text('harbor'), findsOneWidget);

    await tester.drag(
      find.byKey(const ValueKey('recent-harbor')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('recent-harbor')), findsNothing);
    expect(app.prefs.getStringList(recentKey), ['jazz', 'tech']);
    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(app.prefs.getStringList(recentKey), ['jazz', 'harbor', 'tech']);
    expect(find.byKey(const ValueKey('recent-harbor')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('recent-clear-all')));
    await tester.pumpAndSettle();
    expect(find.text('Recent searches'), findsNothing);
    expect(app.prefs.getStringList(recentKey), isNull);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(app.prefs.getStringList(recentKey), ['jazz', 'harbor', 'tech']);

    // Tapping a recent searches it right away and moves it to the top.
    await tester.tap(find.text('harbor'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('search-results')), findsOneWidget);
    expect(find.text('Harbor Art Festival'), findsOneWidget);
    expect(app.prefs.getStringList(recentKey)!.first, 'harbor');
  });

  testWidgets('no results shows suggestions that search on tap', (
    tester,
  ) async {
    await pumpSearch(tester);
    await type(tester, 'zzqx');
    expect(find.byKey(const ValueKey('search-empty')), findsOneWidget);
    expect(find.text('No results for "zzqx"'), findsOneWidget);
    final chip = find.byWidgetPredicate(
      (w) =>
          w is ActionChip &&
          w.key is ValueKey<String> &&
          (w.key! as ValueKey<String>).value.startsWith('empty-suggest-'),
    );
    expect(chip, findsWidgets);
    await tester.tap(chip.first);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('search-results')), findsOneWidget);
    expect(find.byType(EventListTile), findsWidgets);
  });

  testWidgets('filters narrow the results and can be cleared', (tester) async {
    await pumpSearch(tester);
    await type(tester, 'festival');
    final all = tester.widgetList(find.byType(EventListTile)).length;
    expect(all, greaterThan(0));

    await tester.tap(find.byKey(const ValueKey('search-filter')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const ValueKey('filter-free')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('filter-free')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('filters-apply')));
    await tester.pumpAndSettle();

    final freeMatches = seed
        .where((e) => e.isFree && e.title.toLowerCase().contains('festival'))
        .length;
    if (freeMatches == 0) {
      expect(find.byKey(const ValueKey('search-empty')), findsOneWidget);
      expect(find.text('Clear filters'), findsOneWidget);
      await tester.tap(find.text('Clear filters'));
    } else {
      final tiles = tester.widgetList<EventListTile>(
        find.byType(EventListTile),
      );
      expect(tiles.every((t) => t.event.isFree), isTrue);
      await tester.tap(find.byKey(const ValueKey('search-clear-filters')));
    }
    await tester.pumpAndSettle();
    expect(tester.widgetList(find.byType(EventListTile)).length, all);
  });
}
