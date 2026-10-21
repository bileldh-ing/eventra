import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/events/presentation/widgets/event_cards.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Saved events with swipe-to-remove and undo.
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final ids = ref.watch(favoritesProvider);
    final events = ref.watch(eventsProvider).value ?? const [];
    final saved = events.where((e) => ids.contains(e.id)).toList();
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        automaticallyImplyLeading: false,
        title: const Text('Favorites', style: EventraText.sectionTitle),
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
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 130),
              itemCount: saved.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final e = saved[i];
                return Dismissible(
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
                  onDismissed: (_) {
                    final notifier = ref.read(favoritesProvider.notifier)
                      ..toggle(e.id);
                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text('Removed ${e.title}'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () => notifier.toggle(e.id),
                          ),
                        ),
                      );
                  },
                  child: EventListTile(
                    event: e,
                    heroTag: 'fav-${e.id}',
                    trailing: Icon(Icons.favorite_rounded, color: t.primary),
                  ),
                );
              },
            ),
    );
  }
}
