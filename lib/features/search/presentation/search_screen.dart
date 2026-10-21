import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/events/presentation/widgets/event_cards.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Live search over title, venue, address and category.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final query = _controller.text;
    final events = ref.watch(upcomingEventsProvider).value ?? const [];
    final results = events.where((e) => matchesQuery(e, query)).toList();
    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 20, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Back',
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  Expanded(
                    child: Hero(
                      tag: 'search-field',
                      child: Material(
                        color: t.surface,
                        borderRadius: BorderRadius.circular(999),
                        child: TextField(
                          key: const ValueKey('search-input'),
                          controller: _controller,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            hintText: 'Search events, venues, places',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear',
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: () =>
                                        setState(_controller.clear),
                                  ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (query.isEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Popular searches',
                      style: EventraText.cardTitle.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final term in [
                          ...EventCategory.values.map((c) => c.label),
                          'Brooklyn',
                          'Nyack',
                        ])
                          ActionChip(
                            key: ValueKey('suggest-$term'),
                            label: Text(term),
                            onPressed: () => setState(
                              () => _controller.text = term,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              )
            else
              Expanded(
                child: results.isEmpty
                    ? Center(
                        child: MessageView(
                          icon: Icons.search_off_rounded,
                          title: 'No results',
                          message: 'Nothing matches "$query".',
                          actionLabel: 'Clear search',
                          onAction: () => setState(_controller.clear),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                        itemCount: results.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => EventListTile(
                          event: results[i],
                          heroTag: 'search-${results[i].id}',
                        ),
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
