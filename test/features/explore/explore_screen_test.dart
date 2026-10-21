import 'package:eventra/core/location/location_service.dart';
import 'package:eventra/features/explore/presentation/widgets/explore_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';

import '../../helpers/fakes.dart';
import '../../helpers/harness.dart';

void main() {
  const pitchfork = 'evt-002-pitchfork-music-night';
  const national = 'evt-003-national-music-festival';
  const harbor = 'evt-029-harbor-art-festival';

  Future<TestApp> pumpExplore(WidgetTester tester, {TestApp? app}) async {
    await setPhoneSize(tester);
    final a = app ?? TestApp();
    await tester.pumpWidget(a.build(initialLocation: '/explore'));
    await tester.pumpAndSettle();
    return a;
  }

  List<String> listedIds(WidgetTester tester) => tester
      .widgetList<NearestLocationCard>(find.byType(NearestLocationCard))
      .map((c) => c.item.event.id)
      .toList();

  bool isSelected(WidgetTester tester, String id) => tester
      .widget<NearestLocationCard>(find.byKey(ValueKey('nearest-$id')))
      .selected;

  testWidgets('renders the reference layout with the nearest selected', (
    tester,
  ) async {
    await pumpExplore(tester);
    expect(find.byKey(const ValueKey('explore-map')), findsOneWidget);
    expect(find.byKey(const ValueKey('explore-back')), findsOneWidget);
    expect(find.byKey(const ValueKey('locate-me')), findsOneWidget);
    expect(find.text('Search Your Location...'), findsOneWidget);
    expect(find.text('Nearest Location'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    // Preview card shows the nearest event, as in the reference.
    expect(find.byKey(const ValueKey('preview-$pitchfork')), findsOneWidget);
    expect(find.text('4523 Washington USA'), findsWidgets);
    expect(
      find.byKey(const ValueKey('selected-marker-$pitchfork')),
      findsOneWidget,
    );
    // The nav pill hides on the full-screen map.
    expect(find.byKey(const ValueKey('nav-Explore')), findsOneWidget);
    expect(
      tester.getTopLeft(find.byKey(const ValueKey('nav-Explore'))).dy,
      greaterThan(844),
    );
  });

  testWidgets('list is sorted by Haversine distance', (tester) async {
    await pumpExplore(tester);
    final ids = listedIds(tester);
    expect(ids.first, pitchfork);
    expect(ids.indexOf(national), lessThan(ids.indexOf(harbor)));
    expect(find.text('3.11KM'), findsOneWidget);
  });

  testWidgets('selecting a location highlights it and updates the preview', (
    tester,
  ) async {
    await pumpExplore(tester);
    expect(isSelected(tester, pitchfork), isTrue);
    await tester.tap(find.byKey(const ValueKey('nearest-$national')));
    await tester.pump(const Duration(milliseconds: 200));
    // Camera is mid fly-to.
    await tester.pumpAndSettle();
    expect(isSelected(tester, national), isTrue);
    expect(isSelected(tester, pitchfork), isFalse);
    expect(find.byKey(const ValueKey('preview-$national')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('selected-marker-$national')),
      findsOneWidget,
    );
  });

  testWidgets('search narrows the list and shows an empty state', (
    tester,
  ) async {
    await pumpExplore(tester);
    await tester.enterText(
      find.byKey(const ValueKey('explore-search')),
      'harbor',
    );
    await tester.pumpAndSettle();
    expect(listedIds(tester), contains(harbor));
    expect(listedIds(tester), isNot(contains(pitchfork)));

    await tester.enterText(
      find.byKey(const ValueKey('explore-search')),
      'zzzz-nowhere',
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('nearest-empty')), findsOneWidget);
  });

  testWidgets('locate me re-sorts distances from the device position', (
    tester,
  ) async {
    final app = TestApp(
      location: FakeLocationService(
        const LocationResult(
          LocationOutcome.granted,
          LatLng(41.0906, -73.9180),
        ),
      ),
    );
    await pumpExplore(tester, app: app);
    expect(listedIds(tester).first, pitchfork);
    await tester.tap(find.byKey(const ValueKey('locate-me')));
    await tester.pumpAndSettle();
    expect(app.location.calls, 1);
    expect(find.byKey(const ValueKey('user-dot')), findsOneWidget);
    final first = tester
        .widget<NearestLocationCard>(find.byType(NearestLocationCard).first)
        .item;
    expect(first.event.address, contains('Nyack'));
  });

  testWidgets('locate me denied keeps the default and explains', (
    tester,
  ) async {
    await pumpExplore(tester);
    await tester.tap(find.byKey(const ValueKey('locate-me')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('locate-denied')), findsOneWidget);
    expect(listedIds(tester).first, pitchfork);
  });

  testWidgets('sheet drags between snap points', (tester) async {
    await pumpExplore(tester);
    final handle = find.byKey(const ValueKey('sheet-handle'));
    final y0 = tester.getTopLeft(handle).dy;
    await tester.drag(handle, const Offset(0, -300));
    await tester.pumpAndSettle();
    final y1 = tester.getTopLeft(handle).dy;
    expect(y1, lessThan(y0 - 200));
    await tester.drag(handle, const Offset(0, 500));
    await tester.pumpAndSettle();
    final y2 = tester.getTopLeft(handle).dy;
    expect(y2, greaterThan(y0));
  });

  testWidgets('Continue opens the selected event; preview opens details', (
    tester,
  ) async {
    await pumpExplore(tester);
    await tester.tap(find.byKey(const ValueKey('explore-continue')));
    await tester.pumpAndSettle();
    expect(find.text('Events Details'), findsOneWidget);
    expect(find.text('Pitchfork Music Night'), findsWidgets);
    await tester.tap(find.byKey(const ValueKey('details-back')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('preview-card')));
    await tester.pumpAndSettle();
    expect(find.text('Events Details'), findsOneWidget);
  });

  testWidgets('back returns to Home', (tester) async {
    await pumpExplore(tester);
    await tester.tap(find.byKey(const ValueKey('explore-back')));
    await tester.pumpAndSettle();
    expect(find.text('Upcoming Events'), findsOneWidget);
  });

  testWidgets('mini-map opens the full map focused on the event', (
    tester,
  ) async {
    await setPhoneSize(tester);
    await tester.pumpWidget(
      TestApp().build(initialLocation: '/home/event/$national'),
    );
    await tester.pumpAndSettle();
    final mini = find.byKey(const ValueKey('mini-map'));
    await tester.scrollUntilVisible(
      mini,
      300,
      scrollable: find
          .descendant(
            of: find.byKey(const ValueKey('details-scroll')),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    // Bring it clear of the bottom bar before tapping.
    await Scrollable.ensureVisible(tester.element(mini), alignment: 0.5);
    await tester.pumpAndSettle();
    await tester.tap(mini);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('explore-map')), findsOneWidget);
    expect(find.byKey(const ValueKey('preview-$national')), findsOneWidget);
  });
}
