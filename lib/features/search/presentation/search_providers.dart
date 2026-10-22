import 'package:eventra/core/storage/storage_providers.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/search/data/recent_searches_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final recentSearchesRepositoryProvider = Provider<RecentSearchesRepository>(
  (ref) => RecentSearchesRepository(
    ref.watch(prefsStoreProvider),
    scope: ref.watch(authControllerProvider.select((s) => s.scope)),
  ),
);

/// Recent searches for the current account, newest first.
class RecentSearchesNotifier extends Notifier<List<String>> {
  RecentSearchesRepository get _repo =>
      ref.read(recentSearchesRepositoryProvider);

  @override
  List<String> build() => ref.watch(recentSearchesRepositoryProvider).load();

  Future<void> add(String term) async {
    final next = await _repo.add(term);
    if (ref.mounted) state = next;
  }

  Future<void> remove(String term) async {
    final next = await _repo.remove(term);
    if (ref.mounted) state = next;
  }

  Future<void> restore(String term, int index) async {
    final next = await _repo.restore(term, index);
    if (ref.mounted) state = next;
  }

  Future<void> clear() async {
    await _repo.clear();
    if (ref.mounted) state = const [];
  }
}

final recentSearchesProvider =
    NotifierProvider<RecentSearchesNotifier, List<String>>(
      RecentSearchesNotifier.new,
    );
