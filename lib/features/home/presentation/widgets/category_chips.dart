import 'package:eventra/core/theme/app_theme.dart';
import 'package:eventra/core/theme/eventra_tokens.dart';
import 'package:eventra/core/widgets/pressable.dart';
import 'package:eventra/features/events/domain/entities/event_category.dart';
import 'package:eventra/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// 'See All' + the eight categories. The row bleeds off the right edge.
class CategoryChips extends StatelessWidget {
  const CategoryChips({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final EventCategory? selected;
  final ValueChanged<EventCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <EventCategory?>[null, ...EventCategory.values];
    return SizedBox(
      height: 72,
      child: ListView.separated(
        clipBehavior: Clip.none,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsetsDirectional.fromSTEB(24, 6, 24, 18),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) => _Chip(
          label: items[i]?.label ?? context.l10n.seeAll,
          selected: items[i] == selected,
          onTap: () => onSelected(items[i]),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.tokens;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: Pressable(
        key: ValueKey('chip-$label'),
        onTap: onTap,
        child: AnimatedContainer(
          duration: t.motion.medium,
          curve: t.motion.standard,
          padding: const EdgeInsets.symmetric(horizontal: 30),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? t.primaryGradient : null,
            color: selected ? null : t.surface,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x40BC47F5),
                      blurRadius: 14,
                      offset: Offset(0, 6),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: context.tokens.shadowOr(
                        const Color(0x128A4FC8),
                        0.07,
                      ),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Text(
            label,
            style: context.text.body.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: selected ? Colors.white : t.textPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
