import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/widgets/gradient_button.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/features/events/presentation/providers.dart';
import 'package:eventra/features/feed/presentation/feed_providers.dart';
import 'package:eventra/features/home/domain/event_filter.dart';
import 'package:eventra/features/home/presentation/home_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Upper end of the price slider; at the cap the bound is open ("Any").
const kMaxPriceFilter = 150.0;

/// Upper end of the distance slider; at the cap there is no radius.
const kMaxDistanceFilter = 50.0;

String _priceLabel(double price) => price >= kMaxPriceFilter
    ? '${formatPrice(kMaxPriceFilter)}+'
    : formatPrice(price);

Future<void> showFiltersSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useRootNavigator: true,
    builder: (_) => const FiltersSheet(),
  );
}

/// Categories, dates, price, distance, availability and sort, with a live
/// result count. Applies to Home, See All, Search and Explore.
class FiltersSheet extends ConsumerStatefulWidget {
  const FiltersSheet({super.key});

  @override
  ConsumerState<FiltersSheet> createState() => _FiltersSheetState();
}

class _FiltersSheetState extends ConsumerState<FiltersSheet> {
  late EventFilter _draft = ref.read(homeFilterProvider);

  void _update(EventFilter f) {
    HapticFeedback.selectionClick();
    setState(() => _draft = f);
  }

  Future<void> _pickRange(DateTime now) async {
    final current = _draft.customRange;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(now.year + 2, now.month, now.day),
      initialDateRange: current == null
          ? null
          : DateTimeRange(
              start: current.start,
              end: current.end.subtract(const Duration(days: 1)),
            ),
      helpText: 'Pick a date range',
    );
    if (picked == null || !mounted) return;
    _update(
      _draft.copyWith(
        datePreset: DatePreset.custom,
        customRange: () => DateWindow.days(picked.start, picked.end),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final profile = ref.watch(feedProfileProvider);
    final upcoming = ref.watch(upcomingEventsProvider).value ?? const [];
    final count = _draft
        .apply(upcoming, origin: profile.origin, now: profile.now)
        .length;
    final minPrice = _draft.minPrice ?? 0;
    final maxPrice = _draft.maxPrice ?? kMaxPriceFilter;
    final distance = _draft.maxDistanceKm ?? kMaxDistanceFilter;
    final origin = ref.watch(userLocationProvider).label;

    Widget label(String text, {Key? key}) => Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Text(
        text,
        key: key,
        style: EventraText.cardTitle.copyWith(fontSize: 17),
      ),
    );

    final custom = _draft.customRange;
    return SafeArea(
      top: false,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 12, 0),
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Filters', style: EventraText.sectionTitle),
                  ),
                  TextButton(
                    key: const ValueKey('filters-reset'),
                    onPressed: _draft.isDefault
                        ? null
                        : () => _update(EventFilter.none),
                    child: Text(
                      'Reset',
                      style: TextStyle(
                        color: _draft.isDefault ? t.textHint : t.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                key: const ValueKey('filters-scroll'),
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    label('Categories'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilterChip(
                          key: const ValueKey('filter-cat-all'),
                          label: const Text('All'),
                          selected: _draft.categories.isEmpty,
                          onSelected: (_) => _update(
                            _draft.copyWith(categories: const {}),
                          ),
                        ),
                        for (final c in EventCategory.values)
                          FilterChip(
                            key: ValueKey('filter-cat-${c.name}'),
                            avatar: Icon(c.icon, size: 16),
                            label: Text(c.label),
                            selected: _draft.categories.contains(c),
                            onSelected: (_) =>
                                _update(_draft.toggleCategory(c)),
                          ),
                      ],
                    ),
                    label('Date'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final p in DatePreset.values)
                          ChoiceChip(
                            key: ValueKey('filter-date-${p.name}'),
                            avatar: p == DatePreset.custom
                                ? const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 16,
                                  )
                                : null,
                            label: Text(
                              p == DatePreset.custom && custom != null
                                  ? formatDayRange(custom.start, custom.end)
                                  : p.label,
                            ),
                            selected: _draft.datePreset == p,
                            onSelected: (_) => p == DatePreset.custom
                                ? _pickRange(profile.now)
                                : _update(_draft.copyWith(datePreset: p)),
                          ),
                      ],
                    ),
                    label(
                      'Price: ${formatPrice(minPrice)} - '
                      '${_priceLabel(maxPrice)}',
                      key: const ValueKey('filter-price-label'),
                    ),
                    RangeSlider(
                      key: const ValueKey('filter-price'),
                      values: RangeValues(minPrice, maxPrice),
                      max: kMaxPriceFilter,
                      divisions: 30,
                      activeColor: t.primary,
                      labels: RangeLabels(
                        formatPrice(minPrice),
                        _priceLabel(maxPrice),
                      ),
                      onChanged: _draft.freeOnly
                          ? null
                          : (v) => setState(
                              () => _draft = _draft.copyWith(
                                minPrice: () => v.start <= 0 ? null : v.start,
                                maxPrice: () =>
                                    v.end >= kMaxPriceFilter ? null : v.end,
                              ),
                            ),
                    ),
                    label(
                      distance >= kMaxDistanceFilter
                          ? 'Distance: any'
                          : 'Distance: within ${distance.round()} km',
                      key: const ValueKey('filter-distance-label'),
                    ),
                    Slider(
                      key: const ValueKey('filter-distance'),
                      value: distance,
                      min: 1,
                      max: kMaxDistanceFilter,
                      divisions: 49,
                      activeColor: t.primary,
                      label: distance >= kMaxDistanceFilter
                          ? 'Any'
                          : '${distance.round()} km',
                      onChanged: (v) => setState(
                        () => _draft = _draft.copyWith(
                          maxDistanceKm: () => v >= kMaxDistanceFilter
                              ? null
                              : v.roundToDouble(),
                        ),
                      ),
                    ),
                    Text('From $origin', style: EventraText.caption),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      key: const ValueKey('filter-free'),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: t.primary,
                      title: const Text('Free only'),
                      value: _draft.freeOnly,
                      onChanged: (v) => _update(_draft.copyWith(freeOnly: v)),
                    ),
                    SwitchListTile(
                      key: const ValueKey('filter-available'),
                      contentPadding: EdgeInsets.zero,
                      activeThumbColor: t.primary,
                      title: const Text('Has tickets left'),
                      value: _draft.hasTicketsLeft,
                      onChanged: (v) =>
                          _update(_draft.copyWith(hasTicketsLeft: v)),
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
                                _update(_draft.copyWith(sort: s)),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
              child: GradientPillButton(
                key: const ValueKey('filters-apply'),
                label: count == 1 ? 'Show 1 result' : 'Show $count results',
                onPressed: () {
                  ref.read(homeFilterProvider.notifier).set(_draft);
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
