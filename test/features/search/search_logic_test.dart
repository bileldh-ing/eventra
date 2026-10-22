import 'package:eventra/features/search/domain/search_logic.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/seed.dart';

void main() {
  final seed = loadSeed().events;

  test('rank: title prefix > word prefix > substring > venue > category', () {
    final e = seed.firstWhere((e) => e.title == 'Pitchfork Music Night');
    expect(searchRank(e, 'pitch'), 5);
    expect(searchRank(e, 'music'), 4);
    expect(searchRank(e, 'fork'), 3);
    expect(searchRank(e, e.venue.split(' ').first), greaterThanOrEqualTo(2));
    expect(searchRank(e, 'zzqx'), 0);
    expect(searchRank(e, '   '), 0);
  });

  test('results are ordered by rank and deterministic', () {
    final r = searchEvents(seed, 'music');
    expect(r, isNotEmpty);
    final ranks = r.map((e) => searchRank(e, 'music')).toList();
    for (var i = 1; i < ranks.length; i++) {
      expect(ranks[i], lessThanOrEqualTo(ranks[i - 1]));
    }
    expect(searchEvents(seed.reversed, 'music').map((e) => e.id), [
      for (final e in r) e.id,
    ]);
  });

  test('match ranges are case-insensitive and non-overlapping', () {
    expect(matchRanges('Music Night music', 'MUSIC'), [(0, 5), (12, 17)]);
    expect(matchRanges('aaaa', 'aa'), [(0, 2), (2, 4)]);
    expect(matchRanges('abc', ''), isEmpty);
  });

  test('trending searches: unique, capped and stable', () {
    final t = trendingSearches(seed);
    expect(t.length, 8);
    expect(t.toSet().length, 8);
    expect(trendingSearches(seed.reversed), t);
  });
}
