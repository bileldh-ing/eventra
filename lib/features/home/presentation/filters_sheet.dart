import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:eventra/features/home/presentation/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const kMaxPriceFilter = 150.0;

String _priceLabel(double price) =>
    price >= kMaxPriceFilter ? 'Any' : formatPrice(price);

Future<void> showFiltersSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => const FiltersSheet(),
  );
}

/// Category, price, availability and sort, with a live result count.
class FiltersSheet extends ConsumerStatefulWidget {
  const FiltersSheet({super.key});

  @override
  ConsumerState<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<FiltersSheet> {
  late EventFilter _draft = ref.read(homeFilterProvider);

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final origin = ref.watch(userLocationProvider).position;
    final upcoming = ref.watch(upcomingEventsProvider).value ?? const [];
    final count = _draft.apply(upcoming, origin: origin).length;
    final price = _draft.maxPrice ?? kMaxPriceFilter;

    Widget label(String text) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(text, style: EventraText.cardTitle.copyWith(fontSize: 17)),
    );

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text('Filters', style: EventraText.sectionTitle),
                ),
                TextButton(
                  key: const ValueKey('filters-reset'),
                  onPressed: () => setState(() => _draft = EventFilter.none),
                  child: Text('Reset', style: TextStyle(color: t.primary)),
                ),
              ],
            ),
            label('Category'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in <EventCategory?>[null, ...EventCategory.values])
                  ChoiceChip(
                    key: ValueKey('filter-cat-${c?.name ?? 'all'}'),
                    label: Text(c?.label ?? 'All'),
                    selected: _draft.category == c,
                    onSelected: (_) => setState(
                      () => _draft = _draft.copyWith(category: () => c),
                    ),
                  ),
              ],
            ),
            label('Max price: ${_priceLabel(price)}'),
            Slider(
              key: const ValueKey('filter-price'),
              value: price,
              max: kMaxPriceFilter,
              divisions: 15,
              activeColor: t.primary,
              label: _priceLabel(price),
              onChanged: (v) => setState(
                () => _draft = _draft.copyWith(
                  maxPrice: () => v >= kMaxPriceFilter ? null : v,
                ),
              ),
            ),
            SwitchListTile(
              key: const ValueKey('filter-free'),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: t.primary,
              title: const Text('Free only'),
              value: _draft.freeOnly,
              onChanged: (v) =>
                  setState(() => _draft = _draft.copyWith(freeOnly: v)),
            ),
            SwitchListTile(
              key: const ValueKey('filter-available'),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: t.primary,
              title: const Text('Has tickets left'),
              value: _draft.hasTicketsLeft,
              onChanged: (v) =>
                  setState(() => _draft = _draft.copyWith(hasTicketsLeft: v)),
            ),
            label('Sort by'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final s in EventSort.values)
                  ChoiceChip(
                    key: ValueKey('filter-sort-${s.name}'),
                    label: Text(s.label),
                    selected: _draft.sort == s,
                    onSelected: (_) =>
                        setState(() => _draft = _draft.copyWith(sort: s)),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            GradientPillButton(
              key: const ValueKey('filters-apply'),
              label: 'Show $count results',
              onPressed: () {
                ref.read(homeFilterProvider.notifier).set(_draft);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
