import 'dart:async';

import 'package:eventra/features/auth/presentation/auth_providers.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/notifications/data/notifications_repository.dart';
import 'package:eventra/features/notifications/domain/app_notification.dart';
import 'package:eventra/features/settings/presentation/settings_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:eventra/features/notifications/domain/app_notification.dart';

final notificationsRepositoryProvider = Provider<NotificationsRepository>(
  (ref) => NotificationsRepository(
    ref.watch(appDatabaseProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Inbox scope: the signed-in user id, or 'guest'.
final notificationScopeProvider = Provider<String>(
  (ref) => ref.watch(authControllerProvider.select((s) => s.scope)),
);

/// The current inbox, newest first. Updates are optimistic and persisted.
class NotificationsNotifier extends Notifier<List<AppNotification>> {
  NotificationsRepository get _repo =>
      ref.read(notificationsRepositoryProvider);
  String get _scope => ref.read(notificationScopeProvider);

  @override
  List<AppNotification> build() {
    ref
      ..watch(notificationScopeProvider)
      ..watch(notificationsRepositoryProvider)
      // Seed once the catalogue is available.
      ..watch(eventsProvider.select((a) => a.hasValue));
    unawaited(_load());
    return const [];
  }

  Future<void> _load() async {
    final scope = _scope;
    final events = ref.read(eventsProvider).value;
    if (events != null) await _repo.seedIfNeeded(scope, events);
    final items = await _repo.list(scope);
    if (ref.mounted && scope == _scope) state = items;
  }

  /// Reloads from storage (after another feature added an item).
  Future<void> reload() => _load();

  Future<void> markRead(String id) async {
    state = [
      for (final n in state)
        if (n.id == id) n.copyWith(read: true) else n,
    ];
    await _repo.markRead(_scope, id);
  }

  Future<void> markAllRead() async {
    state = [for (final n in state) n.copyWith(read: true)];
    await _repo.markAllRead(_scope);
  }

  Future<void> remove(String id) async {
    state = [
      for (final n in state)
        if (n.id != id) n,
    ];
    await _repo.remove(_scope, id);
  }

  /// Undo for [remove].
  Future<void> insert(int index, AppNotification n) async {
    state = [...state]..insert(index.clamp(0, state.length), n);
    await _repo.put(_scope, n);
  }
}

final notificationsProvider =
    NotifierProvider<NotificationsNotifier, List<AppNotification>>(
      NotificationsNotifier.new,
    );

/// What the inbox shows: recommendation items are hidden when the user
/// turns them off in Settings.
final visibleNotificationsProvider = Provider<List<AppNotification>>((ref) {
  final all = ref.watch(notificationsProvider);
  final recs = ref.watch(settingsProvider.select((s) => s.recommendations));
  return recs
      ? all
      : [
          for (final n in all)
            if (!n.kind.recommendation) n,
        ];
});

final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(visibleNotificationsProvider).where((n) => !n.read).length,
);
