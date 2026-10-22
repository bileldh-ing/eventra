import 'dart:async';

import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/state_views.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/events/presentation/widgets/event_cards.dart';
import 'package:eventra/features/feed/presentation/feed_providers.dart';
import 'package:eventra/features/home/presentation/filters_sheet.dart';
import 'package:eventra/features/home/presentation/home_providers.dart';
import 'package:eventra/features/search/domain/search_logic.dart';
import 'package:eventra/features/search/presentation/search_providers.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Debounce between the last keystroke and the results update.
const kSearchDebounce = Duration(milliseconds: 250);

/// Live search over title, venue, address and category, narrowed by the
/// shared filters. Recent searches persist per account.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  final _focus = FocusNode();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    setState(() {}); // clear button visibility
    _debounce?.cancel();
    _debounce = Timer(kSearchDebounce, () {
      if (mounted) setState(() => _query = text.trim());
    });
  }

  /// Fills the field and searches immediately (chips, recents).
  void _searchNow(String term) {
    _debounce?.cancel();
    _controller
      ..text = term
      ..selection = TextSelection.collapsed(offset: term.length);
    setState(() => _query = term.trim());
    _remember(term);
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() => _query = '');
    _focus.requestFocus();
  }

  void _remember(String term) =>
      ref.read(recentSearchesProvider.notifier).add(term);

  void _snack(String text, VoidCallback onUndo) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(label: context.l10n.undo, onPressed: onUndo),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final filter = ref.watch(homeFilterProvider);
    final profile = ref.watch(feedProfileProvider);
    final events = ref.watch(upcomingEventsProvider).value ?? const <Event>[];
    final results = _query.isEmpty
        ? const <Event>[]
        : searchWithFilter(
            events,
            _query,
            filter,
            now: profile.now,
            origin: profile.origin,
          );

    final Widget body;
    if (_query.isEmpty) {
      body = _Idle(
        key: const ValueKey('search-idle'),
        trending: trendingSearches(events),
        onTerm: _searchNow,
        onSnack: _snack,
      );
    } else if (results.isEmpty) {
      body = _NoResults(
        key: const ValueKey('search-empty'),
        query: _query,
        suggestions: trendingSearches(events, max: 6),
        filtersOn: !filter.isDefault,
        onTerm: _searchNow,
        onClearFilters: () => ref.read(homeFilterProvider.notifier).reset(),
        onClearSearch: _clear,
      );
    } else {
      body = Column(
        key: const ValueKey('search-results'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 4, 16, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.nResults(results.length),
                    key: const ValueKey('search-count'),
                    style: context.text.caption,
                  ),
                ),
                if (!filter.isDefault)
                  TextButton.icon(
                    key: const ValueKey('search-clear-filters'),
                    onPressed: () =>
                        ref.read(homeFilterProvider.notifier).reset(),
                    icon: const Icon(Icons.close_rounded, size: 16),
                    label: Text(context.l10n.clearFilters),
                    style: TextButton.styleFrom(foregroundColor: t.primary),
                  ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsetsDirectional.fromSTEB(20, 4, 20, 32),
              itemCount: results.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) => EventListTile(
                event: results[i],
                heroTag: 'search-${results[i].id}',
                highlight: _query,
                onOpen: () => _remember(_query),
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: t.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    tooltip: context.l10n.back,
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
                          focusNode: _focus,
                          autofocus: true,
                          textInputAction: TextInputAction.search,
                          onChanged: _onChanged,
                          onSubmitted: (v) {
                            if (v.trim().isNotEmpty) _searchNow(v.trim());
                          },
                          decoration: InputDecoration(
                            hintText: context.l10n.searchFullHint,
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: _controller.text.isEmpty
                                ? null
                                : IconButton(
                                    key: const ValueKey('search-clear'),
                                    tooltip: context.l10n.clear,
                                    icon: const Icon(Icons.close_rounded),
                                    onPressed: _clear,
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
                  const SizedBox(width: 8),
                  Material(
                    color: t.surface,
                    shape: const CircleBorder(),
                    child: IconButton(
                      key: const ValueKey('search-filter'),
                      tooltip: context.l10n.filtersTitle,
                      onPressed: () => showFiltersSheet(context),
                      icon: Badge(
                        isLabelVisible: !filter.isDefault,
                        backgroundColor: t.primary,
                        smallSize: 8,
                        child: Icon(Icons.tune_rounded, color: t.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: t.motion.fast,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Recent searches (swipe or clear) and trending chips.
class _Idle extends ConsumerWidget {
  const _Idle({
    required this.trending,
    required this.onTerm,
    required this.onSnack,
    super.key,
  });

  final List<String> trending;
  final ValueChanged<String> onTerm;
  final void Function(String text, VoidCallback onUndo) onSnack;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.tokens;
    final recent = ref.watch(recentSearchesProvider);
    final notifier = ref.read(recentSearchesProvider.notifier);
    final heading = context.text.cardTitle.copyWith(fontSize: 17);
    return ListView(
      padding: const EdgeInsetsDirectional.fromSTEB(0, 8, 0, 32),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      children: [
        if (recent.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 12, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(context.l10n.recentSearches, style: heading),
                ),
                TextButton(
                  key: const ValueKey('recent-clear-all'),
                  onPressed: () {
                    final before = [...recent];
                    notifier.clear();
                    onSnack(context.l10n.recentCleared, () async {
                      for (var i = 0; i < before.length; i++) {
                        await notifier.restore(before[i], i);
                      }
                    });
                  },
                  style: TextButton.styleFrom(foregroundColor: t.primary),
                  child: Text(context.l10n.clearAll),
                ),
              ],
            ),
          ),
          for (final (i, term) in recent.indexed)
            Dismissible(
              key: ValueKey('recent-$term'),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: AlignmentDirectional.centerEnd,
                padding: const EdgeInsetsDirectional.only(end: 28),
                color: t.error.withValues(alpha: 0.12),
                child: Icon(Icons.delete_outline_rounded, color: t.error),
              ),
              onDismissed: (_) {
                notifier.remove(term);
                onSnack(
                  context.l10n.removedTerm(term),
                  () => notifier.restore(term, i),
                );
              },
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                leading: Icon(Icons.history_rounded, color: t.textSecondary),
                title: Text(term, maxLines: 1, overflow: TextOverflow.ellipsis),
                trailing: Icon(
                  Icons.north_west_rounded,
                  size: 18,
                  color: t.textHint,
                ),
                onTap: () => onTerm(term),
              ),
            ),
          const SizedBox(height: 12),
        ],
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 8, 24, 12),
          child: Text(context.l10n.trendingSearches, style: heading),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final term in trending)
                ActionChip(
                  key: ValueKey('suggest-$term'),
                  avatar: Icon(
                    Icons.trending_up_rounded,
                    size: 16,
                    color: t.primary,
                  ),
                  label: Text(term),
                  onPressed: () => onTerm(term),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _NoResults extends StatelessWidget {
  const _NoResults({
    required this.query,
    required this.suggestions,
    required this.filtersOn,
    required this.onTerm,
    required this.onClearFilters,
    required this.onClearSearch,
    super.key,
  });

  final String query;
  final List<String> suggestions;
  final bool filtersOn;
  final ValueChanged<String> onTerm;
  final VoidCallback onClearFilters;
  final VoidCallback onClearSearch;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return SingleChildScrollView(
      padding: const EdgeInsets.only(top: 24, bottom: 32),
      child: Column(
        children: [
          MessageView(
            icon: Icons.search_off_rounded,
            title: context.l10n.noResultsFor(query),
            message: filtersOn
                ? context.l10n.searchFiltersHiding
                : context.l10n.searchCheckSpelling,
            actionLabel: filtersOn
                ? context.l10n.clearFilters
                : context.l10n.clearSearch,
            onAction: filtersOn ? onClearFilters : onClearSearch,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final term in suggestions)
                  ActionChip(
                    key: ValueKey('empty-suggest-$term'),
                    avatar: Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: t.primary,
                    ),
                    label: Text(term),
                    onPressed: () => onTerm(term),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
