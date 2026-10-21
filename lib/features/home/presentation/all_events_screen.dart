import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/events/presentation/widgets/event_cards.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:eventra/features/home/presentation/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 'See All': every upcoming event for the active category, with sorting.
class AllEventsScreen extends ConsumerStatefulWidget {
  const AllEventsScreen({super.key});

  @override
  ConsumerState<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends ConsumerState<AllEventsScreen> {
  EventSort _sort = EventSort.recommended;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final category = ref.watch(homeFilterProvider).category;
    final origin = ref.watch(userLocationProvider).position;
    final async = ref.watch(upcomingEventsProvider);
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        title: Text(
          category == null ? 'Upcoming Events' : '${category.label} Events',
          style: EventraText.sectionTitle,
        ),
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
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      key: ValueKey('sort-${s.name}'),
                      label: Text(s.label),
                      selected: _sort == s,
                      onSelected: (_) => setState(() => _sort = s),
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
                final list = EventFilter(
                  category: category,
                  sort: _sort,
                ).apply(all, origin: origin);
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
