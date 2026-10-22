import 'package:eventra/features/favorites/presentation/favorites_screen.dart';
import 'package:eventra/features/profile/domain/user_profile.dart';
import 'package:eventra/features/profile/presentation/edit_profile_screen.dart';
import 'package:eventra/features/profile/presentation/profile_providers.dart';
import 'package:eventra/features/profile/presentation/widgets/initials_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/fakes.dart';
import '../../helpers/harness.dart';
import '../../helpers/seed.dart';

Future<void> tapKey(WidgetTester tester, String key) async {
  final f = find.byKey(ValueKey(key));
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

void main() {
  final seed = loadSeed().events;
  String idOf(String title) => seed.firstWhere((e) => e.title == title).id;

  group('profile', () {
    test('initials and validators', () {
      expect(initialsOf('Daniel Brooks'), 'DB');
      expect(initialsOf('  cher '), 'C');
      expect(initialsOf('Ana Maria Lopez'), 'AM');
      expect(initialsOf(''), '?');
      expect(ProfileValidators.name('A'), isNotNull);
      expect(ProfileValidators.name('Al'), isNull);
      expect(ProfileValidators.bio('x' * 161), isNotNull);
      expect(ProfileValidators.city('Paris'), isNull);
    });

    testWidgets('edit profile updates name, color, city and bio everywhere', (
      tester,
    ) async {
      await setPhoneSize(tester);
      final app = TestApp();
      await tester.pumpWidget(app.build(initialLocation: '/profile'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('stat-Tickets')), findsOneWidget);
      expect(find.byKey(const ValueKey('stat-Reviews')), findsOneWidget);

      await tapKey(tester, 'profile-edit');
      expect(find.byType(EditProfileScreen), findsOneWidget);

      // Validation blocks a one-letter name.
      await tester.enterText(find.byKey(const ValueKey('edit-name')), 'D');
      await tapKey(tester, 'edit-save');
      expect(find.text('Enter your name (2+ characters)'), findsOneWidget);

      await tester.enterText(
        find.byKey(const ValueKey('edit-name')),
        'Dana Reyes',
      );
      await tester.enterText(find.byKey(const ValueKey('edit-city')), 'Tunis');
      await tester.enterText(
        find.byKey(const ValueKey('edit-bio')),
        'Live music and food markets.',
      );
      await tapKey(tester, 'avatar-color-2');
      await tapKey(tester, 'edit-save');
      // The save is a database transaction spanning several frames.
      for (var i = 0; i < 40; i++) {
        if (find.byType(EditProfileScreen).evaluate().isEmpty) break;
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      expect(find.byType(EditProfileScreen), findsNothing);
      expect(find.text('Dana Reyes'), findsOneWidget);
      expect(find.text('Tunis'), findsOneWidget);
      expect(find.text('Live music and food markets.'), findsOneWidget);
      final avatar = tester.widget<InitialsAvatar>(
        find.byKey(const ValueKey('profile-avatar')),
      );
      expect(avatar.color, kAvatarColors[2]);
      expect(find.text('DR'), findsOneWidget);

      // Persisted: a fresh read from the database matches.
      final container = ProviderScope.containerOf(
        tester.element(find.byType(MaterialApp)),
      );
      final stored = await tester.runAsync(
        () => container
            .read(profileRepositoryProvider)
            .load('u_demo', name: 'ignored'),
      );
      expect(stored!.city, 'Tunis');
      expect(stored.avatarColor, 2);
    });

    testWidgets('profile shows Settings and the unread badge', (tester) async {
      await setPhoneSize(tester);
      await tester.pumpWidget(TestApp().build(initialLocation: '/profile'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('profile-Settings')), findsOneWidget);
      await tapKey(tester, 'profile-Settings');
      expect(find.text('APPEARANCE'), findsOneWidget);
    });
  });

  group('favorites', () {
    Future<TestApp> pumpFavorites(
      WidgetTester tester, {
      Set<String> saved = const {},
    }) async {
      await setPhoneSize(tester);
      final app = TestApp(
        favorites: FakeFavoritesRepository()..ids.addAll(saved),
      );
      await tester.pumpWidget(app.build(initialLocation: '/favorites'));
      await tester.pumpAndSettle();
      return app;
    }

    testWidgets('empty state links back to Home', (tester) async {
      await pumpFavorites(tester);
      expect(find.byKey(const ValueKey('favorites-empty')), findsOneWidget);
      expect(find.byKey(const ValueKey('favorites-sort')), findsNothing);
      await tester.tap(find.text('Explore events'));
      await tester.pumpAndSettle();
      expect(find.text('Discover Amazing\nEvents Near You'), findsOneWidget);
    });

    testWidgets('grid/list toggle persists; sort reorders', (tester) async {
      final ids = {
        idOf('Pitchfork Music Night'),
        idOf('Highland Music Festival'),
      };
      final app = await pumpFavorites(tester, saved: ids);
      expect(find.byKey(const ValueKey('favorites-list')), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('favorites-view-toggle')));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('favorites-grid')), findsOneWidget);
      expect(app.prefs.values['favorites.view'], 'grid');

      await tester.tap(find.byKey(const ValueKey('favorites-sort')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('favorites-sort-name')));
      await tester.pumpAndSettle();
      expect(app.prefs.values['favorites.sort'], 'name');
      final highland = tester.getTopLeft(find.text('Highland Music Festival'));
      final pitchfork = tester.getTopLeft(find.text('Pitchfork Music Night'));
      expect(highland.dx < pitchfork.dx || highland.dy < pitchfork.dy, isTrue);
    });

    testWidgets('swipe removes with undo', (tester) async {
      final id = idOf('Pitchfork Music Night');
      final app = await pumpFavorites(tester, saved: {id});
      await tester.drag(
        find.byKey(ValueKey('fav-$id')),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();
      expect(app.favorites.ids, isNot(contains(id)));
      expect(find.byKey(const ValueKey('favorites-empty')), findsOneWidget);

      await tester.tap(find.text('Undo'));
      await tester.pumpAndSettle();
      expect(app.favorites.ids, contains(id));
      expect(find.text('Pitchfork Music Night'), findsWidgets);
    });

    test('sortFavorites orders by recent, date, price and name', () {
      final a = seed[0];
      final b = seed[1];
      final c = seed[2];
      final list = [a, b, c];
      final order = [c.id, a.id, b.id];
      expect(
        sortFavorites(list, FavoritesSort.recent, order).map((e) => e.id),
        [b.id, a.id, c.id],
      );
      final soonest = sortFavorites(list, FavoritesSort.soonest, order);
      for (var i = 1; i < soonest.length; i++) {
        expect(soonest[i - 1].startAt.isAfter(soonest[i].startAt), isFalse);
      }
      final cheap = sortFavorites(list, FavoritesSort.priceLow, order);
      for (var i = 1; i < cheap.length; i++) {
        expect(cheap[i - 1].price <= cheap[i].price, isTrue);
      }
    });
  });
}
