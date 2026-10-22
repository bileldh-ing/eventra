import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/utils/formatters.dart';
import 'package:eventra/core/utils/geo.dart';
import 'package:eventra/core/widgets/event_image.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/features/events/domain/entities/event.dart';
import 'package:eventra/features/explore/domain/nearest.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// Floating white card with the selected event (reference: thumbnail 88x88
/// radius 20, title, date range, pin + address).
class PreviewCard extends StatelessWidget {
  const PreviewCard({required this.event, required this.onTap, super.key});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final meta = context.text.body.copyWith(
      color: t.textPrimary.withValues(alpha: 0.8),
      fontSize: 14,
      fontWeight: FontWeight.w500,
    );
    return Semantics(
      button: true,
      label: context.l10n.openNamed(event.title),
      child: Pressable(
        key: const ValueKey('preview-card'),
        onTap: onTap,
        pressedScale: 0.98,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: t.surface.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(t.radii.previewCard),
            boxShadow: [
              BoxShadow(
                color: t.shadow(0.12),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(t.radii.thumbnail),
                child: SizedBox.square(
                  dimension: 88,
                  child: EventImage(
                    url: event.coverImageUrl,
                    category: event.category,
                    cacheWidth: 300,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.cardTitle.copyWith(fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formatPreviewRange(event.startAt, event.endAt),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: meta,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: t.textPrimary.withValues(alpha: 0.8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mapAddress(event),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: meta,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small purple pin for non-selected events on the map.
class MiniPin extends StatelessWidget {
  const MiniPin({
    required this.onTap,
    required this.semanticLabel,
    super.key,
  });

  final VoidCallback onTap;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: t.primary.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 3),
              boxShadow: [
                BoxShadow(
                  color: t.primary.withValues(alpha: 0.35),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The lavender 'exploreNearest' sheet body: handle, search, list.
class NearestSheet extends StatelessWidget {
  const NearestSheet({
    required this.scroll,
    required this.items,
    required this.selectedId,
    required this.search,
    required this.onQuery,
    required this.onFilters,
    required this.onSelect,
    required this.bottomPadding,
    super.key,
  });

  final ScrollController scroll;
  final List<NearbyEvent> items;
  final String? selectedId;
  final TextEditingController search;
  final ValueChanged<String> onQuery;
  final VoidCallback onFilters;
  final ValueChanged<NearbyEvent> onSelect;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.sheet,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(t.radii.sheet),
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A6B3FA0),
            blurRadius: 30,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: CustomScrollView(
        controller: scroll,
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 14, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      key: const ValueKey('sheet-handle'),
                      width: 48,
                      height: 7,
                      decoration: BoxDecoration(
                        color: t.disabled,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  _SearchField(
                    controller: search,
                    onChanged: onQuery,
                    onFilters: onFilters,
                  ),
                  const SizedBox(height: 22),
                  Text(
                    context.l10n.exploreNearest,
                    style: context.text.sectionTitle.copyWith(fontSize: 21),
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
          if (items.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: Column(
                  key: const ValueKey('nearest-empty'),
                  children: [
                    Icon(
                      Icons.location_searching_rounded,
                      size: 40,
                      color: t.primary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      context.l10n.exploreNoPlaces,
                      style: context.text.body.copyWith(color: t.textPrimary),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsetsDirectional.fromSTEB(24, 0, 24, bottomPadding),
              sliver: SliverList.separated(
                itemCount: items.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (context, i) => NearestLocationCard(
                  key: ValueKey('nearest-${items[i].event.id}'),
                  item: items[i],
                  index: i,
                  selected: items[i].event.id == selectedId,
                  onTap: () => onSelect(items[i]),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.onChanged,
    required this.onFilters,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilters;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: t.shadow(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsetsDirectional.only(start: 18, end: 6),
      child: Row(
        children: [
          Icon(Icons.search_rounded, color: t.textSecondary, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              key: const ValueKey('explore-search'),
              controller: controller,
              onChanged: onChanged,
              textInputAction: TextInputAction.search,
              style: context.text.body.copyWith(
                color: t.textPrimary,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                hintText: context.l10n.exploreSearchHint,
                hintStyle: context.text.body.copyWith(
                  color: t.textSecondary,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          IconButton(
            key: const ValueKey('explore-filters'),
            tooltip: context.l10n.filtersTitle,
            onPressed: onFilters,
            icon: Icon(Icons.tune_rounded, color: t.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// One 'exploreNearest' row: tinted pin circle, name, address, distance.
/// Selected rows get a purple border.
class NearestLocationCard extends StatelessWidget {
  const NearestLocationCard({
    required this.item,
    required this.index,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final NearbyEvent item;
  final int index;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    final tint = index.isEven ? t.primary : t.accentOrange;
    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.explorePlaceSemantics(
        item.event.title,
        mapAddress(item.event),
        formatKm(item.km),
      ),
      excludeSemantics: true,
      child: Pressable(
        onTap: onTap,
        pressedScale: 0.98,
        child: AnimatedContainer(
          duration: t.motion.medium,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsetsDirectional.fromSTEB(16, 13, 20, 13),
          decoration: BoxDecoration(
            color: t.surface,
            borderRadius: BorderRadius.circular(t.radii.listCard),
            border: Border.all(
              color: selected ? t.primary : t.surface,
              width: 1.6,
            ),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? t.primary.withValues(alpha: 0.18)
                    : t.shadow(0.05),
                blurRadius: selected ? 22 : 14,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on_rounded, color: tint, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.event.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.cardTitle.copyWith(fontSize: 17),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      mapAddress(item.event),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.text.body.copyWith(
                        fontSize: 14,
                        color: t.textPrimary.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Text(
                formatKm(item.km),
                key: ValueKey('km-${item.event.id}'),
                style: context.text.body.copyWith(
                  fontSize: 14,
                  color: t.textPrimary.withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Row in the venue events sheet.
class VenueEventTile extends StatelessWidget {
  const VenueEventTile({required this.event, required this.onTap, super.key});

  final Event event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      key: ValueKey('venue-event-${event.id}'),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SizedBox.square(
          dimension: 52,
          child: EventImage(
            url: event.coverImageUrl,
            category: event.category,
            cacheWidth: 160,
          ),
        ),
      ),
      title: Text(
        event.title,
        style: context.text.cardTitle.copyWith(fontSize: 16),
      ),
      subtitle: Text(
        formatPreviewRange(event.startAt, event.endAt),
        style: context.text.caption,
      ),
      trailing: Text(formatPrice(event.price)),
    );
  }
}
