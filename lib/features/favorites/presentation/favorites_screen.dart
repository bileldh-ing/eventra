import 'package:collection/collection.dart';
import 'package:eventra/core/storage/storage_providers.dart';
import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/events/presentation/widgets/event_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum FavoritesSort {
  recent('Recently saved'),
  soonest('Date: soonest'),
  priceLow('Price: low to high'),
  name('Name: A to Z');

  const FavoritesSort(this.label);
  final String label;
}

enum FavoritesView { list, grid }

/// Persisted view mode and sort for the Favorites tab.
@immutable
class FavoritesPrefs {
  const FavoritesPrefs({
    this.view = FavoritesView.list,
    this.sort = FavoritesSort.recent,
  });
  final FavoritesView view;
  final FavoritesSort sort;
}

class FavoritesPrefsNotifier extends Notifier<FavoritesPrefs> {
  static const _viewKey = 'favorites.view';
  static const _sortKey = 'favorites.sort';

  @override
  FavoritesPrefs build() {
    final p = ref.watch(prefsStoreProvider);
    return FavoritesPrefs(
      view:
          FavoritesView.values.firstWhereOrNull(
            (v) => v.name == p.getString(_viewKey),
          ) ??
          FavoritesView.list,
      sort:
          FavoritesSort.values.firstWhereOrNull(
            (v) => v.name == p.getString(_sortKey),
          ) ??
          FavoritesSort.recent,
    );
  }

  Future<void> setView(FavoritesView view) async {
    state = FavoritesPrefs(view: view, sort: state.sort);
    await ref.read(prefsStoreProvider).setString(_viewKey, view.name);
  }

  Future<void> setSort(FavoritesSort sort) async {
    state = FavoritesPrefs(view: state.view, sort: sort);
    await ref.read(prefsStoreProvider).setString(_sortKey, sort.name);
  }
}

final favoritesPrefsProvider =
    NotifierProvider<FavoritesPrefsNotifier, FavoritesPrefs>(
      FavoritesPrefsNotifier.new,
    );

/// Orders saved events. [savedOrder] is the ids in the order they were
/// saved (oldest first).
List<Event> sortFavorites(
  List<Event> events,
  FavoritesSort sort,
  List<String> savedOrder,
) {
  final list = [...events];
  switch (sort) {
    case FavoritesSort.recent:
      final rank = {for (final (i, id) in savedOrder.indexed) id: i};
      list.sort((a, b) => (rank[b.id] ?? -1).compareTo(rank[a.id] ?? -1));
    case FavoritesSort.soonest:
      list.sort((a, b) => a.startAt.compareTo(b.startAt));
    case FavoritesSort.priceLow:
      list.sort((a, b) => a.price.compareTo(b.price));
    case FavoritesSort.name:
      list.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );
  }
  return list;
}

/// Saved events: list or grid, sortable, swipe to remove with undo.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final ids = ref.watch(favoritesProvider);
    final prefs = ref.watch(favoritesPrefsProvider);
    final prefsNotifier = ref.read(favoritesPrefsProvider.notifier);
    final events = ref.watch(eventsProvider).value ?? const [];
    final saved = sortFavorites(
      events.where((e) => ids.contains(e.id)).toList(),
      prefs.sort,
      ids.toList(),
    );

    void remove(Event e) {
      final notifier = ref.read(favoritesProvider.notifier)..toggle(e.id);
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Removed ${e.title}'),
            action: SnackBarAction(
              key: const ValueKey('favorites-undo'),
              label: 'Undo',
              onPressed: () {
                if (!notifier.isFavorite(e.id)) notifier.toggle(e.id);
              },
            ),
          ),
        );
    }

    Widget dismissible(Event e, Widget child) => Dismissible(
      key: ValueKey('fav-${e.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 28),
        decoration: BoxDecoration(
          color: t.error.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(t.radii.listCard),
        ),
        child: Icon(Icons.delete_outline_rounded, color: t.error),
      ),
      onDismissed: (_) => remove(e),
      child: child,
    );

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        automaticallyImplyLeading: false,
        title: const Text('Favorites', style: EventraText.sectionTitle),
        actions: [
          if (saved.isNotEmpty) ...[
            PopupMenuButton<FavoritesSort>(
              key: const ValueKey('favorites-sort'),
              tooltip: 'Sort',
              icon: const Icon(Icons.sort_rounded),
              initialValue: prefs.sort,
              onSelected: prefsNotifier.setSort,
              itemBuilder: (_) => [
                for (final s in FavoritesSort.values)
                  CheckedPopupMenuItem(
                    key: ValueKey('favorites-sort-${s.name}'),
                    value: s,
                    checked: s == prefs.sort,
                    child: Text(s.label),
                  ),
              ],
            ),
            IconButton(
              key: const ValueKey('favorites-view-toggle'),
              tooltip: prefs.view == FavoritesView.list
                  ? 'Show as grid'
                  : 'Show as list',
              onPressed: () => prefsNotifier.setView(
                prefs.view == FavoritesView.list
                    ? FavoritesView.grid
                    : FavoritesView.list,
              ),
              icon: Icon(
                prefs.view == FavoritesView.list
                    ? Icons.grid_view_rounded
                    : Icons.view_agenda_outlined,
              ),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
      body: saved.isEmpty
          ? Center(
              child: MessageView(
                key: const ValueKey('favorites-empty'),
                icon: Icons.favorite_border_rounded,
                title: 'No favorites yet',
                message: 'Tap the bookmark on any event to save it here.',
                actionLabel: 'Explore events',
                onAction: () => context.go('/home'),
              ),
            )
          : prefs.view == FavoritesView.list
          ? ListView.separated(
              key: const ValueKey('favorites-list'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
              itemCount: saved.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = saved[i];
                return dismissible(
                  e,
                  EventListTile(
                    event: e,
                    heroTag: 'fav-${e.id}',
                    trailing: Icon(Icons.favorite_rounded, color: t.primary),
                  ),
                );
              },
            )
          : GridView.builder(
              key: const ValueKey('favorites-grid'),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                mainAxisExtent: 196,
              ),
              itemCount: saved.length,
              itemBuilder: (context, i) {
                final e = saved[i];
                return dismissible(
                  e,
                  CompactEventCard(event: e, heroTag: 'favgrid-${e.id}'),
                );
              },
            ),
    );
  }
}
