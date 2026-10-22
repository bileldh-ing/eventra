import 'package:eventra/core/storage/storage_providers.dart';
import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/profile/data/profile_repository.dart';
import 'package:eventra/features/profile/domain/user_profile.dart';
import 'package:eventra/features/reviews/presentation/reviews_providers.dart';
import 'package:eventra/features/search/presentation/search_providers.dart';
import 'package:eventra/features/tickets/domain/ticketing_models.dart';
import 'package:eventra/features/tickets/presentation/ticketing_providers.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(
    ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

class ProfileRevision extends Notifier<int> {
  @override
  int build() => 0;
  void bump() => state++;
}

/// Empties the on-disk image cache (overridden in tests).
final diskImageCacheClearerProvider = Provider<Future<void> Function()>(
  (ref) =>
      () => DefaultCacheManager().emptyCache(),
);

final profileRevisionProvider = NotifierProvider<ProfileRevision, int>(
  ProfileRevision.new,
);

/// The signed-in user's profile (null for guests).
final profileProvider = FutureProvider<UserProfile?>((ref) async {
  ref.watch(profileRevisionProvider);
  final user = ref.watch(authControllerProvider.select((s) => s.user));
  if (user == null) return null;
  return ref.read(profileRepositoryProvider).load(user.id, name: user.name);
});

/// Header counters on the profile.
class ProfileStats {
  const ProfileStats({
    required this.tickets,
    required this.saved,
    required this.reviews,
  });
  final int tickets;
  final int saved;
  final int reviews;
}

final profileStatsProvider = Provider<ProfileStats>((ref) {
  final saved = ref.watch(favoritesProvider).length;
  final tickets =
      ref
          .watch(myTicketsProvider)
          .value
          ?.where((e) => e.ticket.status != TicketStatus.cancelled)
          .length ??
      0;
  final reviews = ref.watch(myReviewCountProvider).value ?? 0;
  return ProfileStats(tickets: tickets, saved: saved, reviews: reviews);
});

final myReviewCountProvider = FutureProvider<int>((ref) async {
  ref.watch(reviewsRevisionProvider);
  final user = ref.watch(authControllerProvider.select((s) => s.user));
  if (user == null) return 0;
  return ref.read(profileRepositoryProvider).reviewCount(user.id);
});

/// Profile and account commands.
class ProfileActions {
  ProfileActions(this._ref);
  final Ref _ref;

  Future<void> save(UserProfile profile) async {
    final user = _ref.read(authControllerProvider).user;
    if (user == null) return;
    final saved = await _ref
        .read(profileRepositoryProvider)
        .save(user.id, profile);
    _ref
        .read(authControllerProvider.notifier)
        .replaceUser(user.copyWith(name: saved.name));
    _ref.read(profileRevisionProvider.notifier).bump();
  }

  /// Clears cached images (memory and disk) and search history.
  Future<void> clearCache() async {
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    try {
      await _ref.read(diskImageCacheClearerProvider)();
    } on Object {
      // No disk cache available (tests, unsupported platform).
    }
    await _ref.read(recentSearchesRepositoryProvider).clear();
    _ref.invalidate(recentSearchesProvider);
  }

  /// Deletes the account and all its data, then signs out.
  Future<void> deleteAccount() async {
    final user = _ref.read(authControllerProvider).user;
    if (user == null) return;
    await _ref
        .read(ticketingActionsProvider)
        .applyReminderSetting(userId: user.id, enabled: false);
    await _ref.read(profileRepositoryProvider).deleteAccount(user.id);
    final prefs = _ref.read(prefsStoreProvider);
    await prefs.remove('interests.${user.id}');
    await _ref.read(recentSearchesRepositoryProvider).clear();
    await _ref.read(authControllerProvider.notifier).logOut();
  }
}

final profileActionsProvider = Provider<ProfileActions>(ProfileActions.new);
