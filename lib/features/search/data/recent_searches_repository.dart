import 'package:eventra/core/storage/prefs_store.dart';

/// Recent search terms, newest first, persisted in the settings store.
/// Case-insensitive de-duplication; capped at [limit].
class RecentSearchesRepository {
  RecentSearchesRepository(
    this._prefs, {
    this.scope = 'guest',
    this.limit = 10,
  });

  final PrefsStore _prefs;

  /// Per account so a shared device keeps searches apart.
  final String scope;
  final int limit;

  String get _key => 'search.recent.$scope';

  List<String> load() => _prefs.getStringList(_key) ?? const [];

  /// Adds [term] to the top. Blank terms are ignored.
  Future<List<String>> add(String term) async {
    final t = term.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.isEmpty) return load();
    final next = [
      t,
      for (final e in load())
        if (e.toLowerCase() != t.toLowerCase()) e,
    ].take(limit).toList();
    await _prefs.setStringList(_key, next);
    return next;
  }

  Future<List<String>> remove(String term) async {
    final next = [
      for (final e in load())
        if (e != term) e,
    ];
    await _prefs.setStringList(_key, next);
    return next;
  }

  /// Puts [term] back at [index] (undo of a swipe delete).
  Future<List<String>> restore(String term, int index) async {
    final list = [
      for (final e in load())
        if (e.toLowerCase() != term.toLowerCase()) e,
    ];
    list.insert(index.clamp(0, list.length), term);
    final next = list.take(limit).toList();
    await _prefs.setStringList(_key, next);
    return next;
  }

  Future<void> clear() => _prefs.remove(_key);
}
