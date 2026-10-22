import 'package:eventra/core/storage/prefs_store.dart';
import 'package:eventra/features/search/data/recent_searches_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late MemoryPrefsStore prefs;
  late RecentSearchesRepository repo;

  setUp(() {
    prefs = MemoryPrefsStore();
    repo = RecentSearchesRepository(prefs, scope: 'u1', limit: 3);
  });

  test('starts empty and keeps newest first', () async {
    expect(repo.load(), isEmpty);
    await repo.add('jazz');
    await repo.add('tech');
    expect(repo.load(), ['tech', 'jazz']);
  });

  test('trims, collapses spaces and ignores blanks', () async {
    await repo.add('   ');
    expect(repo.load(), isEmpty);
    await repo.add('  rooftop   party ');
    expect(repo.load(), ['rooftop party']);
  });

  test(
    'de-duplicates case-insensitively, moving the term to the top',
    () async {
      await repo.add('Jazz');
      await repo.add('tech');
      await repo.add('jazz');
      expect(repo.load(), ['jazz', 'tech']);
    },
  );

  test('caps the list at the limit', () async {
    for (final t in ['a', 'b', 'c', 'd']) {
      await repo.add(t);
    }
    expect(repo.load(), ['d', 'c', 'b']);
  });

  test('remove, restore at index and clear', () async {
    for (final t in ['a', 'b', 'c']) {
      await repo.add(t);
    }
    expect(await repo.remove('b'), ['c', 'a']);
    expect(await repo.restore('b', 1), ['c', 'b', 'a']);
    expect(await repo.restore('z', 99), ['c', 'b', 'a']); // capped at 3
    await repo.clear();
    expect(repo.load(), isEmpty);
  });

  test('persists in the store and is scoped per account', () async {
    await repo.add('jazz');
    expect(RecentSearchesRepository(prefs, scope: 'u1').load(), ['jazz']);
    expect(RecentSearchesRepository(prefs, scope: 'u2').load(), isEmpty);
  });
}
