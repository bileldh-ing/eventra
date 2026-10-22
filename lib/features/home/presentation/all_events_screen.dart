import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/events/presentation/widgets/event_cards.dart';
import 'package:eventra/features/feed/presentation/feed_providers.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:eventra/features/home/presentation/filters_sheet.dart';
import 'package:eventra/features/home/presentation/home_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 'See All': every upcoming event through the active filters, with sort
/// chips (they edit the shared filter's sort).
class AllEventsScreen extends ConsumerWidget {
  const AllEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final filter = ref.watch(homeFilterProvider);
    final profile = ref.watch(feedProfileProvider);
    final async = ref.watch(upcomingEventsProvider);
    final category = filter.category;
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        title: Text(
          category == null
              ? context.l10n.homeUpcoming
              : context.l10n.categoryEvents(category.label),
          style: context.text.sectionTitle,
        ),
        actions: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: IconButton(
              key: const ValueKey('all-filter'),
              tooltip: context.l10n.filtersTitle,
              onPressed: () => showFiltersSheet(context),
              icon: Badge(
                isLabelVisible: filter.refinementCount > 0,
                backgroundColor: t.primary,
                label: Text('${filter.refinementCount}'),
                child: const Icon(Icons.tune_rounded),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                for (final s in EventSort.values)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      key: ValueKey('sort-${s.name}'),
                      label: Text(s.label),
                      selected: filter.sort == s,
                      onSelected: (_) => ref
                          .read(homeFilterProvider.notifier)
                          .set(filter.copyWith(sort: s)),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: MessageView.error(
                  message: '$e',
                  onRetry: () => ref.read(eventsProvider.notifier).refresh(),
                ),
              ),
              data: (all) {
                final list = filter.apply(
                  all,
                  origin: profile.origin,
                  profile: profile,
                );
                if (list.isEmpty) {
                  return Center(
                    child: MessageView(
                      key: const ValueKey('all-empty'),
                      icon: Icons.filter_alt_off_outlined,
                      title: context.l10n.noEventsMatch,
                      message: context.l10n.loosenFilters,
                      actionLabel: context.l10n.resetFilters,
                      onAction: () =>
                          ref.read(homeFilterProvider.notifier).reset(),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 32),
                  itemCount: list.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => EventListTile(
                    event: list[i],
                    heroTag: 'all-${list[i].id}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
